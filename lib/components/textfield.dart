import 'package:flutter/material.dart';

// Tạo Textfield để nhập dữ liệu
class Textfield extends StatelessWidget {
  final String hinText; // Văn bản gợi ý
  final bool obscureText; // Ẩn nội dung (password)
  final TextEditingController controller;
  const Textfield({
    super.key,
    required this.hinText,
    required this.obscureText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(
        horizontal: 25.0,
      ), // Khoảng cách ngang
      child: TextField(
        obscureText: obscureText, // Ẩn nội dung nếu là password
        controller: controller,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.tertiary, // Màu viền khi không focus
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.primary, // Màu viền khi focus
            ),
          ),
          fillColor: Colors.white, // Màu nền của input
          filled: true, // Kích hoạt màu nền
          hintText: hinText, // Văn bản gợi ý
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
