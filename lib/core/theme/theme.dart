import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  colorScheme: ColorScheme.light(
      primary: Color(0xFF60A5FA),
      secondary: Colors.grey,
      onSurface: Color(0xFFF7F7F7),
      onError: Colors.red,
      onPrimary: Colors.black87,
      surface: Color(0xFFF7F7F7), //background
      tertiary: Colors.black87,
      tertiaryFixed: Colors.grey[600], // màu icon
      tertiaryFixedDim: Colors.grey.shade200), // màu của background input),
  textTheme: TextTheme(
    //text cho appBar
    titleLarge: GoogleFonts.roboto(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    //Text cho các tên các function
    titleMedium: GoogleFonts.roboto(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
    //Text cho các function chuyển nội dụng
    titleSmall: GoogleFonts.roboto(
      fontSize: 16,
      color: Colors.black87,
    ),
    //Text ở thẻ chi tiết trong news
    displaySmall: GoogleFonts.roboto(
      fontSize: 16,
      color: Colors.black87,
      fontWeight: FontWeight.bold,
    ),
    // Hiển thị nội dung trong username ở infopage
    bodyLarge: GoogleFonts.roboto(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
    // Hiển thị label nội dung trong thẻ card home_page
    bodyMedium: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.blue,
    ),
    // Hiển thị nội dung trong thẻ card home_page
    bodySmall: GoogleFonts.roboto(
      fontSize: 14,
      color: Colors.black87,
    ),
    //  text theme cho button phông chữ trắng
    labelSmall: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    //  text của input  nhập
    labelMedium: GoogleFonts.poppins(
      fontSize: 14,
      color: Colors.grey[600],
    ),
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
