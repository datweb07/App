// accessibility_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityProvider extends ChangeNotifier {
  // Private variables
  bool _highContrast = false;
  bool _largeText = false;
  bool _screenReader = true;
  bool _vibration = true;
  bool _soundEffects = true;
  double _textSize = 1.0;
  bool _voiceNavigation = false;

  // Getters
  bool get highContrast => _highContrast;
  bool get largeText => _largeText;
  bool get screenReader => _screenReader;
  bool get vibration => _vibration;
  bool get soundEffects => _soundEffects;
  double get textSize => _textSize;
  bool get voiceNavigation => _voiceNavigation;

  // Constructor - Load settings when app starts
  AccessibilityProvider() {
    _loadSettings();
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    _highContrast = prefs.getBool('highContrast') ?? false;
    _largeText = prefs.getBool('largeText') ?? false;
    _screenReader = prefs.getBool('screenReader') ?? true;
    _vibration = prefs.getBool('vibration') ?? true;
    _soundEffects = prefs.getBool('soundEffects') ?? true;
    _textSize = prefs.getDouble('textSize') ?? 1.0;
    _voiceNavigation = prefs.getBool('voiceNavigation') ?? false;
    
    notifyListeners();
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('highContrast', _highContrast);
    await prefs.setBool('largeText', _largeText);
    await prefs.setBool('screenReader', _screenReader);
    await prefs.setBool('vibration', _vibration);
    await prefs.setBool('soundEffects', _soundEffects);
    await prefs.setDouble('textSize', _textSize);
    await prefs.setBool('voiceNavigation', _voiceNavigation);
  }

  // Setters with auto-save
  void setHighContrast(bool value) {
    _highContrast = value;
    _saveSettings();
    notifyListeners();
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

  // Helper methods
  Color getTextColor(BuildContext context) {
    if (_highContrast) {
      return Theme.of(context).brightness == Brightness.dark 
          ? Colors.white 
          : Colors.black;
    }
    return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
  }

  Color getBackgroundColor(BuildContext context) {
    if (_highContrast) {
      return Theme.of(context).brightness == Brightness.dark 
          ? Colors.black 
          : Colors.white;
    }
    return Theme.of(context).scaffoldBackgroundColor;
  }

  TextStyle getTextStyle(BuildContext context, {TextStyle? baseStyle}) {
    final defaultStyle = baseStyle ?? Theme.of(context).textTheme.bodyLarge!;
    return defaultStyle.copyWith(
      fontSize: (defaultStyle.fontSize ?? 14) * _textSize,
      color: getTextColor(context),
      fontWeight: _highContrast ? FontWeight.bold : defaultStyle.fontWeight,
    );
  }
}