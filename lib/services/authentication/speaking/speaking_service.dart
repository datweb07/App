import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_nckh/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeakingService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final stt.SpeechToText speechToText = stt.SpeechToText();

  /// Lấy danh sách người dùng
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Gửi tin nhắn từ người dùng hiện tại đến người nhận
  Future<void> sendMessage(String receiverID, String message) async {
    final String currentUserID = auth.currentUser!.uid;
    final String currentUserEmail = auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    await firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("message")
        .add(newMessage.map());
  }

  /// Lấy danh sách tin nhắn giữa hai người, đã được sắp xếp theo thời gian (cũ -> mới)
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

  /// Nhận diện giọng nói 1 lần rồi trả về chuỗi văn bản
  Future<String> listenOnce() async {
    bool available = await speechToText.initialize();
    if (!available) return "Không thể khởi tạo trình nhận dạng giọng nói";

    await speechToText.listen(
      onResult: (result) {},
      listenMode: stt.ListenMode.dictation,
      pauseFor: Duration(seconds: 3),
    );

    await Future.delayed(Duration(seconds: 5));
    await speechToText.stop();

    return speechToText.lastRecognizedWords;
  }

  /// Xóa một tin nhắn trong chat room cụ thể
  Future<void> deleteMessage({
    required String userID,
    required String otherUserID,
    required String messageId,
  }) async {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    await firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("message")
        .doc(messageId)
        .delete();
  }
}
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:demo_nckh/models/message.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

// enum MessageSortType {
//   newest, // Mới nhất trước
//   oldest, // Cũ nhất trước
//   unreadFirst, // Chưa đọc trước
//   readFirst, // Đã đọc trước
// }

// enum MessageType { text, voice, image, file }

// class SpeakingService {
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//   final FirebaseAuth auth = FirebaseAuth.instance;
//   final stt.SpeechToText speechToText = stt.SpeechToText();

//   // ==================== USER MANAGEMENT ====================

//   /// Lấy danh sách người dùng với thông tin trạng thái
//   Stream<List<Map<String, dynamic>>> getUserStream() {
//     return firestore
//         .collection("Users")
//         .orderBy("lastSeen", descending: true)
//         .snapshots()
//         .map((snapshot) {
//           return snapshot.docs.map((doc) {
//             final data = doc.data();
//             data['uid'] = doc.id;
//             return data;
//           }).toList();
//         });
//   }

//   /// Cập nhật trạng thái online/offline của user
//   Future<void> updateUserStatus(bool isOnline) async {
//     final user = auth.currentUser;
//     if (user == null) return;

//     await firestore.collection("Users").doc(user.uid).update({
//       'isOnline': isOnline,
//       'lastSeen': FieldValue.serverTimestamp(),
//     });
//   }

//   /// Lấy thông tin chi tiết của một user
//   Future<Map<String, dynamic>?> getUserInfo(String userId) async {
//     try {
//       final doc = await firestore.collection("Users").doc(userId).get();
//       if (doc.exists) {
//         final data = doc.data()!;
//         data['uid'] = doc.id;
//         return data;
//       }
//       return null;
//     } catch (e) {
//       print('Error getting user info: $e');
//       return null;
//     }
//   }

//   // ==================== MESSAGE MANAGEMENT ====================

//   /// Gửi tin nhắn với thông tin chi tiết hơn
//   Future<void> sendMessage(
//     String receiverID,
//     String message, {
//     MessageType type = MessageType.text,
//     Map<String, dynamic>? metadata,
//   }) async {
//     final String currentUserID = auth.currentUser!.uid;
//     final String currentUserEmail = auth.currentUser!.email!;
//     final Timestamp timestamp = Timestamp.now();

//     // Tạo ID duy nhất cho tin nhắn
//     final String messageId = firestore.collection('temp').doc().id;

//     Message newMessage = Message(
//       senderID: currentUserID,
//       senderEmail: currentUserEmail,
//       receiverID: receiverID,
//       message: message,
//       timestamp: timestamp,
//     );

//     // Thêm thông tin bổ sung cho tin nhắn
//     Map<String, dynamic> messageData = newMessage.map();
//     messageData.addAll({
//       'messageId': messageId,
//       'messageType': type.toString(),
//       'isRead': false,
//       'isDelivered': false,
//       'readBy': <String>[],
//       'deliveredAt': null,
//       'readAt': null,
//       'replyTo': null,
//       'isEdited': false,
//       'editedAt': null,
//       'metadata': metadata ?? {},
//     });

