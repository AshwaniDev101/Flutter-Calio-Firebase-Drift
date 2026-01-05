import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // Common Text Styles that follow Material 3 naming
  static TextTheme _textTheme(Color textColor) => TextTheme(
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor.withValues(alpha: 0.8),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: textColor.withValues(alpha: 0.6),
        ),
        labelSmall: TextStyle(
          fontSize: 8,
          color: textColor.withValues(alpha: 0.8),
        ),
      );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: Colors.white,
      onSurface: AppColors.appbarContent,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.appbar,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.appbarContent,
      ),
      iconTheme: const IconThemeData(color: AppColors.appbarContent),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: AppColors.optionMenuBackground,
      surfaceTintColor: Colors.transparent,
    ),
    textTheme: _textTheme(Colors.black87),
    iconTheme: IconThemeData(color: Colors.blueGrey[700]),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    primaryColor: AppColors.secondary,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.secondary,
      secondary: AppColors.primary,
      surface: Color(0xFF1E1E1E),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    textTheme: _textTheme(Colors.white),
  );
}
