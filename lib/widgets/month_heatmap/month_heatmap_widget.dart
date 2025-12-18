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

  // removed fixed height; keep other sizing constants
  final double hSpacing = 4;
  final double vSpacing = 4;
  final double horizontalPadding = 4;
  final double verticalPadding = 4;
  final bool useHorizontalScroll = true;

  const HeatmapGrid({
    super.key,
    required this.currentDateTime,
    required this.heatmapData,
  });

  int _daysInMonth(DateTime date) => DateTime(date.year, date.month + 1, 0).day;

  Color _getColor(double calories) {

    if(calories>1500 && calories<=1700)
      {
        // return Colors.green;
        return hexToColorWithOpacity("#6ede8a", 50);
      }
    else if(calories>1700 && calories<=2500)
      {
        return hexToColorWithOpacity("#ffe66d", 50);
      }
    else if(calories>2500)
    {
      return hexToColorWithOpacity("#ff6b6b", 50);
    }
    else
      {
        return hexToColorWithOpacity("#EBEDF0", 100);
      }
  }

  @override
  Widget build(BuildContext context) {
    final now = currentDateTime;
    final daysInMonth = _daysInMonth(now);

    const rows = 2;
    // Calculate columns needed to fit all days in 'rows' rows
    final columns = (daysInMonth / rows).ceil().clamp(1, 1000);

    final deviceWidth = MediaQuery.of(context).size.width;
    final totalHSpacing = (columns - 1) * hSpacing;
    final availableWidth = deviceWidth - horizontalPadding * 2 - totalHSpacing;
    final rawBoxSize = (availableWidth / columns);

    // Determine box size from width only and clamp to sensible bounds.
    const double minBox = 6.0;
    const double maxBox = 48.0;
    final boxSize = rawBoxSize.isFinite
        ? rawBoxSize.clamp(minBox, maxBox)
        : ((minBox + maxBox) / 2);

    final placeholderColor = hexToColorWithOpacity("#FFFFFF", 0);

    final totalCells = columns * rows;
    final cells = List.generate(totalCells, (cellIndex) {
      // Determine row and column from the flat cellIndex
      // This maps cells column-by-column into the weekColumns list below.
      final rowIndex = cellIndex % rows;
      final colIndex = cellIndex ~/ rows;

      // To get Day 1, 2, 3... in the top row, we calculate the day based on colIndex
      // Row 0: colIndex + 1
      // Row 1: colIndex + 1 + columns
      final dayNumber = colIndex + 1 + (rowIndex * columns);
      final isValidDay = dayNumber >= 1 && dayNumber <= daysInMonth;

      if (!isValidDay) {
        return Container(
          width: boxSize,
          height: boxSize,
          margin: EdgeInsets.only(bottom: vSpacing),
          decoration: BoxDecoration(
            color: placeholderColor,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }

      // Updated key format to match "day-month-year"
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

    final weekColumns = List.generate(columns, (colIndex) {
      final start = colIndex * rows;
      final end = start + rows;
      final columnCells = cells.sublist(start, end);

      return Container(
        margin: EdgeInsets.only(right: colIndex == columns - 1 ? 0 : hSpacing),
        child: Column(children: columnCells),
      );
    });

    final rowContent = Row(children: weekColumns);

    // Let the Column size itself (MainAxisSize.min) so the height becomes dynamic.
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
            child: useHorizontalScroll
                ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: rowContent,
            )
                : rowContent,
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
