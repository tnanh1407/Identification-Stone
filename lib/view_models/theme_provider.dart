import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum để định nghĩa các chế độ theme
enum ThemeModeOption { system, light, dark }

class ThemeProvider with ChangeNotifier {
  // Khởi tạo với chế độ mặc định là theo hệ thống
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode(); // Tải chế độ đã lưu khi khởi tạo
  }

  // Tải chế độ theme đã được người dùng lưu trước đó
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    // Đọc giá trị từ SharedPreferences, nếu chưa có thì mặc định là 'system'
    final themeString = prefs.getString('themeMode') ?? ThemeModeOption.system.name;

    // Chuyển đổi chuỗi thành enum
    _themeMode = ThemeModeOption.values
        .firstWhere(
          (e) => e.name == themeString,
          orElse: () => ThemeModeOption.system, // Dự phòng
        )
        .toThemeMode();

    notifyListeners();
  }

  // Cập nhật chế độ theme và lưu lại lựa chọn của người dùng
  Future<void> setThemeMode(ThemeModeOption modeOption) async {
    _themeMode = modeOption.toThemeMode();
    notifyListeners();

    // Lưu lựa chọn vào SharedPreferences để ghi nhớ cho lần mở app sau
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', modeOption.name);
  }
}

// Hàm mở rộng (extension) để chuyển đổi từ enum tùy chỉnh sang ThemeMode của Flutter
extension on ThemeModeOption {
  ThemeMode toThemeMode() {
    switch (this) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
      default:
        return ThemeMode.system;
    }
  }
}
