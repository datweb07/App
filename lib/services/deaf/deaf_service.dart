import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_nckh/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DeafService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  // Lấy danh sách kiểu người dùng deaf từ Firestore
  Stream<List<Map<String, dynamic>>> getDeafUserStream() {
    return firestore
        .collection("Users")
        .where("userType", isEqualTo: "deaf")
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  // Lấy danh sách cuộc trò chuyện cho người dùng hiện tại
  Stream<List<Map<String, dynamic>>> getConversationsStream() {
    final currentUserID = auth.currentUser?.uid;
    if (currentUserID == null) {
      return Stream.value([]); // Trả về stream rỗng nếu không có người dùng
    }

    return firestore
        .collection("chat_rooms")
        .where("participants", arrayContains: currentUserID)
        .snapshots()
        .asyncMap((snapshot) async {
          List<Map<String, dynamic>> conversations = [];

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final participants = List<String>.from(data["participants"] ?? []);

            // ID của người dùng khác trong cuộc trò chuyện
            final otherUserID = participants.firstWhere(
              (id) => id != currentUserID,
              orElse: () => "",
            );

            if (otherUserID.isNotEmpty) {
              final userDoc = await firestore
                  .collection("Users")
                  .doc(otherUserID)
                  .get();
              if (userDoc.exists) {
                final userData = userDoc.data()!;

                // Chỉ hiển thị cuộc trò chuyện với người dùng blind hoặc deaf khác
                if (userData["userType"] == "blind" ||
                    userData["userType"] == "deaf") {
                  final unreadCount = await getUnreadMessageCount(
                    currentUserID,
                    otherUserID,
                  );

                  conversations.add({
                    "uid": otherUserID,
                    "email": userData["email"],
                    "photoURL": userData["photoURL"],
                    "userType": userData["userType"],
                    "isOnline": userData["isOnline"] ?? false,
                    "lastSeen": userData["lastSeen"],
                    "lastMessage": data["lastMessage"] ?? "",
                    "lastMessageTime": data["lastMessageTime"],
                    "lastMessageSenderID": data["lastMessageSenderID"],
                    "lastMessageID": data["lastMessageID"] ?? "",
                    "unreadCount": unreadCount,
                  });
                }
              }
            }
          }

          // Sắp xếp cuộc trò chuyện theo thời gian tin nhắn cuối
          conversations.sort((a, b) {
            final timeA = a["lastMessageTime"] as Timestamp?;
            final timeB = b["lastMessageTime"] as Timestamp?;

            if (timeA == null && timeB == null) return 0;
            if (timeA == null) return 1;
            if (timeB == null) return -1;

            return timeB.compareTo(timeA);
          });

          return conversations;
        });
  }

  /// Gửi tin nhắn text
  Future<String> sendMessage(String receiverID, String message) async {
    try {
      final String currentUserID = auth.currentUser!.uid;
      final String currentUserEmail = auth.currentUser!.email!;
      final Timestamp timestamp = Timestamp.now();

      // Tạo chat room ID
      List<String> ids = [currentUserID, receiverID];
      ids.sort();
      String chatRoomID = ids.join('_');

      // Tạo document mới cho tin nhắn
      DocumentReference docRef = firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("message")
          .doc();

      // Tạo đối tượng message
      Message newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: message,
        timestamp: timestamp,
        messageType: 'text',
        messageID: docRef.id,
      );

      // Lưu message vào firestore
      await docRef.set(newMessage.map());

      // Cập nhật metadata phòng chat
      await updateChatRoomMetadata(
        chatRoomID,
        currentUserID,
        receiverID,
        message,
        timestamp,
        docRef.id,
      );

      return docRef.id; // Trả về ID tin nhắn
    } catch (e) {
      throw Exception('Lỗi khi gửi tin nhắn: $e');
    }
  }

  // Cập nhật metadata của phòng chat
  Future<void> updateChatRoomMetadata(
    String chatRoomID,
    String senderID,
    String receiverID,
    String message,
    Timestamp timestamp,
    String messageID,
  ) async {
    await firestore.collection("chat_rooms").doc(chatRoomID).set({
      "participants": [senderID, receiverID],
      "lastMessage": message,
      "lastMessageTime": timestamp,
      "lastMessageSenderID": senderID,
      "updatedAt": timestamp,
      "lastMessageID": messageID,
    }, SetOptions(merge: true)); // Gộp dữ liệu để tránh ghi đè
  }

  /// Lấy danh sách tin nhắn trong phòng chat
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("message")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  /// Đánh dấu tin nhắn đã đọc
  Future<void> markMessagesAsRead(
    String currentUserID,
    String otherUserID,
  ) async {
    List<String> id = [currentUserID, otherUserID];
    id.sort();
    String chatroomID = id.join('_');

    // Lấy tin nhắn chưa đọc
    final messages = await firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("message")
        .where("receiverID", isEqualTo: currentUserID)
        .where("isRead", isEqualTo: false)
        .get();

    // Update status đã đọc
    for (var doc in messages.docs) {
      await doc.reference.update({"isRead": true});
    }
  }

  /// Đếm tin nhắn chưa đọc
  Future<int> getUnreadMessageCount(
    String currentUserID,
    String otherUserID,
  ) async {
    List<String> id = [currentUserID, otherUserID];
    id.sort();
    String chatroomID = id.join('_');

    // Lấy số tin nhắn chưa đọc
    final unreadMessages = await firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("message")
        .where("receiverID", isEqualTo: currentUserID)
        .where("isRead", isEqualTo: false)
        .get();

    return unreadMessages.docs.length;
  }

  /// Xóa tin nhắn
  Future<void> deleteMessage(String messageID, String otherUserID) async {
    final currentUserId = auth.currentUser!.uid;

    // Tạo chatroom ID
    List<String> ids = [currentUserId, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    // Tìm và xóa tin nhắn có messageID
    final querySnapshot = await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('message')
        .where(messageID)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Xóa document đầu tiên tìm được
      await querySnapshot.docs.first.reference.delete();

      // Cập nhật metadata sau xóa
      await _updateLastMessageAfterDelete(chatRoomID);
    } else {
      throw Exception('Không tìm thấy tin nhắn để xóa');
    }
  }

  // Cập nhật metadata phòng chat sau khi xóa tin nhắn
  Future<void> _updateLastMessageAfterDelete(String chatRoomID) async {
    final messagesSnapshot = await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('message')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (messagesSnapshot.docs.isEmpty) {
      final lastMessage = messagesSnapshot.docs.first;
      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomID)
          .update({
            'lastMessage': lastMessage['message'],
            'lastMessageSenderID': lastMessage['senderID'],
            'lastMessageTime': lastMessage['timestamp'],
          });
    } else {
      // Nếu không còn tin nhắn nào, xóa phòng chat
      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomID)
          .delete();
      // .update({
      //   'lastMessage': '',
      //   'lastMessageID': '',
      //   'lastMessageSenderID': '',
      //   'lastMessageTime': null,
      // });
    }
  }

  /// Tìm kiếm tin nhắn trong phòng chat
  Stream<QuerySnapshot> searchMessages(
    String currentUserID,
    String otherUserID,
    String query,
  ) {
    List<String> id = [currentUserID, otherUserID];
    id.sort();
    String chatroomID = id.join('_');

    // Tìm kiếm tin nhắn theo nội dung
    return firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("message")
        .where("message", isGreaterThanOrEqualTo: query)
        .where("message", isLessThanOrEqualTo: '$query\uf8ff')
        .orderBy("message")
        .snapshots();
  }

  /// Cập nhật trạng thái online
  Future<void> updateUserOnlineStatus(bool isOnline) async {
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      await firestore.collection("Users").doc(currentUser.uid).update({
        "isOnline": isOnline,
        "lastSeen": Timestamp.now(),
      });
    }
  }

  /// Lấy thời gian hoạt động cuối
  Future<String> getLastSeenTime(String userID) async {
    final userDoc = await firestore.collection("Users").doc(userID).get();
    if (userDoc.exists) {
      final lastSeen = userDoc.data()?["lastSeen"] as Timestamp?;
      final isOnline = userDoc.data()?["isOnline"] as bool? ?? false;

      if (isOnline) {
        return "Đang hoạt động";
      } else if (lastSeen != null) {
        final now = DateTime.now();
        final lastSeenTime = lastSeen.toDate();
        final difference = now.difference(lastSeenTime);

        if (difference.inDays > 0) {
          return "Hoạt động ${difference.inDays} ngày trước";
        } else if (difference.inHours > 0) {
          return "Hoạt động ${difference.inHours} giờ trước";
        } else if (difference.inMinutes > 0) {
          return "Hoạt động ${difference.inMinutes} phút trước";
        } else {
          return "Hoạt động vừa xong";
        }
      }
    }
    return "Không rõ";
  }

  /// Gửi tin nhắn với emoji/sticker
  Future<void> sendEmojiMessage(String receiverID, String emoji) async {
    await sendMessage(receiverID, emoji);
  }

  /// Gửi tin nhắn hình ảnh
  Future<String> sendImageMessage(String receiverID, String imagePath) async {
    try {
      final String currentUserID = auth.currentUser!.uid;
      final String currentUserEmail = auth.currentUser!.email!;
      final Timestamp timestamp = Timestamp.now();

      // Tạo tên file duy nhất cho ảnh
      String fileName =
          'chat_images/${currentUserID}_${timestamp.millisecondsSinceEpoch}.jpg';

      // Upload ảnh lên Firebase Storage
      File imageFile = File(imagePath);

      // Kiểm tra file có tồn tại không
      if (!await imageFile.exists()) {
        throw Exception('File ảnh không tồn tại');
      }

      // Tạo reference và upload
      Reference storageRef = storage.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(imageFile);

      // Đợi upload hoàn thành
      TaskSnapshot snapshot = await uploadTask;

      // Lấy download URL
      String downloadURL = await snapshot.ref.getDownloadURL();

      // Tạo chat room ID
      List<String> ids = [currentUserID, receiverID];
      ids.sort();
      String chatRoomID = ids.join('_');

      // Tạo document reference với ID tự động
      DocumentReference docRef = firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("message")
          .doc();

      // Tạo message với URL ảnh và messageID
      Message newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: downloadURL, // URL ảnh
        timestamp: timestamp,
        messageType: 'image', // Đánh dấu đây là tin nhắn ảnh
        messageID: docRef.id, // Thêm messageID
      );

      // Lưu message với ID đã định sẵn
      await docRef.set(newMessage.map());

      // Update chat room metadata
      await updateChatRoomMetadata(
        chatRoomID,
        currentUserID,
        receiverID,
        "[Hình ảnh]", // Hiển thị text thay vì URL trong last message
        timestamp,
        docRef.id,
      );

      return docRef.id; // Return messageID
    } catch (e) {
      print('Error sending image: $e');
      throw Exception('Lỗi khi gửi ảnh: $e');
    }
  }
}
