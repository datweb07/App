import 'package:demo_nckh/authentication/login_or_register.dart';
import 'package:demo_nckh/screens/chatting_screen.dart';
import 'package:demo_nckh/screens/identify/login_screen.dart';
import 'package:demo_nckh/screens/mode_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../main.dart';
import '../../animation/animation.dart';

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
      // Exit full screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginOrRegister()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    s = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: s.height * .15,
            width: s.width,
            child: const LogoAnimation(),
          ),
          Positioned(
            bottom: s.height * 0.3,
            width: s.width,
            child: Text(
              textAlign: TextAlign.center,
              "MADE BY DAT >.<\nTHANK YOU FOR EVERYONE",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
