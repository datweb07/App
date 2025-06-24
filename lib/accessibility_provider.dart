import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Lớp quản lý các cài đặt hỗ trợ tiếp cận
class AccessibilityProvider extends ChangeNotifier {
  // Private variables
  bool _highContrast = false;
  bool _largeText = false;
  bool _screenReader = true;
  bool _vibration = true; // Rung thiết bị
  bool _soundEffects = true; // Hiệu ứng âm thanh
  double _textSize = 1.0;
  bool _voiceNavigation = false; // Điều hướng bằng giọng nói

  // Getters
  bool get highContrast => _highContrast;
  bool get largeText => _largeText;
  bool get screenReader => _screenReader;
  bool get vibration => _vibration;
  bool get soundEffects => _soundEffects;
  double get textSize => _textSize;
  bool get voiceNavigation => _voiceNavigation;

  // Constructor - Tải lại các settings khi khởi động lại app
  AccessibilityProvider() {
    _loadSettings();
  }

  // Tải lại cài đặt từ SharedPreferences (bộ nhớ cục bộ)
  Future<void> _loadSettings() async {
    // Khởi tạo biến để sử dụng bộ nhớ cục bộ
    final prefs = await SharedPreferences.getInstance();

    // Tải lại các cài đặt từ bộ nhớ cục bộ, nếu không đổi thì sử dụng cài đặt mặc định
    _highContrast = prefs.getBool('highContrast') ?? false;
    _largeText = prefs.getBool('largeText') ?? false;
    _screenReader = prefs.getBool('screenReader') ?? true;
    _vibration = prefs.getBool('vibration') ?? true;
    _soundEffects = prefs.getBool('soundEffects') ?? true;
    _textSize = prefs.getDouble('textSize') ?? 1.0;
    _voiceNavigation = prefs.getBool('voiceNavigation') ?? false;

    // Thông báo cho các widget sử dụng provider rằng trạng thái đã thay đổi
    notifyListeners();
  }

  // Lưu cài đặt vào SharedPreferences
  Future<void> _saveSettings() async {
    // Khởi tạo biến để lưu dữ liệu
    final prefs = await SharedPreferences.getInstance();

    // Lưu các cài đặt vào SharedPreferences
    await prefs.setBool('highContrast', _highContrast);
    await prefs.setBool('largeText', _largeText);
    await prefs.setBool('screenReader', _screenReader);
    await prefs.setBool('vibration', _vibration);
    await prefs.setBool('soundEffects', _soundEffects);
    await prefs.setDouble('textSize', _textSize);
    await prefs.setBool('voiceNavigation', _voiceNavigation);
  }

  // Setters để cập nhật giá trị của cài đặt và tự động lưu
  void setHighContrast(bool value) {
    _highContrast = value; // Gán giá trị mới
    _saveSettings(); // Lưu vào SharedPreferences
    notifyListeners(); // Thông báo thay đổi trạng thái
  }

  void setLargeText(bool value) {
    _largeText = value;
    _saveSettings();
    notifyListeners();
  }

  void setScreenReader(bool value) {
    _screenReader = value;
    _saveSettings();
    notifyListeners();
  }

  void setVibration(bool value) {
    _vibration = value;
    _saveSettings();
    notifyListeners();
  }

  void setSoundEffects(bool value) {
    _soundEffects = value;
    _saveSettings();
    notifyListeners();
  }

  void setTextSize(double value) {
    _textSize = value;
    _saveSettings();
    notifyListeners();
  }

  void setVoiceNavigation(bool value) {
    _voiceNavigation = value;
    _saveSettings();
    notifyListeners();
  }

  // Lấy màu dựa trên độ tương phản
  Color getTextColor(BuildContext context) {
    if (_highContrast) {
      return Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black;
    }
    // Trả về màu văn bản mặc định nếu không bật chế độ tương phản
    return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
  }

  // Màu nền dựa trên chế độ tương phản
  Color getBackgroundColor(BuildContext context) {
    if (_highContrast) {
      return Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white;
    }
    // Trả về màu nền mặc định nếu không bật chế độ tương phản
    return Theme.of(context).scaffoldBackgroundColor;
  }

  // Tạo kiểu văn bản
  TextStyle getTextStyle(BuildContext context, {TextStyle? baseStyle}) {
    final defaultStyle = baseStyle ?? Theme.of(context).textTheme.bodyLarge!;
    return defaultStyle.copyWith(
      fontSize: (defaultStyle.fontSize ?? 14) * _textSize,
      color: getTextColor(context),
      fontWeight: _highContrast ? FontWeight.bold : defaultStyle.fontWeight,
    );
  }
}
