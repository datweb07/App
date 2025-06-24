import 'package:demo_nckh/screens/identify/login_screen.dart';
import 'package:demo_nckh/screens/identify/register_screen.dart';
import 'package:flutter/material.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  // Khởi tạo màn hình login
  bool showLoginScreen = true;

  // Chuyển đổi giữa hai màn hình đăng nhập và đăng ký
  void toggle() {
    setState(() {
      showLoginScreen = !showLoginScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginScreen) {
      return LoginScreen(onTap: toggle);
    } else {
      return RegisterScreen(onTap: toggle);
    }
  }
}
