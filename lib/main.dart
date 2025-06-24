import 'package:demo_nckh/accessibility_provider.dart';
import 'package:demo_nckh/screens/splash_screen.dart';
import 'package:demo_nckh/themes/change_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Biến toàn cục lưu trữ kích thước màn hình
late Size s;

// Hàm khởi tạo
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

    // Chạy ứng dụng với ScreenUtilInit
    runApp(
      ScreenUtilInit(
        // Kích thước chuẩn mặc định
        designSize: const Size(360, 690),

        // Cho phép điều chỉnh văn bản theo tỷ lệ màn hình
        minTextAdapt: true,

        // Chia màn hình
        splitScreenMode: true,

        // Widget chính của ứng dụng
        builder: (context, child) => MultiProvider(
          providers: [
            // Quản lý sáng/tối
            ChangeNotifierProvider(create: (_) => ChangeTheme()),

            // Quản lý các cài đặt
            ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
          ],
          child: const MyApp(),
        ),
      ),
    );
  });
}

// Lớp kế thừa từ StatelessWidget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lưu kích thước màn hình hiện tại vào biến toàn cục s
    s = MediaQuery.of(context).size;

    // Sử dụng Consumer2 để truy cập vào 2 provider
    return Consumer2<ChangeTheme, AccessibilityProvider>(
      // Tạo giao diện dựa trên trạng thái của 2 provider
      builder: (context, themeProvider, accessibilityProvider, child) {
        return MaterialApp(
          title: 'Sensory Bilingualism',
          debugShowCheckedModeBanner: false, // Ẩn chữ debug
          // Dark theme
          darkTheme: ThemeData.dark().copyWith(
            // Text trong dark theme
            textTheme: ThemeData.dark().textTheme.copyWith(
              // Kiểu chữ cho văn bản lớn
              bodyLarge: TextStyle(
                fontSize: 16 * accessibilityProvider.textSize,
                color: accessibilityProvider.getTextColor(context),
                fontWeight: accessibilityProvider.highContrast
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              // Kiểu chữ cho văn bản vừa
              bodyMedium: TextStyle(
                fontSize: 14 * accessibilityProvider.textSize,
                color: accessibilityProvider.getTextColor(context),
                fontWeight: accessibilityProvider.highContrast
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
              // Kiểu chữ cho tiêu đề lớn
              titleLarge: TextStyle(
                fontSize: 20 * accessibilityProvider.textSize,
                fontWeight: FontWeight.bold,
                color: accessibilityProvider.getTextColor(context),
              ),
            ),
            // Màu nền trong dark theme
            scaffoldBackgroundColor: accessibilityProvider.getBackgroundColor(
              context,
            ),
          ),
          themeMode: themeProvider.themeMode,

          // Light theme
          theme: ThemeData(
            // Sử dụng material2
            useMaterial3: false,

            // Cài đặt độ sáng cho chủ đề
            brightness: Brightness.light,

            // Tùy chỉnh text theme
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
            // Màu nền trong chế độ sáng
            scaffoldBackgroundColor: accessibilityProvider.getBackgroundColor(
              context,
            ),
            // Thanh AppBar
            appBarTheme: AppBarTheme(
              centerTitle: true,
              // Độ nâng
              elevation: 1,
              iconTheme: IconThemeData(
                color: accessibilityProvider.highContrast
                    ? Colors.black
                    : Colors.black,
              ),
              // Kiểu chữ
              titleTextStyle: TextStyle(
                color: accessibilityProvider.getTextColor(context),
                fontWeight: FontWeight.bold,
                fontSize: 20 * accessibilityProvider.textSize,
              ),
              // Màu nền dựa vào độ tương phản (contrast)
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
                // Khoảng cách đệm cho các nút
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
            // Nhập dữ liệu
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
          // Màn hình đầu tiên khi ứng dụng khởi động
          home: SplashScreen(),
        );
      },
    );
  }
}