//     List<String> ids = [currentUserID, receiverID];
//     ids.sort();
//     String chatRoomID = ids.join('_');

//     // Gửi tin nhắn
//     await firestore
//         .collection("chat_rooms")
//         .doc(chatRoomID)
//         .collection("message")
//         .doc(messageId)
//         .set(messageData);

//     // Cập nhật thông tin chat room
//     await _updateChatRoomInfo(
//       chatRoomID,
//       currentUserID,
//       receiverID,
//       message,
//       timestamp,
//     );

//     // Đánh dấu tin nhắn đã được gửi
//     await markMessageAsDelivered(messageId, chatRoomID);
//   }

//   /// Cập nhật thông tin chat room (tin nhắn cuối, thời gian, số tin nhắn chưa đọc)
//   Future<void> _updateChatRoomInfo(
//     String chatRoomID,
//     String senderID,
//     String receiverID,
//     String lastMessage,
//     Timestamp timestamp,
//   ) async {
//     // Lấy số tin nhắn chưa đọc của người nhận
//     final unreadCount = await getUnreadMessageCount(receiverID, senderID);

//     await firestore.collection("chat_rooms").doc(chatRoomID).set({
//       'participants': [senderID, receiverID],
//       'lastMessage': lastMessage,
//       'lastMessageTime': timestamp,
//       'lastSenderID': senderID,
//       'unreadCount_$receiverID': unreadCount + 1,
//       'unreadCount_$senderID': 0,
//       'createdAt': FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   /// Lấy tin nhắn với các tùy chọn sắp xếp và lọc
//   Stream<QuerySnapshot> getMessages(
//     String userID,
//     String otherUserID, {
//     MessageSortType sortType = MessageSortType.newest,
//     int? limit,
//     bool includeDeleted = false,
//   }) {
//     List<String> ids = [userID, otherUserID];
//     ids.sort();
//     String chatRoomID = ids.join('_');

//     Query query = firestore
//         .collection("chat_rooms")
//         .doc(chatRoomID)
//         .collection("message");

//     // Lọc tin nhắn đã xóa
//     if (!includeDeleted) {
//       query = query.where('isDeleted', isEqualTo: false);
//     }

//     // Sắp xếp theo loại
//     switch (sortType) {
//       case MessageSortType.newest:
//         query = query.orderBy("timestamp", descending: true);
//         break;
//       case MessageSortType.oldest:
//         query = query.orderBy("timestamp", descending: false);
//         break;
//       case MessageSortType.unreadFirst:
//         query = query
//             .orderBy("isRead", descending: false)
//             .orderBy("timestamp", descending: true);
//         break;
//       case MessageSortType.readFirst:
//         query = query
//             .orderBy("isRead", descending: true)
//             .orderBy("timestamp", descending: true);
//         break;
//     }

//     // Giới hạn số lượng
//     if (limit != null) {
//       query = query.limit(limit);
//     }

//     return query.snapshots();
//   }

//   /// Lấy danh sách chat rooms đã sắp xếp theo tin nhắn mới nhất
//   Stream<List<Map<String, dynamic>>> getChatRooms(String userID) {
//     return firestore
//         .collection("chat_rooms")
//         .where('participants', arrayContains: userID)
//         .orderBy('lastMessageTime', descending: true)
//         .snapshots()
//         .map((snapshot) {
//           return snapshot.docs.map((doc) {
//             final data = doc.data();
//             data['chatRoomID'] = doc.id;
//             return data;
//           }).toList();
//         });
//   }

//   // ==================== READ/UNREAD MANAGEMENT ====================

//   /// Đánh dấu tin nhắn đã đọc
//   Future<void> markMessageAsRead(String messageId, String chatRoomID) async {
//     final currentUserID = auth.currentUser!.uid;

//     await firestore
//         .collection("chat_rooms")
//         .doc(chatRoomID)
//         .collection("message")
//         .doc(messageId)
//         .update({
//           'isRead': true,
//           'readAt': FieldValue.serverTimestamp(),
//           'readBy': FieldValue.arrayUnion([currentUserID]),
//         });
//   }

//   /// Đánh dấu tất cả tin nhắn trong chat đã đọc
//   Future<void> markAllMessagesAsRead(String userID, String otherUserID) async {
//     List<String> ids = [userID, otherUserID];
//     ids.sort();
//     String chatRoomID = ids.join('_');

