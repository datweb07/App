import 'package:flutter/material.dart';
import 'package:demo_nckh/screens/settings_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../screens/mode_screen.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final FlutterTts flutterTts = FlutterTts();
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
      child: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // PHẦN TRÊN
            Column(
              children: [
                DrawerHeader(
                  child: Center(
                    child: Image.asset(
                      'images/iconApp.png',
                      width: 60,
                      height: 60,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 25.0, top: 25.0),
                  child: ListTile(
                    title: const Text(
                      "M O D E",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    leading: Icon(Icons.mode),
                    onTap: () async {
                      await flutterTts.awaitSpeakCompletion(true);
                      await flutterTts.speak("Đang vào chế độ người dùng");
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => ModeScreen()),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    title: const Text(
                      "S E T T I N G S",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    leading: Icon(Icons.settings),
                    onTap: () async {
                      await flutterTts.awaitSpeakCompletion(true);
                      await flutterTts.speak("Đang vào chế độ cài đặt");
                      Navigator.pop(context);

                      // Navigate to settings page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Settingssreen(),
                        ),
                      );
                    },
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
