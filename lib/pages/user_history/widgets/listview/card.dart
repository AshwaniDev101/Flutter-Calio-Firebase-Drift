
import 'package:calio/models/week_stats.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_settings.dart';
import '../../../../helper/progress_visuals_helper.dart';
import '../../../../models/food_stats.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/caution_label/caution_label_widget.dart';
import '../../../../widgets/edit_delete_option_menu/edit_delete_option_menu.widget.dart';

class DayCard extends StatelessWidget {
  final DateTime dateTime;
  final FoodStats foodStats;
  final EditDeleteOptionMenuWidget editDeleteOptionMenu;

  const DayCard({
    super.key,
    required this.dateTime,
    required this.foodStats,
    required this.editDeleteOptionMenu,
  });

  @override
  Widget build(BuildContext context) {
    final weekdayName = DateFormat('EEE').format(dateTime).toUpperCase();
    final formattedDate = DateFormat('d MMM, y').format(dateTime);





    final Color cardColor = AppColors.getColorOnWeek(dateTime);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
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
                                text: "Week ${WeekStats.getWeekInTheYear(dateTime)}",
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
                size: const Size(32, 32),
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




