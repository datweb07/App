import 'package:flutter/material.dart';

class ChangeTheme extends ChangeNotifier {
  bool isDarkMode = false;

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme(bool mode) {
    isDarkMode = mode;
    notifyListeners();
  }
}
