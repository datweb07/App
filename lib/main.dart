import 'package:demo_nckh/authentication/login_or_register.dart';
import 'package:demo_nckh/components/drawer.dart';
import 'package:demo_nckh/screens/identify/login_screen.dart';
import 'package:demo_nckh/screens/identify/register_screen.dart';
import 'package:demo_nckh/screens/mode_screen.dart';
import 'package:demo_nckh/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

late Size s;
Future<void> main() async {
  // Khởi tạo binding của Flutter (bắt buộc nếu dùng async trong main)
  WidgetsFlutterBinding.ensureInitialized();

  // Full Screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // For setting orientation to portrait only (hiểu là cho phép full screen ở màn hình đầu, còn những màn hình lúc sau thì vẫn thấy các thông báo phía trên)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) async {
    // Đợi Firebase khởi tạo xong
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Chạy ứng dụng
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            // color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
