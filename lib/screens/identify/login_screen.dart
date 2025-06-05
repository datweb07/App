import 'package:demo_nckh/screens/home_screen.dart';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../animation/animation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    s = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        255,
        255,
        255,
      ), // Toàn bộ giao diện
      appBar: AppBar(
        centerTitle: true,
        elevation: 4,
        backgroundColor: const Color.fromARGB(
          255,
          255,
          255,
          255,
        ), // Màu nền của App bar
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue[100], // màu nền nổi
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: const Offset(2, 2),
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
      ),

      body: Stack(
        children: [
          // Positioned(
          //   top: s.height * .15,
          //   width: s.width * .5,
          //   left: s.width * .25,
          //   child: Image.asset('images/iconApp.png'),
          // ),
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
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                );
              },
              icon: Image.asset('images/eyes.png', height: s.height * 0.05),
              label: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [TextSpan(text: 'Visually Impaired People')],
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
              onPressed: () {},
              icon: Image.asset('images/ear.png', height: s.height * 0.05),
              label: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [TextSpan(text: 'Hearing Impaired People')],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
