import 'package:flutter/material.dart';
import 'package:rock_classifier/core/theme/theme.dart';

class ThemeProvider with ChangeNotifier {
  bool _isPrimary = true;
  bool get isPrimary => _isPrimary;

  // ThemeData get themeData => _isPrimary ? lightTheme : darkTheme;
  ThemeData get themeData => lightTheme;
  void toggleTheme() {
    _isPrimary = !_isPrimary;
    notifyListeners();
  }
}
