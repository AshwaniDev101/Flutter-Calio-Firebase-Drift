import 'package:calio/models/week_stats.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class WeeklyListWidget extends StatelessWidget {

  final List<WeekStats> weekStatsList;
  const WeeklyListWidget({super.key, required this.weekStatsList});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: weekStatsList.length,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        itemBuilder: (context, index) {
          // final cardColor = AppColors.getColorOnWeek(weekStatsList[index].foodStatsEntry.getDateTime(weekStatsList[index].year)); //colorPalette[index % AppColors.colorPalette.length];

          final cardColor = AppColors.getColorAtIndex(weekStatsList[index].weekNumber);
          WeekStats weekStats = weekStatsList[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // CARD
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Week ${weekStats.weekNumber}",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 14),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${weekStats.foodStatsEntry.foodStats.calories}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                          Text(
                            "${10500}-${11900}",
                            style: TextStyle(
                              fontSize: 10,
                              // fontWeight: FontWeight.bold,
                              color: Colors.green.shade600,
                            ),
                          ),
                          Text(
                            "${17500}",
                            style: TextStyle(
                              fontSize: 10,
                              // fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
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
                  //     size: const Size(22, 22),
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        },
      ),
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
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
    } else {
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
