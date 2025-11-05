import 'package:flutter/material.dart';

class AppColors {
  // Color Palette
  static const Color primary = Color(0xFFFFA4A4);
  static const Color secondary = Color(0xFF70B2B2);
  static const Color third = Color(0xFF9ECFD4);
  static const Color fourth = Color(0xFFE5E9C5);

  // App bar
  static Color appbar = Colors.grey[100]!;

  // Value for Colors.blueGrey.shade50
  static Color appbarContent = Color(0xFF546E7A);

  // static const Color appbarContent = Color(0xFFECEFF1);

  static Color backgroundColor = Colors.grey[100]!;
  static Color slideUpPanelColor = Colors.grey[100]!;

  // Option Menu
  // Value for Colors.grey.shade50
  static const Color optionMenuBackground = Color(0xFFFAFAFA);

  // Value for Colors.blueGrey.shade600
  static const Color optionMenuContent = Color(0xFF546E7A);

  static const List<Color> colorPalette = [
    Color(0xFFF8BBD0),
    Color(0xFFBBDEFB),
    Color(0xFFC8E6C9),
    Color(0xFFE1BEE7),
    Color(0xFFB2DFDB),
    Color(0xFFFFECB3),
    Color(0xFFFFE0B2),
    Color(0xFFC5CAE9),
    Color(0xFFB2EBF2),
    Color(0xFFFFCDD2),
    Color(0xFFDCEDC8),
    Color(0xFFFFF9C4),
    Color(0xFFD1C4E9),
    Color(0xFFB3E5FC),
    Color(0xFFFFCCBC),
    Color(0xFFE6EE9C),
    Color(0xFFCFD8DC),
    Color(0xFFF3E5F5),
    Color(0xFFEF9A9A),
    Color(0xFFBCAAA4),
    Color(0xFFFFF3E0),
    Color(0xFFA1887F),
    Color(0xFF8D6E63),
    Color(0xFF6D4C41),
    Color(0xFFFFE082),
    Color(0xFFFFCC80),
    Color(0xFFD7CCC8),
    Color(0xFFFF5252),
    Color(0xFFFFA726),
    Color(0xFFFFEB3B),
    Color(0xFF26C6DA),
    Color(0xFF66BB6A),
    Color(0xFF7E57C2),
    Color(0xFF29B6F6),
    Color(0xFFEC407A),
    Color(0xFFAB47BC),
  ];
}

class AppTextStyle {
  // Option Menu
  static final TextStyle optionMenuTextStyle = TextStyle(fontSize: 14, color: AppColors.optionMenuContent);
  static final TextStyle appBarTextStyle =
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.appbarContent);



  // Card Text Style -- Calorie Counter
  static final TextStyle textStyleCardTitle = TextStyle(
    fontSize: 14, // more readable on mobile
    color: Colors.blueGrey[800],
    fontWeight: FontWeight.w600,
  );

  static final TextStyle textStyleCardSubTitle = TextStyle(
    fontSize: 12,
    color: Colors.grey[600],
    fontWeight: FontWeight.w400,
  );
}
