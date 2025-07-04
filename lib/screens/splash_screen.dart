import 'package:demo_nckh/services/authentication/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../animation/animation.dart';

// SplashScreen hiển thị màn hình đầu tiên của application
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 8), () {
      // Thoát chế độ toàn màn hình
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      // Thiết lập thanh trạng thái trong suốt
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      );
      // Điều hướng sang màn hình AuthGate
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    });
  }

  // Tạo giao diện
  @override
  Widget build(BuildContext context) {
    final Size s = MediaQuery.of(
      context,
    ).size; // Lưu biến s với kích thước màn hình
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4FC3F7),
              Color(0xFF0288D1),
            ], // Gradient từ xanh nhạt sang xanh đậm
          ),
        ),
        child: Stack(
          children: [
            // Logo với hiệu ứng
            Positioned(
              top: s.height * .15,
              width: s.width,
              child: const LogoAnimation(),
            ),
            // Tiêu đề application
            Positioned(
              bottom: s.height * 0.45, // Cách đáy 45% chiều cao màn hình
              width: s.width,
              child: Text(
                textAlign: TextAlign.center,
                "APPLICATION FOR HEARING AND VISUALLY IMPAIRED PEOPLE",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 1,
                ),
              ),
            ),
            // Thông tin liên hệ
            Positioned(
              bottom: s.height * 0.1, // Cách đáy 10% chiều cao màn hình
              width: s.width,
              child: Text(
                textAlign: TextAlign.center,
                "Please contact me if have a problem\n By email: dat82770@gmail.com",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            // Người phát triển
            Positioned(
              bottom: s.height * 0.01, // Cách đáy 1% chiều cao màn hình
              width: s.width,
              left: s.width * 0.2, // Lệch trái 20% chiều rộng màn hình
              child: Text(
                textAlign: TextAlign.center,
                "DEVELOPED BY DAT",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
