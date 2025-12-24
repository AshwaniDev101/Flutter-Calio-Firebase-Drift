import 'package:flutter/material.dart';
import '../../../core/helpers/date_time_helper.dart';
import '../../models/food_stats.dart';
import '../../theme/app_colors.dart';

class MonthHeatmapWidget extends StatelessWidget {
  final DateTime currentDateTime;
  final Map<String, FoodStats> heatmapData;

  const MonthHeatmapWidget({
    super.key,
    required this.currentDateTime,
    required this.heatmapData,
  });

  @override
  Widget build(BuildContext context) {
    return HeatmapGrid(
      currentDateTime: currentDateTime,
      heatmapData: heatmapData,
    );
  }
}

/// Builds the grid layout and handles month calculations
class HeatmapGrid extends StatelessWidget {
  final DateTime currentDateTime;
  final Map<String, FoodStats> heatmapData;

  final double hSpacing = 4;
  final double vSpacing = 4;
  final double horizontalPadding = 4;
  final double verticalPadding = 4;

  const HeatmapGrid({
    super.key,
    required this.currentDateTime,
    required this.heatmapData,
  });

  int _daysInMonth(DateTime date) => DateTime(date.year, date.month + 1, 0).day;

  Color _getColor(double calories) {
    if (calories > 0 && calories <= 1500) {
      // Under-consuming
      final double alpha = ((calories / 1500)).clamp(0.0, 1.0);
      return AppColors.heatmapNeutral.withValues(alpha: alpha);

    } else if (calories > 1500 && calories <= 1700) {
      // Transition zone
      final double alpha = (0.6 + ((calories - 1500) / 200) * 0.4).clamp(0.6, 1.0);
      return AppColors.heatmapTransition.withValues(alpha: alpha);

    } else if (calories > 1700 && calories <= 2500) {
      // Optimal range
      final double alpha = (0.4 + ((calories - 1700) / 800) * 0.6).clamp(0.4, 1.0);
      return AppColors.heatmapOptimal.withValues(alpha: alpha);

    } else if (calories > 2500) {
      // Over-consuming
      final double alpha = (0.6 + ((calories - 2500) / 1000) * 0.4).clamp(0.6, 1.0);
      return AppColors.heatmapOver.withValues(alpha: alpha);

    } else {
      // No data / zero
      return AppColors.heatmapEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = currentDateTime;
    final daysInMonth = _daysInMonth(now);

    const int columnsPerRow = 16;
    
    final deviceWidth = MediaQuery.of(context).size.width;
    final availableWidth = deviceWidth - horizontalPadding * 2 - 8;
    final totalHSpacing = (columnsPerRow - 1) * hSpacing;
    
    final boxSize = (availableWidth - totalHSpacing) / columnsPerRow;

    final cells = List.generate(daysInMonth, (index) {
      final dayNumber = index + 1;
      final date = DateTime(now.year, now.month, dayNumber);
      final key = DateTimeHelper.toHeatmapKey(date);
      
      final stats = heatmapData[key];
      final calories = stats?.calories ?? 0.0;
      
      final isToday = (now.day == dayNumber &&
          DateTime.now().month == now.month &&
          DateTime.now().year == now.year);

      return HeatmapCell(
        day: dayNumber,
        color: _getColor(calories),
        isToday: isToday,
        size: boxSize,
        vSpacing: vSpacing,
      );
    });

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0, top: 2),
            child: Text(
              '${DateTimeHelper.getMonthName(now)} ${now.year}',
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Wrap(
              spacing: hSpacing,
              runSpacing: 0,
              children: cells,
            ),
          ),
        ],
      ),
    );
  }
}

/// Single day cell widgets
class HeatmapCell extends StatelessWidget {
  final int day;
  final Color color;
  final bool isToday;
  final double size;
  final double vSpacing;

  const HeatmapCell({
    super.key,
    required this.day,
    required this.color,
    required this.isToday,
    required this.size,
    required this.vSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.only(bottom: vSpacing),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: isToday ? Border.all(width: 1, color: theme.colorScheme.primary.withValues(alpha: 0.5)) : null,
      ),
      child: Center(
        child: Text(
          "$day",
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 7,
            color: color == AppColors.heatmapEmpty ? theme.textTheme.bodySmall?.color : Colors.black87,
          ),
        ),
      ),
    );
  }
}
