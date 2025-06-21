// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:demo_nckh/models/message.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

// class SpeakingService {
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//   final FirebaseAuth auth = FirebaseAuth.instance;
//   final stt.SpeechToText speechToText = stt.SpeechToText();

//   /// Lấy danh sách người dùng
//   Stream<List<Map<String, dynamic>>> getBlindUserStream() {
//     return firestore.collection("Users").where("userType", isEqualTo: "blind").snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) => doc.data()).toList();
//     });
//   }

//   /// Gửi tin nhắn từ người dùng hiện tại đến người nhận
//   Future<void> sendMessage(String receiverID, String message) async {
//     final String currentUserID = auth.currentUser!.uid;
//     final String currentUserEmail = auth.currentUser!.email!;
//     final Timestamp timestamp = Timestamp.now();

//     Message newMessage = Message(
//       senderID: currentUserID,
//       senderEmail: currentUserEmail,
//       receiverID: receiverID,
//       message: message,
//       timestamp: timestamp,
//     );

//     List<String> ids = [currentUserID, receiverID];
//     ids.sort();
//     String chatRoomID = ids.join('_');

//     await firestore
//         .collection("chat_rooms")
//         .doc(chatRoomID)
//         .collection("message")
//         .add(newMessage.map());
//   }

//   /// Lấy danh sách tin nhắn giữa hai người, đã được sắp xếp theo thời gian (cũ -> mới)
//   Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
//     List<String> ids = [userID, otherUserID];
//     ids.sort();
//     String chatRoomID = ids.join('_');

//     return firestore
//         .collection("chat_rooms")
//         .doc(chatRoomID)
//         .collection("message")
//         .orderBy("timestamp", descending: false)
//         .snapshots();
//   }

//   /// Nhận diện giọng nói 1 lần rồi trả về chuỗi văn bản
//   Future<String> listenOnce() async {
//     bool available = await speechToText.initialize();
//     if (!available) return "Không thể khởi tạo trình nhận dạng giọng nói";

//     await speechToText.listen(
//       onResult: (result) {},
//       listenMode: stt.ListenMode.dictation,
//       pauseFor: Duration(seconds: 3),
//     );

//     await Future.delayed(Duration(seconds: 5));
//     await speechToText.stop();

//     return speechToText.lastRecognizedWords;
//   }

//   /// Xóa một tin nhắn trong chat room cụ thể
//   Future<void> deleteMessage({
//     required String userID,
//     required String otherUserID,
//     required String messageId,
//   }) async {
//     List<String> ids = [userID, otherUserID];
//     ids.sort();
//     String chatRoomID = ids.join('_');

//     await firestore
//         .collection("chat_rooms")
//         .doc(chatRoomID)
//         .collection("message")
//         .doc(messageId)
//         .delete();
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:demo_nckh/models/message.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

// class BlindService {
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//   final FirebaseAuth auth = FirebaseAuth.instance;
//   final stt.SpeechToText speechToText = stt.SpeechToText();

//   /// Lấy danh sách người dùng blind
//   Stream<List<Map<String, dynamic>>> getBlindUserStream() {
//     return firestore
//         .collection("Users")
//         .where("userType", isEqualTo: "blind")
//         .snapshots()
//         .map((snapshot) {
//           return snapshot.docs.map((doc) => doc.data()).toList();
//         });
//   }

//   /// Lấy danh sách cuộc trò chuyện cho người dùng blind
//   Stream<List<Map<String, dynamic>>> getConversationsStream() {
//     final currentUserID = auth.currentUser?.uid;
//     if (currentUserID == null) {
//       return Stream.value([]);
//     }

//     return firestore
//         .collection("chat_rooms")
//         .where("participants", arrayContains: currentUserID)
//         .snapshots()
//         .asyncMap((snapshot) async {
//           List<Map<String, dynamic>> conversations = [];

//           for (var doc in snapshot.docs) {
//             final data = doc.data();
//             final participants = List<String>.from(data["participants"] ?? []);

//             final otherUserID = participants.firstWhere(
//               (id) => id != currentUserID,
//               orElse: () => "",
//             );

//             if (otherUserID.isNotEmpty) {
//               final userDoc = await firestore
//                   .collection("Users")
//                   .doc(otherUserID)
//                   .get();
//               if (userDoc.exists) {
//                 final userData = userDoc.data()!;

