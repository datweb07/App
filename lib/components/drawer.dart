import 'package:flutter/material.dart';
import 'package:demo_nckh/screens/settings_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../screens/mode_screen.dart';

// Tạo lớp MyDrawer để tạo thanh menu bên trái thiết bị
class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  // Method tạo giao diện
  @override
  Widget build(BuildContext context) {
    final FlutterTts flutterTts =
        FlutterTts(); // Khởi tạo đối tượng TextToSpeech
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ), // Bo góc
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
                      await flutterTts.awaitSpeakCompletion(
                        true,
                      ); // Chờ hoàn thành TTS
                      await flutterTts.speak(
                        "Đang vào chế độ người dùng",
                      ); // Đọc thông báo
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ModeScreen(),
                        ), // Chuyển sang ModeScreen
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

                      // Chuyển sang SettingScreen
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
