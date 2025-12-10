
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_settings.dart';
import '../../../../models/food_stats.dart';
import '../../../../models/foodstats_entry.dart';
import '../../../helper/progress_visuals_helper.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/caution_label/caution_label_widget.dart';
import '../../../widgets/edit_delete_option_menu/edit_delete_option_menu.widget.dart';


class CalorieHistoryListview extends StatelessWidget {
  final List<FoodStatsEntry> monthStats;
  final DateTime pageDateTime;

  final void Function(DateTime) onEdit;
  final void Function(DateTime) onDelete;

  const CalorieHistoryListview(
      {required this.pageDateTime, required this.monthStats, required this.onEdit, required this.onDelete, super.key});

  @override
  Widget build(BuildContext context) {
    // Sort entries by ID (descending by date)
    final sortedStats = List<FoodStatsEntry>.from(monthStats);
      // ..sort((a, b) => b.id.compareTo(a.id));

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sortedStats.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final entry = sortedStats[index];
        final parts = entry.id.split('-');
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);

        final cardDateTime = DateTime(pageDateTime.year, month, day);

        return _DayCard(
          dateTime: cardDateTime,
          foodStats: entry.stats,
          editDeleteOptionMenu: EditDeleteOptionMenuWidget(
            onDelete: () => onDelete(cardDateTime),
            onEdit: () => onEdit(cardDateTime),
          ),
        );
      },
    );
  }

}

// Improved Compact & Modern DayCard
class _DayCard extends StatelessWidget {
  final DateTime dateTime;
  final FoodStats foodStats;
  final EditDeleteOptionMenuWidget editDeleteOptionMenu;

  const _DayCard({
    required this.dateTime,
    required this.foodStats,
    required this.editDeleteOptionMenu,
  });