//                 // Chỉ hiển thị cuộc trò chuyện với người dùng deaf hoặc blind khác
//                 if (userData["userType"] == "deaf" ||
//                     userData["userType"] == "blind") {
//                   final unreadCount = await getUnreadMessageCount(
//                     currentUserID,
//                     otherUserID,
//                   );

//                   conversations.add({
//                     "uid": otherUserID,
//                     "email": userData["email"],
//                     "photoURL": userData["photoURL"],
//                     "userType": userData["userType"],
//                     "isOnline": userData["isOnline"] ?? false,
//                     "lastSeen": userData["lastSeen"],
//                     "lastMessage": data["lastMessage"] ?? "",
//                     "lastMessageTime": data["lastMessageTime"],
//                     "lastMessageSenderID": data["lastMessageSenderID"],
//                     "unreadCount": unreadCount,
//                   });
//                 }
//               }
//             }
//           }

//           conversations.sort((a, b) {
//             final timeA = a["lastMessageTime"] as Timestamp?;
//             final timeB = b["lastMessageTime"] as Timestamp?;

//             if (timeA == null && timeB == null) return 0;
//             if (timeA == null) return 1;
//             if (timeB == null) return -1;

//             return timeB.compareTo(timeA);
//           });

//           return conversations;
//         });
//   }

//   /// Gửi tin nhắn với hỗ trợ voice cho người blind
//   Future<void> sendMessage(String receiverID, String message) async {
//     final String currentUserID = auth.currentUser!.uid;
//     final String currentUserEmail = auth.currentUser!.email!;
//     final Timestamp timestamp = Timestamp.now();

//     Message newMessage = Message(
//       senderID: currentUserID,
//       senderEmail: currentUserEmail,
//       receiverID: receiverID,
//       message: message,
//       timestamp: timestamp,
//     );

//     List<String> ids = [currentUserID, receiverID];
//     ids.sort();
//     String chatRoomID = ids.join('_');

//     await firestore
//         .collection("chat_rooms")
//         .doc(chatRoomID)
//         .collection("message")
//         .add(newMessage.map());

//     await updateChatRoomMetadata(
//       chatRoomID,
//       currentUserID,
//       receiverID,
//       message,
//       timestamp,
//     );
//   }

//   /// Update chat room metadata
//   Future<void> updateChatRoomMetadata(
//     String chatRoomID,
//     String senderID,
//     String receiverID,
//     String message,
//     Timestamp timestamp,
//   ) async {
//     await firestore.collection("chat_rooms").doc(chatRoomID).set({
//       "participants": [senderID, receiverID],
//       "lastMessage": message,
//       "lastMessageTime": timestamp,
//       "lastMessageSenderID": senderID,
//       "updatedAt": timestamp,
//     }, SetOptions(merge: true));
//   }

//   /// Lấy tin nhắn
//   Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
//     List<String> ids = [userID, otherUserID];
//     ids.sort();
//     String chatRoomID = ids.join('_');

//     return firestore
//         .collection("chat_rooms")
//         .doc(chatRoomID)
//         .collection("message")
//         .orderBy("timestamp", descending: false)
//         .snapshots();
//   }

//   /// Nhận diện giọng nói (chức năng chính cho người blind)
//   Future<String> listenOnce() async {
//     bool available = await speechToText.initialize();
//     if (!available) return "Không thể khởi tạo trình nhận dạng giọng nói";

//     await speechToText.listen(
//       onResult: (result) {},
//       listenMode: stt.ListenMode.dictation,
//       pauseFor: Duration(seconds: 3),
//     );

//     await Future.delayed(Duration(seconds: 5));
//     await speechToText.stop();

//     return speechToText.lastRecognizedWords;
//   }

//   /// Đánh dấu tin nhắn đã đọc
//   Future<void> markMessagesAsRead(
//     String currentUserID,
//     String otherUserID,
//   ) async {
//     List<String> id = [currentUserID, otherUserID];
//     id.sort();
//     String chatroomID = id.join('_');

//     final messages = await firestore
//         .collection("chat_rooms")
//         .doc(chatroomID)
//         .collection("message")
//         .where("receiverID", isEqualTo: currentUserID)
//         .where("isRead", isEqualTo: false)
//         .get();

//     for (var doc in messages.docs) {
//       await doc.reference.update({"isRead": true});
//     }
//   }

