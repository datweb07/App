import 'package:flutter/material.dart';

class Textfield extends StatelessWidget {
  final String hinText;
  final bool obscureText;
  final TextEditingController controller;
  const Textfield({
    super.key,
    required this.hinText,
    required this.obscureText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 25.0),
      child: TextField(
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          fillColor: Colors.white,
          filled: true,
          hintText: hinText,
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
