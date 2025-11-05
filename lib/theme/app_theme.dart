import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  // LIGHT THEME
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.grey[100],
    primaryColor: Colors.pink,
    colorScheme: ColorScheme.light(
      primary: Colors.pink,
      secondary: Colors.pinkAccent,
      surface: Colors.white,
    ),
    appBarTheme:  AppBarTheme(
      backgroundColor: AppColors.appbar,
      elevation: 0,
      foregroundColor: Colors.black87,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.grey[50],
      textStyle: TextStyle(color: Colors.blueGrey[800]),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
    ),
    iconTheme: const IconThemeData(color: Colors.grey),
    useMaterial3: true,
  );






  // DARK THEME
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    primaryColor: Colors.tealAccent[200],
    colorScheme: ColorScheme.dark(
      primary: Colors.tealAccent,
      secondary: Colors.tealAccent,
      surface: const Color(0xFF1E1E1E),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      foregroundColor: Colors.white,
      // scrolledUnderElevation: 0,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Color(0xFF2A2A2A),
      textStyle: TextStyle(color: Colors.white),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
    ),
    iconTheme: const IconThemeData(color: Colors.white60),
    useMaterial3: true,
  );
}