//   /// Đếm tin nhắn chưa đọc
//   Future<int> getUnreadMessageCount(
//     String currentUserID,
//     String otherUserID,
//   ) async {
//     List<String> id = [currentUserID, otherUserID];
//     id.sort();
//     String chatroomID = id.join('_');

//     final unreadMessages = await firestore
//         .collection("chat_rooms")
//         .doc(chatroomID)
//         .collection("message")
//         .where("receiverID", isEqualTo: currentUserID)
//         .where("isRead", isEqualTo: false)
//         .get();

//     return unreadMessages.docs.length;
//   }

//   /// Xóa tin nhắn
//   Future<void> deleteMessage({
//     required String userID,
//     required String otherUserID,
//     required String messageId,
//   }) async {
//     List<String> ids = [userID, otherUserID];
//     ids.sort();
//     String chatRoomID = ids.join('_');

//     await firestore
//         .collection("chat_rooms")
//         .doc(chatRoomID)
//         .collection("message")
//         .doc(messageId)
//         .delete();
//   }

//   /// Cập nhật trạng thái online
//   Future<void> updateUserOnlineStatus(bool isOnline) async {
//     final currentUser = auth.currentUser;
//     if (currentUser != null) {
//       await firestore.collection("Users").doc(currentUser.uid).update({
//         "isOnline": isOnline,
//         "lastSeen": Timestamp.now(),
//       });
//     }
//   }

//   /// Lấy thời gian hoạt động cuối
//   Future<String> getLastSeenTime(String userID) async {
//     final userDoc = await firestore.collection("Users").doc(userID).get();
//     if (userDoc.exists) {
//       final lastSeen = userDoc.data()?["lastSeen"] as Timestamp?;
//       final isOnline = userDoc.data()?["isOnline"] as bool? ?? false;

//       if (isOnline) {
//         return "Đang hoạt động";
//       } else if (lastSeen != null) {
//         final now = DateTime.now();
//         final lastSeenTime = lastSeen.toDate();
//         final difference = now.difference(lastSeenTime);

