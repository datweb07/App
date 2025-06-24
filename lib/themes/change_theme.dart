import 'package:flutter/material.dart';

class ChangeTheme extends ChangeNotifier {
  // true là dark mode, false là light mode
  bool isDarkMode = false;

  // Getter trả về ThemeMode dựa trên trạng thái isDarkMode
  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // Hàm chuyển đổi chế độ sáng tối
  void toggleTheme(bool mode) {
    isDarkMode = mode;
    notifyListeners();
  }
}
