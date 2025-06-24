import 'package:flutter/material.dart';

// Tạo lớp Button kế thừa từ StatelessWidget để tạo nút
class Button extends StatelessWidget {
  final void Function()? onTap; // Hàm callback khi nhấn nút (có thể null)
  final String text;
  const Button({super.key, required this.text, required this.onTap});

  // Method tạo giao diện cho nút
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Gắn hàm callback khi user nhấn vào nút
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary, // Màu nền từ theme
          borderRadius: BorderRadius.circular(8), // Bo góc
        ),
        padding: const EdgeInsets.all(25), // Khoảng cách bên trong nút
        margin: const EdgeInsets.symmetric(
          horizontal: 25,
        ), // Khoảng cách bên ngoài theo chiều ngang
        child: Center(
          child: Text(
            text, // Hiển thị văn bản của nút
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
