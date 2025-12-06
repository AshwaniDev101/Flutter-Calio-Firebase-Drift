
import 'package:flutter/material.dart';
import '../../../core/app_settings.dart';
import '../../../models/food_stats.dart';
import '../../helper/progress_visuals_helper.dart';


class CationLabelWidget extends StatelessWidget {
  final FoodStats foodStats;

  const CationLabelWidget({required this.foodStats, super.key});

  @override
  Widget build(BuildContext context) {
    final double maxCalories = AppSettings.atMaxCalories.toDouble();
    final double current = foodStats.calories.toDouble();

    final double diff = current - maxCalories;

    final ProgressVisuals progressVisuals = getProgressVisuals(foodStats);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: progressVisuals.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: progressVisuals.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(progressVisuals.icon, color: Colors.white, size: 12),
          Text(
            diff.abs().toStringAsFixed(0),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
