
import 'package:flutter/material.dart';

class CalorieBarLinear extends StatelessWidget {
  final int currentCalories;
  final int atLeastCalories; // green threshold
  final int atMostCalories; // yellow threshold
  final double greenPercent; // portion of bar reserved for "green"
  final double yellowPercent; // portion of bar reserved for "yellow"
  final double height;
  final bool showPercent;
  final Color bgColor;
  final Color greenColor;
  final Color yellowColor;
  final Color redColor;

  const CalorieBarLinear({
    super.key,
    required this.currentCalories,
    required this.atLeastCalories,
    required this.atMostCalories,
    this.greenPercent = 0.6,
    this.yellowPercent = 0.8,
    this.height = 24.0,
    this.showPercent = true,
    this.bgColor = const Color(0xFFF0F0F0),
    this.greenColor = const Color(0xFF8CE99A),
    // this.yellowColor = const Color(0xFFFFE082),
    this.yellowColor = const Color(0xFF9C9C9C),
    this.redColor = const Color(0xFFFF474F),
  })  : assert(greenPercent > 0 && greenPercent < yellowPercent && yellowPercent < 1.0),
        assert(atLeastCalories > 0 && atMostCalories > atLeastCalories);

  double _computeFraction() {
    final cur = currentCalories.toDouble();
    final atLeast = atLeastCalories.toDouble(); // green threshold
    final atMost = atMostCalories.toDouble();   // yellow threshold
    final g = greenPercent;                    // 60%
    final y = yellowPercent;                   // 80%

    if (cur <= atLeast) return (cur / atLeast) * g;
    if (cur <= atMost) {
      final t = (cur - atLeast) / (atMost - atLeast);
      return g + t * (y - g);
    }

    // Beyond atMost, extend proportionally to some maxCalories
    final maxCalories = atMost * 2; // for example, adjust as needed
    final t = ((cur - atMost) / (maxCalories - atMost)).clamp(0.0, 1.0);
    return y + t * (1.0 - y);
  }


  double displayedPercent() {
    final cur = currentCalories.toDouble();
    // final atLeast = atLeastCalories.toDouble();
    final atMost = atMostCalories.toDouble();

    if (cur <= atMost) {
      // proportional to atMostCalories as 100%
      return (cur / atMost) * 100;
    }
    // beyond atMost, can scale beyond 100%
    return (cur / atMost) * 100;
  }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final totalWidth = constraints.maxWidth;
      final fraction = _computeFraction().clamp(0.0, 1.0);

      // animate change in fraction smoothly when value changes
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: fraction),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        builder: (context, animatedFraction, _) {
          final filledWidth = animatedFraction * totalWidth;
          final greenW = totalWidth * greenPercent;
          final yellowW = totalWidth * (yellowPercent - greenPercent);
          final redW = totalWidth * (1.0 - yellowPercent);

          // fixed label width for simple clamping
          const labelW = 72.0;
          final labelLeft = (filledWidth - labelW / 2).clamp(0.0, totalWidth - labelW);

          // percent string
          // final percentText = (animatedFraction * 100).toStringAsFixed(0) + '%';
          final percentText = '${displayedPercent().toStringAsFixed(0)}%';

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // background
                  Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(height / 2),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),

                  // vertical markers
                  Positioned(
                    left: greenW - 1,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 2, color: Colors.grey.shade400),
                  ),
                  Positioned(
                    left: greenW + yellowW - 1,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 2, color: Colors.grey.shade400),
                  ),

                  // filled segments (clamped per segment)
                  // green segment
                  if (filledWidth > 0)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: filledWidth.clamp(0.0, greenW),
                        decoration: BoxDecoration(
                          color: greenColor,
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(height / 2)),
                        ),
                      ),
                    ),

                  // yellow segment
                  if (filledWidth > greenW)
                    Positioned(
                      left: greenW,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: (filledWidth - greenW).clamp(0.0, yellowW),
                        color: yellowColor,
                      ),
                    ),

                  // red segment
                  if (filledWidth > greenW + yellowW)
                    Positioned(
                      left: greenW + yellowW,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: (filledWidth - greenW - yellowW).clamp(0.0, redW),
                        decoration: BoxDecoration(
                          color: redColor,                     // move color here
                          borderRadius: BorderRadius.horizontal(right: Radius.circular(height / 2)),
                        ),
                      ),
                    ),


                  // floating label above bar
                  Positioned(
                    left: labelLeft,
                    top: -30,
                    child: Tooltip(
                      message: '$currentCalories kcal',
                      child: Container(
                        width: labelW,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$currentCalories kcal',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              height: 4,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: (animatedFraction).clamp(0.0, 1.0),
                                child: Container(color: Colors.grey.shade300),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // bottom row: thresholds and optional percent
              SizedBox(
                height: 18,
                width: totalWidth,
                child: Stack(
                  children: [
                    // atLeast label (centered approximately on marker)
                    Positioned(
                      left: (greenW - 40).clamp(0.0, totalWidth - 80),
                      child: Text(
                        '$atLeastCalories kcal',
                        style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                      ),
                    ),

                    // atMost label
                    Positioned(
                      left: (greenW + yellowW - 40).clamp(0.0, totalWidth - 80),
                      child: Text(
                        '$atMostCalories kcal',
                        style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                      ),
                    ),

                    if (showPercent)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Text(
                          percentText,
                          style: TextStyle(fontSize: 10, color: Colors.grey[800], fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    });
  }
}