  // @override
  // Widget build(BuildContext context) {
  //   final weekdayName = DateFormat('EEE').format(dateTime).toUpperCase();
  //   final formattedDate = DateFormat('d MMM, y').format(dateTime);
  //
  //   // ISO week calculation
  //   final numberOfDays = int.parse(DateFormat("D").format(dateTime));
  //   final int weekDayNo = dateTime.weekday;
  //   final int weekInTheYear = ((numberOfDays - weekDayNo + 10) ~/ 7);
  //
  //   final cardColor = AppColors.colorPalette[weekInTheYear % AppColors.colorPalette.length];
  //
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
  //     child: IntrinsicHeight( // ensures left bar matches card height
  //       child: Row(
  //         crossAxisAlignment: CrossAxisAlignment.stretch,
  //         children: [
  //           // Left colored bar
  //           Container(
  //             width: 8,
  //             decoration: BoxDecoration(
  //               color: cardColor,
  //               borderRadius: const BorderRadius.only(
  //                 topLeft: Radius.circular(12),
  //                 bottomLeft: Radius.circular(12),
  //               ),
  //             ),
  //           ),
  //
  //           // Card content
  //           Expanded(
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: const BorderRadius.only(
  //                   topRight: Radius.circular(14),
  //                   bottomRight: Radius.circular(14),
  //                 ),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.grey.shade300.withValues(alpha: 0.3),
  //                     spreadRadius: 1,
  //                     blurRadius: 4,
  //                     offset: const Offset(0, 2),
  //                   ),
  //                 ],
  //               ),
  //               child: Stack(
  //                 children: [
  //                   // Edit/Delete menu
  //                   Positioned(top: 6, right: 4, child: editDeleteOptionMenu),
  //                   Padding(
  //                     padding: const EdgeInsets.all(12.0),
  //                     child: Row(
  //                       children: [
  //                         // Progress Circle
  //                         _buildProgressCircle(),
  //                         const SizedBox(width: 12),
  //
  //                         // Date + Calories + Status
  //                         Expanded(
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               RichText(
  //                                 text: TextSpan(
  //                                   style: TextStyle(
  //                                     fontSize: 11,
  //                                     fontWeight: FontWeight.w500,
  //                                     color: Colors.grey[500], // default color
  //                                   ),
  //                                   children: [
  //                                     TextSpan(text: formattedDate + ' '), // Date in default color
  //                                     TextSpan(
  //                                       text: '($weekdayName) ',
  //                                       style: const TextStyle(fontWeight: FontWeight.bold), // weekday bold
  //                                     ),
  //                                     TextSpan(
  //                                       text: '-week:$weekInTheYear',
  //                                       style: TextStyle(color: Colors.blue[400], fontStyle: FontStyle.italic,), // week number in different color
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //                               const SizedBox(height: 2),
  //                               Row(
  //                                 children: [
  //                                   Text(
  //                                     '${trimTrailingZero(foodStats.calories)} kcal',
  //                                     style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
  //                                   ),
  //                                   const SizedBox(width: 6),
  //                                   Text(
  //                                     '/${AppSettings.atLeastCalories})',
  //                                     style: TextStyle(color: Colors.grey[500], fontSize: 11),
  //                                   ),
  //                                   const SizedBox(width: 4),
  //                                   Text(
  //                                     'max(${AppSettings.atMaxCalories})',
  //                                     style: TextStyle(color: Colors.grey[500], fontSize: 8),
  //                                   ),
  //                                 ],
  //                               ),
  //                               const SizedBox(height: 4),
  //                               SizedBox(
  //                                 width: 50,
  //                                 child: CationLabelWidget(foodStats: foodStats),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                         const SizedBox(width: 4),
  //
  //                         // Status Summary
  //                         getText(),
  //                         const SizedBox(width: 10),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    final weekdayName = DateFormat('EEE').format(dateTime).toUpperCase();
    final formattedDate = DateFormat('d MMM, y').format(dateTime);

    // ISO week calculation
    final numberOfDays = int.parse(DateFormat("D").format(dateTime));
    final int weekDayNo = dateTime.weekday;
    final int weekInTheYear = ((numberOfDays - weekDayNo + 10) ~/ 7);

    final Color cardColor = AppColors.colorPalette[weekInTheYear % AppColors.colorPalette.length];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      child: Stack(
        children: [

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300.withValues(alpha: 0.3),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildProgressCircle(),
                const SizedBox(width: 12),

                // TEXT COLUMN
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                          children: [
                            TextSpan(text: formattedDate + " "),
                            TextSpan(
                              text: "($weekdayName) ",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: "-week:$weekInTheYear",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.blue[400],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Text(
                            '${trimTrailingZero(foodStats.calories)} kcal',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '/${AppSettings.atLeastCalories})',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500]),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'max(${AppSettings.atMaxCalories})',
                            style:
                            TextStyle(fontSize: 8, color: Colors.grey[500]),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      SizedBox(
                        width: 50,
                        child: CationLabelWidget(foodStats: foodStats),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 4),
                getText(),
                const SizedBox(width: 10),
              ],
            ),
          ),

          // TOP-LEFT TRIANGLE
          Positioned(
            top: 0,
            left: 0,
            child: CustomPaint(
              painter: CornerTrianglePainter(
                color: cardColor,
                isTopLeft: true,
              ),
              size: const Size(26, 26),
            ),
          ),

          // BOTTOM-RIGHT TRIANGLE
          // Positioned(
          //   bottom: 0,
          //   right: 0,
          //   child: CustomPaint(
          //     painter: CornerTrianglePainter(
          //       color: cardColor,
          //       isTopLeft: false,
          //     ),
          //     size: const Size(26, 26),
          //   ),
          // ),

          // EDIT / DELETE MENU
          Positioned(top: 6, right: 4, child: editDeleteOptionMenu),
        ],
      ),
    );
  }




  Widget _buildProgressCircle() {
    final progress = getProgressRatio(foodStats);
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 350),
      tween: Tween(begin: 0, end: progress > 1 ? 1 : progress),
      builder: (context, animatedValue, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 38,
              width: 38,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                value: 1,
                color: Colors.grey.shade200,
              ),
            ),
            SizedBox(
              height: 38,
              width: 38,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                value: animatedValue,
                strokeCap: StrokeCap.round,
                color: getProgressCircleColor(foodStats),
              ),
            ),
            Text('${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          ],
        );
      },
    );
  }

  Widget getText() {
    final max = AppSettings.atMaxCalories;
    final cal = foodStats.calories;
    const rangeA = 1500;
    const rangeB = 1700;

    String text = "Under Eating";
    String stringValue = "${trimTrailingZero(rangeA - cal)} Kcal (eat more)";
    IconData iconData = Icons.fastfood_rounded;
    Color iconColor = Colors.grey;

    if (cal >= rangeA && cal <= rangeB) {
      text = "Perfect";
      stringValue = "";
      iconColor = Colors.green;
      iconData = Icons.check_circle_rounded;
    } else if (cal > rangeB && cal <= max) {
      text = "Over Consumed";
      stringValue = "${trimTrailingZero(cal - rangeB)} Kcal (reduce)";
      iconData = Icons.warning_amber_rounded;
      iconColor = Colors.orange;
    } else if (cal > max) {
      text = "Exceeded";
      stringValue = "+${trimTrailingZero(cal - max)} Kcal (risk)";
      iconColor = Colors.red;
      iconData = Icons.error_rounded;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Icon(iconData, size: 20, color: iconColor),
            const SizedBox(width: 4),
            Text(text, style: TextStyle(color: iconColor, fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
        if (stringValue.isNotEmpty)
          Text(
            stringValue,
            style: TextStyle(color: iconColor, fontSize: 11),
            textAlign: TextAlign.right,
          ),
      ],
    );
  }
}

class CornerTrianglePainter extends CustomPainter {
  final Color color;
  final bool isTopLeft;

  CornerTrianglePainter({required this.color, required this.isTopLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    Path path = Path();

    if (isTopLeft) {
      // Top-left triangle
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
    } else {
      // Bottom-right triangle
      path.moveTo(size.width, size.height);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CornerTrianglePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isTopLeft != isTopLeft;
}










