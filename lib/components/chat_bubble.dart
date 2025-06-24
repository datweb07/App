import 'package:flutter/material.dart';

// Tạo lớp ChatBubble để hiển thị đoạn chat trong màn hình chatting
class ChatBubble extends StatelessWidget {
  final String message; // Nội dung
  final bool isCurrentUser; // Xác định tin nhắn từ người dùng hiện tại
  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  // Method tạo giao diện nhắn tin
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Màu xanh cho người gửi, xám cho người nhận
        color: isCurrentUser ? Colors.green : Colors.grey.shade500,
        borderRadius: BorderRadius.circular(12), // Bo góc
      ),
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 25),
      child: Text(message, style: TextStyle(color: Colors.white)),
    );
  }
}
