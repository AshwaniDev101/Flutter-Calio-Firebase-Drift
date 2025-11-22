import 'package:flutter/material.dart';
import '../../../core/app_settings.dart';
import '../../../models/food_stats.dart';

class ProgressVisuals {
  final Color color;
  final Color shadow;
  final IconData icon;

  const ProgressVisuals(this.color, this.shadow, this.icon);
}

/// Returns a value between 0 and infinity representing progress
double getProgressRatio(FoodStats foodStats) {
  return (foodStats.calories / AppSettings.atMaxCalories)
      .clamp(0.0, double.infinity);
}

Color getProgressCircleColor(FoodStats foodStats) {
  return getProgressVisuals(foodStats).color;
}

/// Returns the visuals (color, shadow, icon) based on the calorie ratio.
/// Returns visual color + icon based on the progress ratio.
/// 4-color system: grey → green → amber → red.
ProgressVisuals getProgressVisuals(FoodStats foodStats) {
  final double ratio = getProgressRatio(foodStats).clamp(0.0, 10.0);

  if (ratio < 0.50) {
    return const ProgressVisuals(
      Colors.grey,
      Colors.grey,
      Icons.horizontal_rule_rounded, // neutral icon
    );
  } else if (ratio < 0.75) {
    return const ProgressVisuals(
      Colors.green,
      Colors.green,
      Icons.arrow_downward_rounded,
    );
  } else if (ratio < 1.0) {
    return const ProgressVisuals(
      Colors.amber,
      Colors.amber,
      Icons.arrow_downward_rounded,
    );
  } else {
    return const ProgressVisuals(
      Colors.red,
      Colors.red,
      Icons.arrow_upward_rounded,
    );
  }
}



/// Formats a double for display.
/// If the number is a whole number (e.g., 1.0), it returns an integer string ('1').
/// Otherwise, it returns the standard double string ('1.5').
String trimTrailingZero(double value) {
  if (value == value.truncate()) {
    return value.toInt().toString();
  }
  return value.toString();
}
