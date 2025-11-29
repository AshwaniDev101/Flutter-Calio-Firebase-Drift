import 'package:flutter/material.dart';

import '../../core/helper.dart';


/// 🧠 Main reactive heatmap widgets
class MonthHeatmap extends StatelessWidget {
  final DateTime currentDateTime;
  final Stream<Map<String, dynamic>> heatmapStream;

  const MonthHeatmap({
    super.key,
    required this.currentDateTime,
    required this.heatmapStream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: heatmapStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 70,
            child: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
          );
        }

        if (snapshot.hasError) {
          return const SizedBox(
            height: 70,
            child: Center(child: Text('Error loading heatmap')),
          );
        }

        final heatmapData = snapshot.data ?? {};

        return HeatmapGrid(
          currentDateTime: currentDateTime,
          heatmapData: heatmapData,
        );
      },
    );
  }
}

/// 🧱 Builds the grid layout and handles month calculations
class HeatmapGrid extends StatelessWidget {
  final DateTime currentDateTime;
  final Map<String, dynamic> heatmapData;

  final double height = 70;
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

  Color _getColor(double percentage) {
    percentage = percentage.clamp(0, 100);
    return percentage == 0
        ? hexToColorWithOpacity("#EBEDF0", 100)
        : hexToColorWithOpacity("#38d9a9", percentage);
  }

  @override
  Widget build(BuildContext context) {
    final now = currentDateTime;
    final daysInMonth = _daysInMonth(now);

    const rows = 2;
    final firstWeekday = DateTime(now.year, now.month, 1).weekday;
    final offset = (firstWeekday - 1) % rows;
    final columns = ((offset + daysInMonth) / rows).ceil();

    final deviceWidth = MediaQuery.of(context).size.width;
    final totalHSpacing = (columns - 1) * hSpacing;
    final availableWidth = deviceWidth - horizontalPadding * 2 - totalHSpacing;
    final rawBoxSize = (availableWidth / columns);

    final totalVSpacing = (rows - 1) * vSpacing;
    final availableHeight = height - verticalPadding * 2 - totalVSpacing;
    final rawRowHeight = (availableHeight / rows);

    final boxSize = rawBoxSize.isFinite
        ? rawBoxSize.clamp(6.0, 48.0).clamp(0.0, rawRowHeight)
        : rawRowHeight.clamp(6.0, 48.0);

    final placeholderColor = hexToColorWithOpacity("#FFFFFF", 0);

    final totalCells = columns * rows;
    final cells = List.generate(totalCells, (cellIndex) {
      final dayNumber = (cellIndex - offset + 1);
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

      final value = (heatmapData[dayNumber.toString()] ?? 0).toDouble();
      final isToday = (now.day == dayNumber &&
          DateTime.now().month == now.month &&
          DateTime.now().year == now.year);

      return HeatmapCell(
        day: dayNumber,
        color: _getColor(value),
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

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Column(
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
          // "$day",
          style: TextStyle(fontSize: 8, color: Colors.grey[800]),
        ),
      ),
    );
  }
}
