import 'package:flutter/material.dart';
import 'package:habit_tracker/theme/theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightMode;
  ThemeData get themeData => _themeData;
  set themeData(ThemeData theme) {
    _themeData = theme;
    notifyListeners();
  }

  bool get isDarkMode => _themeData == darkMode;
  void toggle() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
