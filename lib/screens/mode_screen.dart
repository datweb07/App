import 'package:demo_nckh/authentication/auth_service.dart';
import 'package:demo_nckh/screens/chatting_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // thêm dòng này
import '../animation/animation.dart';
import '../authentication/auth_gate.dart'; // đảm bảo có file này để quay lại sau khi sign out
import 'speak_screen.dart';

class ModeScreen extends StatefulWidget {
  const ModeScreen({super.key});

  @override
  State<ModeScreen> createState() => _ModeScreenState();
}

class _ModeScreenState extends State<ModeScreen> {
  void logout() {
    // Get auth service
    final _auth = AuthService();
    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final Size s = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.blue,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              const BoxShadow(
                color: Colors.grey,
                offset: Offset(2, 2),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Text(
            "WELCOME TO CHATTING",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Logout button
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sign out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthGate()),
                (route) => false,
              );
            },
          ),
        ],
        // actions: [
        //   // Logout button
        //   IconButton(onPressed: logout, icon: Icon(Icons.logout)),
        // ],
      ),

      body: Stack(
        children: [
          Positioned(
            top: s.height * .15,
            width: s.width,
            child: const LogoAnimation(),
          ),
          Positioned(
            bottom: s.height * 0.10,
            width: s.width * 0.9,
            height: s.height * 0.06,
            left: s.width * 0.05,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue.shade300,
                shape: const StadiumBorder(),
                elevation: 1,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SpeakScreen()),
                );
              },
              icon: Image.asset('images/eyes.png', height: s.height * 0.05),
              label: const Text(
                'Visually Impaired People',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: s.height * 0.20,
            width: s.width * 0.9,
            height: s.height * 0.06,
            left: s.width * 0.05,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue.shade300,
                shape: const StadiumBorder(),
                elevation: 1,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ChattingScreen()),
                );
              },
              icon: Image.asset('images/ear.png', height: s.height * 0.05),
              label: const Text(
                'Hearing Impaired People',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
