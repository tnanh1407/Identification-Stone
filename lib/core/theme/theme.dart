import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// =======================================================================
//                           PHẦN DÙNG CHUNG
// =======================================================================

// --- FONT CHỮ CHUNG ---
// Dùng chung cho cả light và dark theme
final TextTheme globalTextTheme = GoogleFonts.robotoTextTheme();

// --- MÀU SẮC CHỦ ĐẠO ---
// Dùng chung cho cả hai theme để dễ quản lý
const Color primaryColor = Color(0xFF3B82F6); // Xanh dương làm màu chính
const Color errorColor = Color(0xFFEF4444); // Màu đỏ cho lỗi, sáng hơn một chút

// =======================================================================
//                               LIGHT THEME
// =======================================================================

const Color lt_secondaryColor = Color(0xFF6C757D); // Xám cho các yếu tố phụ
const Color lt_backgroundColor = Color(0xFFF8FAFC); // Màu nền chung
const Color lt_surfaceColor = Colors.white; // Màu cho các bề mặt như Card
const Color lt_onSurfaceColor = Color(0xFF1F2937); // Màu chữ/icon chính trên nền

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  // 1. LIGHT COLOR SCHEME
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryColor,
    primary: primaryColor,
    secondary: lt_secondaryColor,
    surface: lt_surfaceColor,
    background: lt_backgroundColor,
    error: errorColor,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: lt_onSurfaceColor,
    onError: Colors.white,
    brightness: Brightness.light,
  ),

  // 2. TEXT THEME (Màu chữ sáng)
  textTheme: globalTextTheme.copyWith(
    displayLarge: globalTextTheme.displayLarge?.copyWith(color: lt_onSurfaceColor),
    displayMedium: globalTextTheme.displayMedium?.copyWith(color: lt_onSurfaceColor),
    displaySmall: globalTextTheme.displaySmall?.copyWith(color: lt_onSurfaceColor),
    headlineLarge: globalTextTheme.headlineLarge?.copyWith(color: lt_onSurfaceColor),
    headlineMedium: globalTextTheme.headlineMedium?.copyWith(color: lt_onSurfaceColor, fontSize: 18, fontWeight: FontWeight.bold),
    headlineSmall: globalTextTheme.headlineSmall?.copyWith(color: lt_onSurfaceColor),
    titleLarge: globalTextTheme.titleLarge?.copyWith(color: lt_onSurfaceColor, fontSize: 20, fontWeight: FontWeight.bold),
    titleMedium: globalTextTheme.titleMedium?.copyWith(color: lt_onSurfaceColor),
    titleSmall: globalTextTheme.titleSmall?.copyWith(color: lt_onSurfaceColor),
    bodyLarge: globalTextTheme.bodyLarge?.copyWith(color: lt_onSurfaceColor, fontSize: 16),
    bodyMedium: globalTextTheme.bodyMedium?.copyWith(color: lt_onSurfaceColor.withOpacity(0.8)),
    bodySmall: globalTextTheme.bodySmall?.copyWith(color: lt_onSurfaceColor.withOpacity(0.6)),
    labelLarge: globalTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
  ),

  // 3. COMPONENT THEMES (Sáng)
  appBarTheme: AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: globalTextTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: primaryColor,
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.black.withOpacity(0.05),
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryColor, width: 2)),
    labelStyle: globalTextTheme.bodyMedium?.copyWith(color: lt_secondaryColor),
    hintStyle: globalTextTheme.bodyMedium?.copyWith(color: lt_secondaryColor),
  ),

  cardTheme: CardTheme(
    elevation: 2,
    color: lt_surfaceColor,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: lt_surfaceColor,
    selectedItemColor: primaryColor,
    unselectedItemColor: lt_secondaryColor.withOpacity(0.8),
  ),

  visualDensity: VisualDensity.adaptivePlatformDensity,
);

// =======================================================================
//                               DARK THEME
// =======================================================================

