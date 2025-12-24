import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

String trimTrailingZero(double v) {
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  return v.toString();
}

String trimDouble(double v) => trimTrailingZero(v);

/// Single place to keep colors, ticks and numeric helpers.
/// This keeps the public widget APIs the same (for backward compatibility)
/// while centralizing common logic.
class CalorieConfig {
  final double maxCalories;
  final double tick1;
  final double tick2;
  final double tick3;

  final Color color0;
  final Color color1;
  final Color color2;
  final Color color3;

  final Color bgColor;
  final double strokeWidth;
  final Duration animationDuration;

  const CalorieConfig({
    this.maxCalories = 3500.0,
    this.tick1 = 1500.0,
    this.tick2 = 1700.0,
    this.tick3 = 2500.0,
    this.color0 = AppColors.calorieBarUnder,
    this.color1 = AppColors.calorieBarSuccess,
    this.color2 = AppColors.calorieBarWarning,
    this.color3 = AppColors.calorieBarDanger,
    this.bgColor = AppColors.calorieBarBackground,
    this.strokeWidth = 18.0,
    this.animationDuration = const Duration(milliseconds: 420),
  })  : assert(maxCalories > 0),
        assert(0 <= tick1 && tick1 < tick2 && tick2 < tick3 && tick3 <= maxCalories);

  double numToFrac(double value) => (value / maxCalories).clamp(0.0, 1.0).toDouble();

  /// returns the three tick fractions and four segment fractions
  CalorieSegments segments() {
    final f1 = numToFrac(tick1);
    final f2 = numToFrac(tick2);
    final f3 = numToFrac(tick3);

    final seg0 = f1;
    final seg1 = (f2 - f1).clamp(0.0, 1.0);
    final seg2 = (f3 - f2).clamp(0.0, 1.0);
    final seg3 = (1.0 - f3).clamp(0.0, 1.0);

    return CalorieSegments(
      tick1Frac: f1,
      tick2Frac: f2,
      tick3Frac: f3,
      segFrac0: seg0,
      segFrac1: seg1,
      segFrac2: seg2,
      segFrac3: seg3,
    );
  }
}

class CalorieSegments {
  final double tick1Frac, tick2Frac, tick3Frac;
  final double segFrac0, segFrac1, segFrac2, segFrac3;

  const CalorieSegments({
    required this.tick1Frac,
    required this.tick2Frac,
    required this.tick3Frac,
    required this.segFrac0,
    required this.segFrac1,
    required this.segFrac2,
    required this.segFrac3,
  });
}
