import 'package:demo_nckh/accessibility_provider.dart';
import 'package:demo_nckh/screens/splash_screen.dart';
import 'package:demo_nckh/themes/change_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

    // Chạy ứng dụng với MultiProvider thay vì ChangeNotifierProvider đơn lẻ
    runApp(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ChangeTheme()),
            ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
          ],
          child: const MyApp(),
        ),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    s = MediaQuery.of(context).size;

    return Consumer2<ChangeTheme, AccessibilityProvider>(
      builder: (context, themeProvider, accessibilityProvider, child) {
        return MaterialApp(
          title: 'Sensory Bilingualism',
          debugShowCheckedModeBanner: false,

          darkTheme: ThemeData.dark().copyWith(
            // Áp dụng accessibility settings cho dark theme
            textTheme: ThemeData.dark().textTheme.copyWith(
              bodyLarge: TextStyle(
                fontSize: 16 * accessibilityProvider.textSize,
                color: accessibilityProvider.getTextColor(context),
                fontWeight: accessibilityProvider.highContrast
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              bodyMedium: TextStyle(
                fontSize: 14 * accessibilityProvider.textSize,
                color: accessibilityProvider.getTextColor(context),
                fontWeight: accessibilityProvider.highContrast
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
              titleLarge: TextStyle(
                fontSize: 20 * accessibilityProvider.textSize,
                fontWeight: FontWeight.bold,
                color: accessibilityProvider.getTextColor(context),
              ),
            ),
            scaffoldBackgroundColor: accessibilityProvider.getBackgroundColor(
              context,
            ),
          ),
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            useMaterial3: false,
            brightness: Brightness.light,
            // Áp dụng accessibility settings cho light theme
            textTheme: ThemeData.light().textTheme.copyWith(
              bodyLarge: TextStyle(
                fontSize: 16 * accessibilityProvider.textSize,
                color: accessibilityProvider.getTextColor(context),
                fontWeight: accessibilityProvider.highContrast
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              bodyMedium: TextStyle(
                fontSize: 14 * accessibilityProvider.textSize,
                color: accessibilityProvider.getTextColor(context),
                fontWeight: accessibilityProvider.highContrast
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
              titleLarge: TextStyle(
                fontSize: 20 * accessibilityProvider.textSize,
                fontWeight: FontWeight.bold,
                color: accessibilityProvider.getTextColor(context),
              ),
            ),
            scaffoldBackgroundColor: accessibilityProvider.getBackgroundColor(
              context,
            ),
            appBarTheme: AppBarTheme(
              centerTitle: true,
              elevation: 1,
              iconTheme: IconThemeData(
                color: accessibilityProvider.highContrast
                    ? Colors.black
                    : Colors.black,
              ),
              titleTextStyle: TextStyle(
                color: accessibilityProvider.getTextColor(context),
                fontWeight: FontWeight.bold,
                fontSize: 20 * accessibilityProvider.textSize,
              ),
              backgroundColor: accessibilityProvider.highContrast
                  ? (themeProvider.isDarkMode ? Colors.black : Colors.white)
                  : null,
            ),
            // Cải thiện độ tương phản cho các components khác
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(
                  fontSize: 16 * accessibilityProvider.textSize,
                  fontWeight: accessibilityProvider.highContrast
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 24 * accessibilityProvider.textSize,
                  vertical: 12 * accessibilityProvider.textSize,
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: TextStyle(
                  fontSize: 16 * accessibilityProvider.textSize,
                  fontWeight: accessibilityProvider.highContrast
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              labelStyle: TextStyle(
                fontSize: 16 * accessibilityProvider.textSize,
                color: accessibilityProvider.getTextColor(context),
              ),
              hintStyle: TextStyle(
                fontSize: 14 * accessibilityProvider.textSize,
                color: accessibilityProvider
                    .getTextColor(context)
                    .withOpacity(0.6),
              ),
              border: accessibilityProvider.highContrast
                  ? OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    )
                  : null,
            ),
          ),
          home: SplashScreen(),
        );
      },
    );
  }
}
