import 'package:demo_nckh/authentication/auth_service.dart';
import 'package:demo_nckh/components/button.dart';
import 'package:demo_nckh/components/textfield.dart';
import 'package:demo_nckh/screens/identify/login_screen.dart';
import 'package:demo_nckh/screens/mode_screen.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Go to RegisterScreen
  final void Function()? onTap;
  RegisterScreen({super.key, required this.onTap});

  void register() {
    // Get auth service
    final _auth = AuthService();
    _auth.signUpWithEmailPassword(
      _emailController.text,
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Icon(
              Icons.message,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 50),
            // Text
            Text(
              "Let's create an account",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),

            // Email
            Textfield(
              hinText: "Email",
              obscureText: false,
              controller: _emailController,
            ),

            const SizedBox(height: 10),

            // Password
            Textfield(
              hinText: "Password",
              obscureText: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 25),

            // Button register
            Button(text: "Register", onTap: register),

            // Button(
            //   text: "Register",
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => LoginScreen(onTap: () {}),
            //       ),
            //     );
            //   },
            // ),
            const SizedBox(height: 25),

            // Register
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: TextStyle(color: Colors.black, fontSize: 17),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    "Login now",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
