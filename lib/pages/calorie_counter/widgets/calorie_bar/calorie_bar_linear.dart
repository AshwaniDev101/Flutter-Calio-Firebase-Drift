import 'dart:math';
import 'package:flutter/material.dart';
import 'calorie_config.dart';

String _trim(double v) => trimTrailingZero(v);

class CalorieLinearProgressBarWidget extends StatelessWidget {
  final double current;
  final CalorieConfig? config;
  final double height;

  const CalorieLinearProgressBarWidget({
    super.key,
    required this.current,
    this.config,
    this.height = 22,
  });

  @override
  Widget build(BuildContext context) {
    // Use the provided config or fallback to a default instance.
    final effectiveConfig = config ?? const CalorieConfig();
    
    final seg = effectiveConfig.segments();
    final targetFrac = effectiveConfig.numToFrac(current);

    return Card(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: 0,
        ),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: targetFrac),
          duration: effectiveConfig.animationDuration,
          curve: Curves.easeOutCubic,
          builder: (context, animFrac, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Progress bar
                SizedBox(
                  height: height + 10,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _LinearPainter(
                      anim: animFrac,
                      height: height,
                      seg0: seg.segFrac0,
                      seg1: seg.segFrac1,
                      seg2: seg.segFrac2,
                      seg3: seg.segFrac3,
                      c0: effectiveConfig.color0,
                      c1: effectiveConfig.color1,
                      c2: effectiveConfig.color2,
                      c3: effectiveConfig.color3,
                      bgColor: effectiveConfig.bgColor,
                      tick1: seg.tick1Frac,
                      tick2: seg.tick2Frac,
                      tick3: seg.tick3Frac,
                    ),
                  ),
                ),

                const SizedBox(height: 2),

                // Tick labels block
                SizedBox(
                  height: 20,
                  width: double.infinity,
                  child: LayoutBuilder(builder: (context, cons) {
                    return Stack(
                      children: [
                        Align(
                          alignment: const FractionalOffset(0, 0),
                          child: Transform.translate(
                            offset: const Offset(0, -6),
                            child: const Text('0 kcal', style: TextStyle(fontSize: 11)),
                          ),
                        ),
                        Align(
                          alignment: FractionalOffset(seg.tick1Frac.clamp(0.0, 1.0), 0),
                          child: Transform.translate(
                            offset: const Offset(0, -6),
                            child: Text(_trim(effectiveConfig.tick1), style: const TextStyle(fontSize: 11)),
                          ),
                        ),
                        Align(
                          alignment: FractionalOffset(seg.tick2Frac.clamp(0.0, 1.0), 0),
                          child: Transform.translate(
                            offset: const Offset(0, -50),
                            child: Text(_trim(effectiveConfig.tick2), style: const TextStyle(fontSize: 11)),
                          ),
                        ),
                        Align(
                          alignment: FractionalOffset(seg.tick3Frac.clamp(0.0, 1.0), 0),
                          child: Transform.translate(
                            offset: const Offset(0, -6),
                            child: Text(_trim(effectiveConfig.tick3), style: const TextStyle(fontSize: 11)),
                          ),
                        ),
                        Align(
                          alignment: const FractionalOffset(1, 0),
                          child: Transform.translate(
                            offset: const Offset(0, -6),
                            child: const Text('\u221E kcal', style: TextStyle(fontSize: 11)),
                          ),
                        ),
                      ],
                    );
                  }),
                ),

                // kcal number
                Transform.translate(
                  offset: const Offset(0, -2),
                  child: Text(
                    '${_trim(current)} kcal',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.0),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LinearPainter extends CustomPainter {
  final double anim;
  final double height;
  final double seg0, seg1, seg2, seg3;
  final Color c0, c1, c2, c3;
  final Color bgColor;
  final double tick1, tick2, tick3;

  _LinearPainter({
    required this.anim,
    required this.height,
    required this.seg0,
    required this.seg1,
    required this.seg2,
    required this.seg3,
    required this.c0,
    required this.c1,
    required this.c2,
    required this.c3,
    required this.bgColor,
    required this.tick1,
    required this.tick2,
    required this.tick3,
  });

  @override
  void paint(Canvas c, Size s) {
    const double top = 4.0;
    final double barW = s.width;
    final double barH = height;

    // background
    c.drawRect(Rect.fromLTWH(0, top, barW, barH), Paint()..color = bgColor);

    final s0 = seg0 * barW;
    final s1 = seg1 * barW;
    final s2 = seg2 * barW;
    final s3 = seg3 * barW;

    double remain = anim * barW;
    double x = 0.0;

    void drawSeg(double segW, Color col) {
      if (segW <= 0) {
        x += segW;
        return;
      }
      final toDraw = min(remain, segW);
      if (toDraw > 0) {
        c.drawRect(Rect.fromLTWH(x, top, toDraw, barH), Paint()..color = col);
      }
      x += segW;
      remain -= toDraw;
    }

    drawSeg(s0, c0);
    drawSeg(s1, c1);
    drawSeg(s2, c2);
    drawSeg(s3, c3);

    final dividerPaint = Paint()..strokeWidth = 1.3..strokeCap = StrokeCap.butt;
    double d1 = s0;
    double d2 = s0 + s1;
    double d3 = s0 + s1 + s2;

    dividerPaint.color = c1;
    c.drawLine(Offset(d1, top - 3), Offset(d1, top + barH + 3), dividerPaint);
    dividerPaint.color = c2;
    c.drawLine(Offset(d2, top - 3), Offset(d2, top + barH + 3), dividerPaint);
    dividerPaint.color = c3;
    c.drawLine(Offset(d3, top - 3), Offset(d3, top + barH + 3), dividerPaint);

    void drawTick(double frac, Color color) {
      final xPos = frac * barW;
      c.drawLine(
        Offset(xPos, top - 3),
        Offset(xPos, top + barH + 3),
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.butt,
      );
    }

    drawTick(tick1, c1);
    drawTick(tick2, c2);
    drawTick(tick3, c3);
  }

  @override
  bool shouldRepaint(covariant _LinearPainter old) => true;
}
