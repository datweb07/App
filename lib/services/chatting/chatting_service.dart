import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_nckh/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChattingService {
  // Get instance of firestore and authentication
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Get user stream
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Go through each individual user
        final user = doc.data();
        // Return user
        return user;
      }).toList();
    });
  }

  // Get conversations stream with last message and sorting
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

            // Tìm người dùng khác trong cuộc trò chuyện
            final otherUserID = participants.firstWhere(
              (id) => id != currentUserID,
              orElse: () => "",
            );

            if (otherUserID.isNotEmpty) {
              // Lấy thông tin người dùng khác
              final userDoc = await firestore
                  .collection("Users")
                  .doc(otherUserID)
                  .get();
              if (userDoc.exists) {
                final userData = userDoc.data()!;

                // Đếm tin nhắn chưa đọc
                final unreadCount = await getUnreadMessageCount(
                  currentUserID,
                  otherUserID,
                );

                conversations.add({
                  "uid": otherUserID,
                  "email": userData["email"],
                  "photoURL": userData["photoURL"],
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

          // Sắp xếp theo thời gian tin nhắn cuối (mới nhất trước)
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

  // Send message
  Future<void> senMessage(String receiverID, message) async {
    // Get current user info
    final String currentUserID = auth.currentUser!.uid;
    final String currentUserEmail = auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // Create a new message
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    // Construct chat room id for the two users
    List<String> id = [currentUserID, receiverID];
    id.sort(); // Sort the id, ensure the chatroomID is the same for any 2 people
    String chatRoomID = id.join('_');

    // Add new message to database
    await firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("message")
        .add(newMessage.map());

    // Update chat room metadata
    await updateChatRoomMetadata(
      chatRoomID,
      currentUserID,
      receiverID,
      message,
      timestamp,
    );
  }

  // Update chat room metadata
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

  // Get messages
  Stream<QuerySnapshot> getMessage(String userID, otherUserID) {
    // Construct a chatroomID for the 2 people
    List<String> id = [userID, otherUserID];
    id.sort();
    String chatroomID = id.join('_');

    return firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("message")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(
    String currentUserID,
    String otherUserID,
  ) async {
    List<String> id = [currentUserID, otherUserID];
    id.sort();
    String chatroomID = id.join('_');

    final messages = await firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("message")
        .where("receiverID", isEqualTo: currentUserID)
        .where("isRead", isEqualTo: false)
        .get();

    for (var doc in messages.docs) {
      await doc.reference.update({"isRead": true});
    }
  }

  // Get unread message count
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

  // Update user online status
  Future<void> updateUserOnlineStatus(bool isOnline) async {
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      await firestore.collection("Users").doc(currentUser.uid).update({
        "isOnline": isOnline,
        "lastSeen": Timestamp.now(),
      });
    }
  }

  // Get last seen time for a user
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

  // Delete message
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

  // Search messages in a conversation
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
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:demo_nckh/models/message.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ChattingService {
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//   final FirebaseAuth auth = FirebaseAuth.instance;

//   // Get user stream (original method)
//   Stream<List<Map<String, dynamic>>> getUserStream() {
//     return firestore.collection("Users").snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         final user = doc.data();
//         return user;
//       }).toList();
//     });
//   }

//   // Simplified conversations stream - uses existing user data with last message info
//   Stream<List<Map<String, dynamic>>> getConversationsStream() {
//     final currentUserID = auth.currentUser?.uid;
//     if (currentUserID == null) {
//       return Stream.value([]);
//     }

//     return firestore.collection("Users").snapshots().asyncMap((snapshot) async {
//       List<Map<String, dynamic>> conversations = [];

//       for (var doc in snapshot.docs) {
//         final userData = doc.data();
//         final otherUserID = doc.id;

//         // Skip current user
//         if (otherUserID == currentUserID) continue;

//         try {
//           // Get last message between current user and this user
//           final lastMessage = await getLastMessageBetweenUsers(
//             currentUserID,
//             otherUserID,
//           );

//           if (lastMessage != null) {
//             conversations.add({
//               "uid": otherUserID,
//               "email": userData["email"] ?? "Unknown",
//               "photoURL": userData["photoURL"],
//               "isOnline": userData["isOnline"] ?? false,
//               "lastSeen": userData["lastSeen"],
//               "lastMessage": lastMessage["message"] ?? "",
//               "lastMessageTime": lastMessage["timestamp"],
//               "lastMessageSenderID": lastMessage["senderID"],
//               "unreadCount": 0, // Simplified - set to 0 for now
//             });
//           }
//         } catch (e) {
//           print("Error getting last message for user $otherUserID: $e");
//         }
//       }

//       // Sort by last message time
//       conversations.sort((a, b) {
//         final timeA = a["lastMessageTime"] as Timestamp?;
//         final timeB = b["lastMessageTime"] as Timestamp?;

//         if (timeA == null && timeB == null) return 0;
//         if (timeA == null) return 1;
//         if (timeB == null) return -1;

//         return timeB.compareTo(timeA);
//       });

//       return conversations;
//     });
//   }

//   // Get last message between two users
//   Future<Map<String, dynamic>?> getLastMessageBetweenUsers(
//     String userID1,
//     String userID2,
//   ) async {
//     try {
//       List<String> id = [userID1, userID2];
//       id.sort();
//       String chatroomID = id.join('_');

//       final querySnapshot = await firestore
//           .collection("chat_rooms")
//           .doc(chatroomID)
//           .collection("message")
//           .orderBy("timestamp", descending: true)
//           .limit(1)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         return querySnapshot.docs.first.data();
//       }
//     } catch (e) {
//       print("Error getting last message: $e");
//     }
//     return null;
//   }

//   // Send message (original method with small fix)
//   Future<void> senMessage(String receiverID, message) async {
//     try {
//       final String currentUserID = auth.currentUser!.uid;
//       final String currentUserEmail = auth.currentUser!.email!;
//       final Timestamp timestamp = Timestamp.now();

//       Message newMessage = Message(
//         senderID: currentUserID,
//         senderEmail: currentUserEmail,
//         receiverID: receiverID,
//         message: message,
//         timestamp: timestamp,
//       );

//       List<String> id = [currentUserID, receiverID];
//       id.sort();
//       String chatRoomID = id.join('_');

//       await firestore
//           .collection("chat_rooms")
//           .doc(chatRoomID)
//           .collection("message")
//           .add(newMessage.map());
//     } catch (e) {
//       print("Error sending message: $e");
//       rethrow;
//     }
//   }

//   // Get messages (original method)
//   Stream<QuerySnapshot> getMessage(String userID, otherUserID) {
//     List<String> id = [userID, otherUserID];
//     id.sort();
//     String chatroomID = id.join('_');
//     return firestore
//         .collection("chat_rooms")
//         .doc(chatroomID)
//         .collection("message")
//         .orderBy("timestamp", descending: false)
//         .snapshots();
//   }
// }
