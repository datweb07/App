import 'package:flutter/material.dart';

class Settingssreen extends StatelessWidget {
  const Settingssreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        iconTheme: IconThemeData(color: Colors.white),
      ),
    );
  }
}
