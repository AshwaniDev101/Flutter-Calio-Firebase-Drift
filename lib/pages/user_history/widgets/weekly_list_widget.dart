import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class WeeklyListWidget extends StatelessWidget {
  const WeeklyListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: 7,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        itemBuilder: (context, index) {
          final cardColor =
          AppColors.colorPalette[index % AppColors.colorPalette.length];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
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
                              "Week ${index + 11}",
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
                          "12,000 kcal",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade600,
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
                    size: const Size(22, 22),
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