//     // Lấy tất cả tin nhắn chưa đọc
//     final unreadMessages = await firestore
//         .collection("chat_rooms")
//         .doc(chatRoomID)
//         .collection("message")
//         .where('isRead', isEqualTo: false)
//         .where('senderID', isNotEqualTo: userID)
//         .get();

//     // Cập nhật từng tin nhắn
//     final batch = firestore.batch();
//     for (var doc in unreadMessages.docs) {
//       batch.update(doc.reference, {
//         'isRead': true,
//         'readAt': FieldValue.serverTimestamp(),
//         'readBy': FieldValue.arrayUnion([userID]),
//       });
//     }

//     // Cập nhật số tin nhắn chưa đọc trong chat room
//     batch.update(firestore.collection("chat_rooms").doc(chatRoomID), {
//       'unreadCount_$userID': 0,
//     });

//     await batch.commit();
//   }

//   /// Đánh dấu tin nhắn đã được gửi
//   Future<void> markMessageAsDelivered(
//     String messageId,
//     String chatRoomID,
//   ) async {
//     await firestore
//         .collection("chat_rooms")
//         .doc(chatRoomID)
//         .collection("message")
//         .doc(messageId)
//         .update({
//           'isDelivered': true,
//           'deliveredAt': FieldValue.serverTimestamp(),
//         });
//   }

//   /// Lấy số tin nhắn chưa đọc
//   Future<int> getUnreadMessageCount(String userID, String otherUserID) async {
//     List<String> ids = [userID, otherUserID];
//     ids.sort();
//     String chatRoomID = ids.join('_');

//     final unreadMessages = await firestore
//         .collection("chat_rooms")
//         .doc(chatRoomID)
//         .collection("message")
//         .where('isRead', isEqualTo: false)
//         .where('senderID', isEqualTo: otherUserID)
//         .get();

//     return unreadMessages.docs.length;
//   }

//   /// Lấy tổng số tin nhắn chưa đọc của user
//   Future<int> getTotalUnreadCount(String userID) async {
//     final chatRooms = await firestore
//         .collection("chat_rooms")
//         .where('participants', arrayContains: userID)
//         .get();

//     int totalUnread = 0;
//     for (var doc in chatRooms.docs) {
//       final data = doc.data();
//       final unreadCount = data['unreadCount_$userID'] ?? 0;
//       totalUnread += unreadCount as int;
//     }

//     return totalUnread;
//   }

//   // ==================== MESSAGE ACTIONS ====================

//   /// Xóa tin nhắn (soft delete)
//   Future<void> deleteMessage({
//     required String userID,
//     required String otherUserID,
//     required String messageId,
//     bool hardDelete = false,
//   }) async {
//     List<String> ids = [userID, otherUserID];
//     ids.sort();
//     String chatRoomID = ids.join('_');

//     if (hardDelete) {
//       // Xóa vĩnh viễn
//       await firestore
//           .collection("chat_rooms")
//           .doc(chatRoomID)
//           .collection("message")
//           .doc(messageId)
//           .delete();
//     } else {
//       // Xóa mềm
//       await firestore
//           .collection("chat_rooms")
//           .doc(chatRoomID)
//           .collection("message")
//           .doc(messageId)
//           .update({
//             'isDeleted': true,
//             'deletedAt': FieldValue.serverTimestamp(),
//             'deletedBy': userID,
//           });
//     }
//   }

//   /// Chỉnh sửa tin nhắn
//   Future<void> editMessage({
//     required String userID,
//     required String otherUserID,
//     required String messageId,
//     required String newMessage,
//   }) async {
//     List<String> ids = [userID, otherUserID];
//     ids.sort();
//     String chatRoomID = ids.join('_');

//     await firestore
//         .collection("chat_rooms")
//         .doc(chatRoomID)
//         .collection("message")
//         .doc(messageId)
//         .update({
//           'message': newMessage,
//           'isEdited': true,
//           'editedAt': FieldValue.serverTimestamp(),
//         });
//   }

//   /// Trả lời tin nhắn
//   Future<void> replyToMessage({
//     required String receiverID,
//     required String message,
//     required String replyToMessageId,
//     MessageType type = MessageType.text,
//   }) async {
//     await sendMessage(
//       receiverID,
//       message,
//       type: type,
//       metadata: {'replyTo': replyToMessageId},
//     );
//   }

//   /// Pin/Unpin tin nhắn
//   Future<void> togglePinMessage({
//     required String userID,
//     required String otherUserID,
//     required String messageId,
//     required bool isPinned,
//   }) async {
//     List<String> ids = [userID, otherUserID];
//     ids.sort();
//     String chatRoomID = ids.join('_');

