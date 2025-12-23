import 'package:calio/core/helpers/color_helper.dart';
import 'package:flutter/material.dart';
import '../../../core/helpers/date_time_helper.dart';
import '../../models/food_stats.dart';

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
      // Under-consuming: blue (0 → 100%)
      final double opacity =
      ((calories / 1500) * 100).clamp(0, 100);
      return ColorHelper.fromHexWithOpacity("#4D96FF", opacity);

    } else if (calories > 1500 && calories <= 1700) {
      // Transition zone: teal (60 → 100%)
      final double opacity =
      (60 + ((calories - 1500) / 200) * 40).clamp(60, 100);
      return ColorHelper.fromHexWithOpacity("#6BCF9D", opacity);

    } else if (calories > 1700 && calories <= 2500) {
      // Optimal range: amber (40 → 100%)
      final double opacity =
      (40 + ((calories - 1700) / 800) * 60).clamp(40, 100);
      return ColorHelper.fromHexWithOpacity("#FFD166", opacity);

    } else if (calories > 2500) {
      // Over-consuming: soft red (60 → 100%)
      final double opacity =
      (60 + ((calories - 2500) / 1000) * 40).clamp(60, 100);
      return ColorHelper.fromHexWithOpacity("#EF476F", opacity);

    } else {
      // No data / zero
      return ColorHelper.fromHexWithOpacity("#EBEDF0", 100);
    }
  }


  // Color _getColor(double calories) {
  //   if (calories > 0 && calories <= 1500) {
  //     final double opacity = ((calories / 1500) * 100).clamp(0, 100);
  //     return ColorHelper.fromHexWithOpacity("#6ede8a", opacity);
  //   }else if (calories > 1500 && calories <= 1700) {
  //     return ColorHelper.fromHexWithOpacity("#6ede8a", 50);
  //   } else if (calories > 1700 && calories <= 2500) {
  //     return ColorHelper.fromHexWithOpacity("#ffe66d", 50);
  //   } else if (calories > 2500) {
  //     return ColorHelper.fromHexWithOpacity("#ff6b6b", 50);
  //   } else {
  //     return ColorHelper.fromHexWithOpacity("#EBEDF0", 100);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final now = currentDateTime;
    final daysInMonth = _daysInMonth(now);

    const int columnsPerRow = 16;
    
    final deviceWidth = MediaQuery.of(context).size.width;
    final availableWidth = deviceWidth - horizontalPadding * 2 - 8;
    final totalHSpacing = (columnsPerRow - 1) * hSpacing;
    
    final boxSize = (availableWidth - totalHSpacing) / columnsPerRow;

    final cells = List.generate(daysInMonth, (index) {
      final dayNumber = index + 1;
      
      // Fixed: The key must exactly match how it's stored in the heatmap map.
      // In ViewModel, it is "${entry.id}-${pageDateTime.year}"
      // entry.id is "day-month"
      final key = "$dayNumber-${now.month}-${now.year}";
      
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
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.only(bottom: vSpacing),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: isToday ? Border.all(width: 1, color: Colors.grey) : null,
      ),
      child: Center(
        child: Text(
          "$day",
          style: TextStyle(fontSize: 8, color: Colors.grey[800]),
        ),
      ),
    );
  }
}
