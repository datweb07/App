import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID; // ID người gửi
  final String senderEmail; // Email người gửi
  final String receiverID; // ID người nhận
  final String message; // Nội dung tin nhắn
  final Timestamp timestamp; // Thời gian gửi tin
  final String messageType; // Loại tin (text, image)
  final String? messageID; // ID tin nhắn (có thể null)
  final bool isRead; // Trạng thái tin nhắn (read or unread)

  // Constructor
  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp,
    required this.messageType,
    this.messageID,
    this.isRead = false, // Mặc định là chưa đọc
  });

  // Chuyển đổi đối tượng Message thành Map để lưu vào firestore
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

  // Tạo đối tượng Message từ Map
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