//     await firestore
//         .collection("chat_rooms")
//         .doc(chatRoomID)
//         .collection("message")
//         .doc(messageId)
//         .update({
//           'isPinned': isPinned,
//           'pinnedAt': isPinned ? FieldValue.serverTimestamp() : null,
//           'pinnedBy': isPinned ? userID : null,
//         });
//   }

//   // ==================== SEARCH & FILTER ====================

//   /// Tìm kiếm tin nhắn theo từ khóa
//   Stream<QuerySnapshot> searchMessages({
//     required String userID,
//     required String otherUserID,
//     required String keyword,
//     MessageType? messageType,
//   }) {
//     List<String> ids = [userID, otherUserID];
//     ids.sort();
//     String chatRoomID = ids.join('_');

//     Query query = firestore
//         .collection("chat_rooms")
//         .doc(chatRoomID)
//         .collection("message")
//         .where('message', isGreaterThanOrEqualTo: keyword)
//         .where('message', isLessThanOrEqualTo: keyword + '\uf8ff')
//         .where('isDeleted', isEqualTo: false);

//     if (messageType != null) {
//       query = query.where('messageType', isEqualTo: messageType.toString());
//     }

//     return query.orderBy('timestamp', descending: true).snapshots();
//   }

//   /// Lấy tin nhắn được ghim
//   Stream<QuerySnapshot> getPinnedMessages(String userID, String otherUserID) {
//     List<String> ids = [userID, otherUserID];
//     ids.sort();
//     String chatRoomID = ids.join('_');

//     return firestore
//         .collection("chat_rooms")
//         .doc(chatRoomID)
//         .collection("message")
//         .where('isPinned', isEqualTo: true)
//         .where('isDeleted', isEqualTo: false)
//         .orderBy('pinnedAt', descending: true)
//         .snapshots();
//   }

//   // ==================== VOICE FEATURES ====================

//   /// Nhận diện giọng nói một lần
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

//   /// Gửi tin nhắn voice
//   Future<void> sendVoiceMessage({
//     required String receiverID,
//     required String audioPath,
//     required Duration duration,
//   }) async {
//     await sendMessage(
//       receiverID,
//       "Tin nhắn thoại",
//       type: MessageType.voice,
//       metadata: {'audioPath': audioPath, 'duration': duration.inSeconds},
//     );
//   }

//   // ==================== CHAT ROOM MANAGEMENT ====================

//   /// Xóa toàn bộ cuộc trò chuyện
//   Future<void> deleteChatRoom(String userID, String otherUserID) async {
//     List<String> ids = [userID, otherUserID];
//     ids.sort();
//     String chatRoomID = ids.join('_');

//     // Xóa tất cả tin nhắn
//     final messages = await firestore
//         .collection("chat_rooms")
//         .doc(chatRoomID)
//         .collection("message")
//         .get();

//     final batch = firestore.batch();
//     for (var doc in messages.docs) {
//       batch.delete(doc.reference);
//     }

//     // Xóa chat room
//     batch.delete(firestore.collection("chat_rooms").doc(chatRoomID));

//     await batch.commit();
//   }

//   /// Lấy thống kê cuộc trò chuyện
//   Future<Map<String, dynamic>> getChatStatistics(
//     String userID,
//     String otherUserID,
//   ) async {
//     List<String> ids = [userID, otherUserID];
//     ids.sort();
//     String chatRoomID = ids.join('_');

//     final messages = await firestore
//         .collection("chat_rooms")
//         .doc(chatRoomID)
//         .collection("message")
//         .where('isDeleted', isEqualTo: false)
//         .get();

//     int totalMessages = messages.docs.length;
//     int myMessages = messages.docs
//         .where((doc) => doc.data()['senderID'] == userID)
//         .length;
//     int otherMessages = totalMessages - myMessages;
//     int unreadMessages = messages.docs
//         .where(
//           (doc) =>
//               doc.data()['isRead'] == false && doc.data()['senderID'] != userID,
//         )
//         .length;

//     return {
//       'totalMessages': totalMessages,
//       'myMessages': myMessages,
//       'otherMessages': otherMessages,
//       'unreadMessages': unreadMessages,
//       'firstMessageDate': messages.docs.isNotEmpty
//           ? messages.docs.last.data()['timestamp']
//           : null,
//     };
//   }

//   // ==================== CLEANUP ====================

//   /// Dọn dẹp tài nguyên
//   void dispose() {
//     speechToText.stop();
//   }
// }