const Color dt_secondaryColor = Color(0xFFB0B0B0); // Xám nhạt hơn cho nền tối
const Color dt_backgroundColor = Color(0xFF121212); // Màu nền chuẩn của Material Design Dark
const Color dt_surfaceColor = Color(0xFF1E1E1E); // Màu cho các bề mặt như Card
const Color dt_onSurfaceColor = Color(0xFFE0E0E0); // Màu chữ/icon chính trên nền tối

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  // 1. DARK COLOR SCHEME
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryColor,
    primary: primaryColor, // Màu chính vẫn là xanh
    secondary: dt_secondaryColor,
    surface: dt_surfaceColor,
    background: dt_backgroundColor,
    error: errorColor,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: dt_onSurfaceColor, // Chữ trắng trên nền tối
    onError: Colors.white,
    brightness: Brightness.dark, // QUAN TRỌNG: Đánh dấu đây là theme tối
  ),

  // 2. TEXT THEME (Màu chữ tối)
  textTheme: globalTextTheme.copyWith(
    displayLarge: globalTextTheme.displayLarge?.copyWith(color: dt_onSurfaceColor),
    displayMedium: globalTextTheme.displayMedium?.copyWith(color: dt_onSurfaceColor),
    displaySmall: globalTextTheme.displaySmall?.copyWith(color: dt_onSurfaceColor),
    headlineLarge: globalTextTheme.headlineLarge?.copyWith(color: dt_onSurfaceColor),
    headlineMedium: globalTextTheme.headlineMedium?.copyWith(color: dt_onSurfaceColor, fontSize: 18, fontWeight: FontWeight.bold),
    headlineSmall: globalTextTheme.headlineSmall?.copyWith(color: dt_onSurfaceColor),
    titleLarge: globalTextTheme.titleLarge?.copyWith(color: dt_onSurfaceColor, fontSize: 20, fontWeight: FontWeight.bold),
    titleMedium: globalTextTheme.titleMedium?.copyWith(color: dt_onSurfaceColor),
    titleSmall: globalTextTheme.titleSmall?.copyWith(color: dt_onSurfaceColor),
    bodyLarge: globalTextTheme.bodyLarge?.copyWith(color: dt_onSurfaceColor, fontSize: 16),
    bodyMedium: globalTextTheme.bodyMedium?.copyWith(color: dt_onSurfaceColor.withOpacity(0.8)),
    bodySmall: globalTextTheme.bodySmall?.copyWith(color: dt_onSurfaceColor.withOpacity(0.6)),
    labelLarge: globalTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
  ),

  // 3. COMPONENT THEMES (Tối)
  appBarTheme: AppBarTheme(
    // AppBar trong theme tối thường có màu nền của surface để hòa lẫn
    backgroundColor: dt_surfaceColor,
    foregroundColor: dt_onSurfaceColor, // Icon và chữ trên AppBar
    elevation: 0,
    centerTitle: true,
    titleTextStyle: globalTextTheme.titleLarge?.copyWith(color: dt_onSurfaceColor, fontWeight: FontWeight.bold, fontSize: 20),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor, // Nút bấm vẫn giữ màu chính
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: primaryColor, // Nút text vẫn giữ màu chính
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    // Màu nền ô nhập liệu tối hơn một chút so với nền chung
    fillColor: Colors.white.withOpacity(0.08),
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryColor, width: 2)),
    labelStyle: globalTextTheme.bodyMedium?.copyWith(color: dt_secondaryColor),
    hintStyle: globalTextTheme.bodyMedium?.copyWith(color: dt_secondaryColor),
  ),

  cardTheme: CardTheme(
    elevation: 1, // Giảm đổ bóng trong theme tối
    color: dt_surfaceColor,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: dt_surfaceColor,
    selectedItemColor: primaryColor,
    unselectedItemColor: dt_secondaryColor.withOpacity(0.8),
  ),

  visualDensity: VisualDensity.adaptivePlatformDensity,
);