//         if (difference.inDays > 0) {
//           return "Hoạt động ${difference.inDays} ngày trước";
//         } else if (difference.inHours > 0) {
//           return "Hoạt động ${difference.inHours} giờ trước";
//         } else if (difference.inMinutes > 0) {
//           return "Hoạt động ${difference.inMinutes} phút trước";
//         } else {
//           return "Hoạt động vừa xong";
//         }
//       }
//     }
//     return "Không rõ";
//   }
// }
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_nckh/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class BlindService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  /// Lấy danh sách người dùng deaf
  Stream<List<Map<String, dynamic>>> getBlindUserStream() {
    return firestore
        .collection("Users")
        .where("userType", isEqualTo: "blind")
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  /// Lấy danh sách cuộc trò chuyện cho người dùng deaf
  Stream<List<Map<String, dynamic>>> getConversationsStream() {
    final currentUserID = auth.currentUser?.uid;
    if (currentUserID == null) {
      return Stream.value([]);
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
                    "unreadCount": unreadCount,
                  });
                }
              }
            }
          }

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
  Future<void> sendMessage(String receiverID, String message) async {
    try {
      final String currentUserID = auth.currentUser!.uid;
      final String currentUserEmail = auth.currentUser!.email!;
      final Timestamp timestamp = Timestamp.now();

      Message newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: message,
        timestamp: timestamp,
        messageType: 'text',
      );

      List<String> ids = [currentUserID, receiverID];
      ids.sort();
      String chatRoomID = ids.join('_');

      await firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("message")
          .add(newMessage.map());

      await updateChatRoomMetadata(
        chatRoomID,
        currentUserID,
        receiverID,
        message,
        timestamp,
      );
    } catch (e) {
      throw Exception('Lỗi khi gửi tin nhắn: $e');
    }
  }

  /// Update chat room metadata
  Future<void> updateChatRoomMetadata(
    String chatRoomID,
    String senderID,
    String receiverID,
    String message,
    Timestamp timestamp,
  ) async {
    await firestore.collection("chat_rooms").doc(chatRoomID).set({
      "participants": [senderID, receiverID],
      "lastMessage": message,
      "lastMessageTime": timestamp,
      "lastMessageSenderID": senderID,
      "updatedAt": timestamp,
    }, SetOptions(merge: true));
  }

  /// Lấy tin nhắn
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
  // Future<void> markMessagesAsRead(
  //   String currentUserID,
  //   String otherUserID,
  // ) async {
  //   List<String> id = [currentUserID, otherUserID];
  //   id.sort();
  //   String chatroomID = id.join('_');

  //   final messages = await firestore
  //       .collection("chat_rooms")
  //       .doc(chatroomID)
  //       .collection("message")
  //       .where("receiverID", isEqualTo: currentUserID)
  //       .where("isRead", isEqualTo: false)
  //       .get();

  //   for (var doc in messages.docs) {
  //     await doc.reference.update({"isRead": true});
  //   }
  // }
  Future<void> markMessagesAsRead(
    String currentUserID,
    String otherUserID,
  ) async {
    try {
      List<String> ids = [currentUserID, otherUserID];
      ids.sort();
      String chatRoomID = ids.join('_');

      QuerySnapshot unreadMessages = await firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .where("receiverID", isEqualTo: currentUserID)
          .where("isRead", isEqualTo: false)
          .get();

      for (DocumentSnapshot doc in unreadMessages.docs) {
        await doc.reference.update({"isRead": true});
      }
    } catch (e) {
      print('Error marking messages as read: $e');
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
  Future<void> deleteMessage(
    String messageID,
    String currentUserID,
    String otherUserID,
  ) async {
    List<String> id = [currentUserID, otherUserID];
    id.sort();
    String chatroomID = id.join('_');

    await firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("message")
        .doc(messageID)
        .delete();
  }

  /// Tìm kiếm tin nhắn trong cuộc trò chuyện (hữu ích cho người deaf)
  Stream<QuerySnapshot> searchMessages(
    String currentUserID,
    String otherUserID,
    String query,
  ) {
    List<String> id = [currentUserID, otherUserID];
    id.sort();
    String chatroomID = id.join('_');

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

  /// Gửi tin nhắn với emoji/sticker (phù hợp với giao tiếp deaf)
  Future<void> sendEmojiMessage(String receiverID, String emoji) async {
    await sendMessage(receiverID, emoji);
  }

  // Gửi tin nhắn hình ảnh
  // Future<void> sendImageMessage(String receiverID, String imagePath) async {
  //   try {
  //     final currentUserID = auth.currentUser!.uid;
  //     final currentUserEmail = auth.currentUser!.email!;
  //     final timestamp = Timestamp.now();

  //     // Upload ảnh lên Firebase Storage
  //     final storageRef = FirebaseStorage.instance
  //         .ref()
  //         .child('chat_images')
  //         .child('${currentUserID}_${timestamp.millisecondsSinceEpoch}.jpg');

  //     final uploadTask = await storageRef.putFile(File(imagePath));
  //     final imageUrl = await uploadTask.ref.getDownloadURL();

  //     // Tạo tin nhắn với URL ảnh
  //     Message newMessage = Message(
  //       senderID: currentUserID,
  //       senderEmail: currentUserEmail,
  //       receiverID: receiverID,
  //       message: imageUrl, // Lưu URL ảnh
  //       timestamp: timestamp,
  //       messageType: 'image', // Thêm type để phân biệt
  //     );

  //     // Lưu tin nhắn vào Firestore
  //     List<String> ids = [currentUserID, receiverID];
  //     ids.sort();
  //     String chatRoomID = ids.join('_');

  //     await firestore
  //         .collection("chat_rooms")
  //         .doc(chatRoomID)
  //         .collection("messages")
  //         .add(newMessage.map());
  //   } catch (e) {
  //     throw Exception('Lỗi khi gửi ảnh: ${e.toString()}');
  //   }
  // }
  // Gửi tin nhắn hình ảnh
  Future<void> sendImageMessage(String receiverID, String imagePath) async {
    try {
      final String currentUserID = auth.currentUser!.uid;
      final String currentUserEmail = auth.currentUser!.email!;
      final Timestamp timestamp = Timestamp.now();

      // Tạo tên file unique
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

      // Tạo message với URL ảnh
      Message newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: downloadURL, // URL ảnh
        timestamp: timestamp,
        messageType: 'image', // Đánh dấu đây là tin nhắn ảnh
      );

      // Tạo chat room ID
      List<String> ids = [currentUserID, receiverID];
      ids.sort();
      String chatRoomID = ids.join('_');

      // Lưu message vào Firestore
      await firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .add(newMessage.map());
    } catch (e) {
      print('Error sending image: $e');
      throw Exception('Lỗi khi gửi ảnh: $e');
    }
  }
}
