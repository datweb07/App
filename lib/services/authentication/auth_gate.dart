import 'package:demo_nckh/services/authentication/login_or_register.dart';
import 'package:demo_nckh/screens/mode_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // check user logged in
          if (snapshot.hasData) {
            return ModeScreen();
          }
          // check user isnot logged in
          else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder<User?>(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasData) {
//             return const ModeScreen();
//           } else {
//             return const LoginOrRegister();
//           }
//         },
//       ),
//     );
//   }
}
