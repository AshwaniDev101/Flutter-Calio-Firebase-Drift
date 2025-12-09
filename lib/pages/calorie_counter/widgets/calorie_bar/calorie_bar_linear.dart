import 'dart:math';
import 'package:flutter/material.dart';

String _trim(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();


class CalorieLinearProgressBarWidget extends StatelessWidget {
  final double current;

  final double maxCalories;
  final double tick1;
  final double tick2;
  final double tick3;

  final Color color0;
  final Color color1;
  final Color color2;
  final Color color3;

  final double height;
  final Duration animationDuration;

  const CalorieLinearProgressBarWidget({
    super.key,
    required this.current,
    this.maxCalories = 3500,
    this.tick1 = 1500,
    this.tick2 = 1700,
    this.tick3 = 2500,
    // this.color0 = const Color(0xFFD8D8D8),
    this.color0 = const Color(0xFF504D4D),
    this.color1 = const Color(0xFF10DA48),
    this.color2 = Colors.amber,
    this.color3 = const Color(0xFFFF6B6B),
    this.height = 22,
    this.animationDuration = const Duration(milliseconds: 420),
  });

  double _frac(double v) => (v / maxCalories).clamp(0, 1);

  @override
  Widget build(BuildContext context) {
    final f1 = _frac(tick1);
    final f2 = _frac(tick2);
    final f3 = _frac(tick3);

    final seg0 = f1;
    final seg1 = (f2 - f1).clamp(0.0, 1.0);
    final seg2 = (f3 - f2).clamp(0.0, 1.0);
    final seg3 = (1 - f3).clamp(0.0, 1.0);

    final targetFrac = _frac(current);

    final deviceWidth = MediaQuery.of(context).size.width;
    // Leave small insets from device edge so content doesn't touch the absolute edge.
    const double deviceHorizontalInset = 16.0;
    final innerWidth = (deviceWidth - deviceHorizontalInset * 2).clamp(0.0, deviceWidth);

    return Card(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
      
        ),
      
      
        // padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      
        padding: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: 0, // tighter!
        ),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: targetFrac),
          duration: animationDuration,
          curve: Curves.easeOutCubic,
          builder: (context, animFrac, _) {
            // OverflowBox allows the inner child to be wider than the parent constraints
            // so it appears full device width even inside padded parent.
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
                      seg0: seg0,
                      seg1: seg1,
                      seg2: seg2,
                      seg3: seg3,
                      c0: color0,
                      c1: color1,
                      c2: color2,
                      c3: color3,
                      tick1: f1,
                      tick2: f2,
                      tick3: f3,
                    ),
                  ),
                ),
      
                // tiny gap
                const SizedBox(height: 2),
      
                // Tick labels block:
                // - most labels sit slightly BELOW their ticks (nudge up by -6)
                // - tick2 (the middle one) placed ABOVE the bar to avoid overlap (nudge -18)
                SizedBox(
                  height: 20,
                  width: double.infinity,
                  child: LayoutBuilder(builder: (context, cons) {
                    final width = cons.maxWidth;
                    // Use fractional alignment positions; Align uses FractionalOffset( x, 0 )
                    return Stack(
                      children: [
                        // left 0 kcal
                        Align(
                          alignment: const FractionalOffset(0, 0),
                          child: Transform.translate(
                            offset: const Offset(0, -6),
                            child: const Text('0 kcal', style: TextStyle(fontSize: 11)),
                          ),
                        ),
      
                        // tick1 (slightly below)
                        Align(
                          alignment: FractionalOffset(f1.clamp(0.0, 1.0), 0),
                          child: Transform.translate(
                            offset: const Offset(0, -6),
                            child: Text(_trim(tick1), style: const TextStyle(fontSize: 11)),
                          ),
                        ),
      
                        // tick2 (place above the bar to avoid overlap)
                        Align(
                          alignment: FractionalOffset(f2.clamp(0.0, 1.0), 0),
                          child: Transform.translate(
                            offset: const Offset(0, -50),
                            child: Text(_trim(tick2), style: const TextStyle(fontSize: 11)),
                          ),
                        ),
      
                        // tick3 (slightly below)
                        Align(
                          alignment: FractionalOffset(f3.clamp(0.0, 1.0), 0),
                          child: Transform.translate(
                            offset: const Offset(0, -6),
                            child: Text(_trim(tick3), style: const TextStyle(fontSize: 11)),
                          ),
                        ),
      
                        // right infinity label
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
      
                // const SizedBox(height: 2),
      
                // kcal number centered at bottom middle
                // very small gap then kcal centered at bottom middle (tight)
                // const SizedBox(height: 4),
                // use TextStyle height = 1.0 to eliminate extra line-height spacing
                Transform.translate(
                  offset: const Offset(0, -2), // pull a touch upwards to tighten gap
                  child: Text(
                    '${_trim(current)} kcal',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.0),
                  ),
                ),
                // Text('${_trim(current)} kcal',
                //     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Painter for the linear bar with square edges, colored dividers and colored ticks.
class _LinearPainter extends CustomPainter {
  final double anim;
  final double height;

  final double seg0, seg1, seg2, seg3;
  final Color c0, c1, c2, c3;

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
    required this.tick1,
    required this.tick2,
    required this.tick3,
  });

  @override
  void paint(Canvas c, Size s) {
    const double top = 4.0;
    final double barW = s.width;
    final double barH = height;

    // background (square)
    c.drawRect(Rect.fromLTWH(0, top, barW, barH), Paint()..color = const Color(0xFFECEFF1));

    // compute absolute segment widths
    final s0 = seg0 * barW;
    final s1 = seg1 * barW;
    final s2 = seg2 * barW;
    final s3 = seg3 * barW;

    // fill segments progressively up to anim * total width
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

    // ticks: colored according to their segment color; square caps
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
