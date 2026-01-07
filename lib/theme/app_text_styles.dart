import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Hierarchy: Large -> Medium -> Small

  // Headings (Titles, AppBars)
  static const TextStyle h1 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.appbarContent,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.appbarContent,
  );

  // Body Text (Standard content)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Color(0xFF263238), // BlueGrey 900
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF455A64), // BlueGrey 700
  );

  // Captions & Labels (Secondary info, dates, kcal)
  static const TextStyle labelLarge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xFF607D8B), // BlueGrey 500
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: Color(0xFF78909C), // BlueGrey 400
  );

  // Specific UI Styles (mapping existing usages)
  static final TextStyle appBarTitle = h2;
  static final TextStyle cardTitle = bodyMedium.copyWith(fontWeight: FontWeight.w700);
  static final TextStyle cardSubTitle = labelLarge;
  static final TextStyle optionMenu = bodyMedium.copyWith(color: AppColors.optionMenuContent);
}
