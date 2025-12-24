import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/week_stats.dart';

class AppColors {
  // Primary Branding
  static const Color primary = Color(0xFFFFA4A4);
  static const Color secondary = Color(0xFF70B2B2);
  static const Color third = Color(0xFF9ECFD4);
  static const Color fourth = Color(0xFFE5E9C5);

  // Surface & Backgrounds
  static final Color appbar = Colors.grey[100]!;
  static final Color backgroundColor = Colors.grey[100]!;
  static final Color slideUpPanelColor = Colors.grey[100]!;
  static const Color optionMenuBackground = Color(0xFFFAFAFA);

  // Content & Icons
  static const Color appbarContent = Color(0xFF546E7A);
  static const Color optionMenuContent = Color(0xFF546E7A);



  // Calorie Bar Specific Colors
  static const Color calorieBarUnder = Color(0xFF504D4D);
  static const Color calorieBarSuccess = Color(0xFF6BCF9D); //Color(0xFF10DA48);
  static const Color calorieBarWarning = Color(0xFFFFD166); //Color(0xFFFFC107); // Colors.amber
  static const Color calorieBarDanger = Color(0xFFFF6B6B);
  static const Color calorieBarBackground = Color(0xFFECEFF1);


  // Calorie Bar Colors (Refined)
// Calorie Bar – Premium Health Palette
//   static const Color calorieBarUnder = Color(0xFF5B8DEF);   // Cool Indigo Blue
//   static const Color calorieBarSuccess = Color(0xFF2EC4B6); // Fresh Teal (not green)
//   static const Color calorieBarWarning = Color(0xFFFFB703); // Golden Amber
//   static const Color calorieBarDanger = Color(0xFFE63946);  // Strong Coral Red
//   static const Color calorieBarBackground = Color(0xFFF1F5F9);



  // Heatmap Colors
  static const Color heatmapNeutral = calorieBarUnder;  //Color(0xFF504D4D);
  static const Color heatmapTransition = calorieBarSuccess;//Color(0xFF6BCF9D);
  static const Color heatmapOptimal = calorieBarWarning;//Color(0xFFFFD166);
  static const Color heatmapOver = calorieBarDanger;//Color(0xFFFF6B6B);//Color(0xFFEF476F);
  static const Color heatmapEmpty = calorieBarBackground;//Color(0xFFEBEDF0);

  // Status Colors (Generic)
  static const Color success = Color(0xFF6EDE8A);
  static const Color warning = Color(0xFFFFE66D);
  static const Color danger = Color(0xFFFF6B6B);
  
  // Dynamic Color Palette
  static const List<Color> colorPalette = [
    Color(0xFFF8BBD0), Color(0xFFBBDEFB), Color(0xFFC8E6C9), Color(0xFFE1BEE7),
    Color(0xFFB2DFDB), Color(0xFFFFECB3), Color(0xFFFFE0B2), Color(0xFFC5CAE9),
    Color(0xFFB2EBF2), Color(0xFFFFCDD2), Color(0xFFDCEDC8), Color(0xFFFFF9C4),
    Color(0xFFD1C4E9), Color(0xFFB3E5FC), Color(0xFFFFCCBC), Color(0xFFE6EE9C),
    Color(0xFFCFD8DC), Color(0xFFF3E5F5), Color(0xFFEF9A9A), Color(0xFFBCAAA4),
    Color(0xFFFFF3E0), Color(0xFFA1887F), Color(0xFF8D6E63), Color(0xFF6D4C41),
    Color(0xFFFFE082), Color(0xFFFFCC80), Color(0xFFD7CCC8), Color(0xFFFF5252),
    Color(0xFFFFA726), Color(0xFFFFEB3B), Color(0xFF26C6DA), Color(0xFF66BB6A),
    Color(0xFF7E57C2), Color(0xFF29B6F6), Color(0xFFEC407A), Color(0xFFAB47BC),
  ];

  static final Random _rand = Random();

  /// Returns a random color from the palette
  static Color get randomColor => colorPalette[_rand.nextInt(colorPalette.length)];

  /// Returns a consistent color for a given week number
  static Color getColorOnWeek(DateTime dateTime) {
    final weekNumber = WeekStats.getWeekInTheYear(dateTime);
    return getColorAtIndex(weekNumber);
  }

  /// Returns a color from the palette based on index (with wrapping)
  static Color getColorAtIndex(int index) {
    return colorPalette[index % colorPalette.length];
  }
}

class AppTextStyle {
  static final TextStyle optionMenuTextStyle = TextStyle(
    fontSize: 14, 
    color: AppColors.optionMenuContent
  );
  
  static final TextStyle appBarTextStyle = TextStyle(
    fontSize: 18, 
    fontWeight: FontWeight.bold, 
    color: AppColors.appbarContent
  );

  static final TextStyle textStyleCardTitle = TextStyle(
    fontSize: 14,
    color: Colors.blueGrey[800],
    fontWeight: FontWeight.w600,
  );

  static final TextStyle textStyleCardSubTitle = TextStyle(
    fontSize: 12,
    color: Colors.grey[600],
    fontWeight: FontWeight.w400,
  );
}
