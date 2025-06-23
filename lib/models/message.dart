import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  final Timestamp timestamp;
  final String messageType;
  final String? messageID; 
  final bool isRead;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp,
    required this.messageType,
    this.messageID, 
    this.isRead = false,
  });

  // Convert to map
  Map<String, dynamic> map() {
    return {
      "senderID": senderID,
      "senderEmail": senderEmail,
      "receiverID": receiverID,
      "message": message,
      "timestamp": timestamp,
      "messageType": messageType,
      "messageID": messageID,
      "isRead": isRead,
    };
  }

  // Create from map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderID: map["senderID"] ?? "",
      senderEmail: map["senderEmail"] ?? "",
      receiverID: map["receiverID"] ?? "",
      message: map["message"] ?? "",
      timestamp: map["timestamp"] ?? Timestamp.now(),
      messageType: map["messageType"] ?? "text",
      messageID: map["messageID"],
      isRead: map["isRead"] ?? false,
    );
  }
}
