import 'package:demo_nckh/screens/chatting_screen.dart';
import 'package:demo_nckh/screens/mode_screen.dart';
import 'package:demo_nckh/screens/object_recognition_screen.dart';
import 'package:demo_nckh/services/authentication/login_or_register.dart';
import 'package:demo_nckh/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Hiển thị loading khi đang kiểm tra trạng thái
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Nếu chưa đăng nhập, chuyển đến màn hình đăng nhập
        if (!snapshot.hasData) {
          return const LoginOrRegister(); // Thay thế bằng màn hình login của bạn
        }

        // Nếu đã đăng nhập, kiểm tra loại người dùng
        return FutureBuilder<String?>(
          future: UserService.getUserType(),
          builder: (context, userTypeSnapshot) {
            // Hiển thị loading khi đang lấy thông tin người dùng
            if (userTypeSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Color(0xFFF8FAFC),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF667EEA),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Đang tải thông tin...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Kiểm tra lỗi
            if (userTypeSnapshot.hasError) {
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Có lỗi xảy ra khi tải thông tin',
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              );
            }

            final userType = userTypeSnapshot.data;

            // Nếu chưa có loại người dùng, chuyển đến màn hình chọn chế độ
            if (userType == null || userType.isEmpty) {
              return const ModeScreen();
            }

            // Điều hướng dựa trên loại người dùng
            switch (userType) {
              case 'deaf':
                return ChattingScreen();
              case 'blind':
                return const ObjectRecognitionScreen();
              default:
                // Nếu có loại người dùng không hợp lệ, quay về màn hình chọn chế độ
                return const ModeScreen();
            }
          },
        );
      },
    );
  }
}
