import 'package:demo_nckh/services/authentication/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size s = MediaQuery.of(context).size;
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
            Positioned(
              top: s.height * .15,
              width: s.width,
              child: const LogoAnimation(),
            ),
            Positioned(
              bottom: s.height * 0.45,
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

            Positioned(
              bottom: s.height * 0.1,
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

            Positioned(
              bottom: s.height * 0.01,
              width: s.width,
              left: s.width * 0.2,
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
