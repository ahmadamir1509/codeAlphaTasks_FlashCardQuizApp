import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../utils/constants.dart';

class ThemeProvider extends ChangeNotifier {
  final Box _settingsBox = Hive.box(AppConstants.settingsBox);

  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  void _loadTheme() {
    final saved = _settingsBox.get('themeMode', defaultValue: 'system');
    _themeMode = _stringToThemeMode(saved);
    notifyListeners();
  }

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    _settingsBox.put('themeMode', _themeModeToString(mode));
    notifyListeners();
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode _stringToThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}