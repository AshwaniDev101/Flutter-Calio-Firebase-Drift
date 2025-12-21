import 'package:flutter/material.dart';
import '../../../core/helper.dart';
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
      return hexToColorWithOpacity("#7A7781", 50);
    } else if (calories > 1500 && calories <= 1700) {
      return hexToColorWithOpacity("#6ede8a", 50);
    } else if (calories > 1700 && calories <= 2500) {
      return hexToColorWithOpacity("#ffe66d", 50);
    } else if (calories > 2500) {
      return hexToColorWithOpacity("#ff6b6b", 50);
    } else {
      return hexToColorWithOpacity("#EBEDF0", 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = currentDateTime;
    final daysInMonth = _daysInMonth(now);

    // Increased columnsPerRow from 11 to 15 to make cells even smaller.
    const int columnsPerRow = 16;
    
    final deviceWidth = MediaQuery.of(context).size.width;
    final availableWidth = deviceWidth - horizontalPadding * 2 - 8; // -8 for internal padding
    final totalHSpacing = (columnsPerRow - 1) * hSpacing;
    
    // Calculate square box size to fit exactly columnsPerRow in the width
    final boxSize = (availableWidth - totalHSpacing) / columnsPerRow;

    final cells = List.generate(daysInMonth, (index) {
      final dayNumber = index + 1;
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
              '${getMonthName(now)} ${now.year}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Wrap(
              spacing: hSpacing,
              runSpacing: 0, // HeatmapCell handles its own bottom margin via vSpacing
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
