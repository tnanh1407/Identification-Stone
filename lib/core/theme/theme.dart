import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- MÀU SẮC CHỦ ĐẠO ---
// Định nghĩa các màu sắc chính ở đây để dễ dàng thay đổi và tái sử dụng.
const Color primaryColor = Color(0xFF3B82F6); // Xanh dương làm màu chính
const Color secondaryColor = Color(0xFF6C757D); // Xám cho các yếu tố phụ
const Color backgroundColor = Color(0xFFF8FAFC); // Màu nền chung
const Color surfaceColor = Colors.white; // Màu cho các bề mặt như Card, Dialog
const Color errorColor = Colors.redAccent;
const Color onPrimaryColor = Colors.white; // Màu chữ/icon trên nền màu chính
const Color onSurfaceColor = Color(0xFF1F2937); // Màu chữ/icon chính trên nền

// --- FONT CHỮ CHUNG ---
// Dùng một font chữ chính để đảm bảo tính nhất quán.
final TextTheme globalTextTheme = GoogleFonts.robotoTextTheme();

// --- THEME HOÀN CHỈNH ---
final ThemeData lightTheme = ThemeData(
  // Bật Material 3
  useMaterial3: true,

  // 1. DÙNG COLOR SCHEME ĐÚNG CHUẨN
  // Xây dựng bảng màu từ một màu gốc. Flutter sẽ tự tạo các màu khác một cách hài hòa.
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryColor,
    primary: primaryColor,
    secondary: secondaryColor,
    surface: surfaceColor,
    background: backgroundColor,
    error: errorColor,
    onPrimary: onPrimaryColor, // Chữ/icon trên nền primary (VD: trong ElevatedButton)
    onSecondary: Colors.white,
    onSurface: onSurfaceColor, // Chữ/icon chính của app
    onError: Colors.white,
    brightness: Brightness.light,
  ),

  // 2. ĐỊNH NGHĨA TEXT THEME TỔNG QUÁT
  // Áp dụng font chữ chung và chỉ tinh chỉnh màu sắc cơ bản.
  textTheme: globalTextTheme.copyWith(
    // Dùng cho các tiêu đề lớn (ví dụ: title của AppBar)
    displayLarge: globalTextTheme.displayLarge?.copyWith(color: onSurfaceColor),
    displayMedium: globalTextTheme.displayMedium?.copyWith(color: onSurfaceColor),
    displaySmall: globalTextTheme.displaySmall?.copyWith(color: onSurfaceColor),

    // Dùng cho các tiêu đề nhỏ hơn
    headlineLarge: globalTextTheme.headlineLarge?.copyWith(color: onSurfaceColor),
    headlineMedium: globalTextTheme.headlineMedium?.copyWith(color: onSurfaceColor, fontSize: 18, fontWeight: FontWeight.bold), // Ví dụ: tiêu đề các function
    headlineSmall: globalTextTheme.headlineSmall?.copyWith(color: onSurfaceColor),

    // Dùng cho tiêu đề trong các widget như ListTile, Card
    titleLarge: globalTextTheme.titleLarge?.copyWith(color: onSurfaceColor, fontSize: 20, fontWeight: FontWeight.bold),
    titleMedium: globalTextTheme.titleMedium?.copyWith(color: onSurfaceColor),
    titleSmall: globalTextTheme.titleSmall?.copyWith(color: onSurfaceColor),

    // Dùng cho các đoạn văn bản chính trong ứng dụng
    bodyLarge: globalTextTheme.bodyLarge?.copyWith(color: onSurfaceColor, fontSize: 16),
    bodyMedium: globalTextTheme.bodyMedium?.copyWith(color: onSurfaceColor.withOpacity(0.8)), // Màu chữ phụ
    bodySmall: globalTextTheme.bodySmall?.copyWith(color: onSurfaceColor.withOpacity(0.6)),

    // Dùng cho các label của button, caption
    labelLarge: globalTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold), // Chữ trong Button
    labelMedium: globalTextTheme.labelMedium?.copyWith(color: onSurfaceColor.withOpacity(0.8)),
    labelSmall: globalTextTheme.labelSmall?.copyWith(color: onSurfaceColor.withOpacity(0.6)),
  ),

  // 3. TÙY BIẾN CÁC THÀNH PHẦN UI CỤ THỂ
  // Đây là cách làm mạnh mẽ và đúng đắn nhất để tùy biến app.

  // --- AppBar Theme ---
  appBarTheme: AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: onPrimaryColor, // Màu cho icon (BackButton, actions) và title
    elevation: 0,
    centerTitle: true,
    titleTextStyle: globalTextTheme.titleLarge?.copyWith(
      color: onPrimaryColor,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),

  // --- ElevatedButton Theme ---
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: onPrimaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      textStyle: globalTextTheme.labelLarge?.copyWith(color: onPrimaryColor),
    ),
  ),

  // --- TextButton Theme ---
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: primaryColor,
      textStyle: globalTextTheme.labelLarge,
    ),
  ),

  // --- InputDecoration Theme (cho TextFormField, TextField) ---
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.black.withOpacity(0.05),
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    labelStyle: globalTextTheme.bodyMedium?.copyWith(color: secondaryColor),
    hintStyle: globalTextTheme.bodyMedium?.copyWith(color: secondaryColor),
  ),

  // --- Card Theme ---
  cardTheme: CardTheme(
    elevation: 2,
    color: surfaceColor,
    surfaceTintColor: Colors.transparent, // Ngăn Card bị ám màu primary
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  visualDensity: VisualDensity.adaptivePlatformDensity,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: surfaceColor, // Màu nền của thanh điều hướng
    elevation: 8.0, // Đổ bóng mặc định
    selectedItemColor: primaryColor, // Màu của item được chọn
    unselectedItemColor: secondaryColor.withOpacity(0.8), // Màu của item không được chọn
    type: BottomNavigationBarType.fixed, // Luôn hiển thị label
    showSelectedLabels: true,
    showUnselectedLabels: true,
    selectedLabelStyle: globalTextTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
    unselectedLabelStyle: globalTextTheme.labelSmall,
  ),
);

final ThemeData darkTheme = ThemeData(
  textTheme: GoogleFonts.robotoTextTheme(),
  useMaterial3: true,
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shadowColor: Colors.amber,
      backgroundColor: Color(0xffE57C3B),
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(25.0),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 1),
      borderRadius: BorderRadius.all(
        Radius.circular(25.0),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2),
      borderRadius: BorderRadius.all(
        Radius.circular(25.0),
      ),
    ),
  ),
);
