// calorie_semicircle_refactored.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../../helper/progress_visuals_helper.dart';

class CalorieSemicircle extends StatelessWidget {
  final double currentCalories;
  final double atLeastCalories;
  final double atMostCalories;
  final double greenPercent; // 0..1 portion of the semicircle reserved for green
  final double yellowPercent; // 0..1 portion up to yellow (must be > greenPercent)
  final double strokeWidth;
  final double size;
  final double overflowFactor; // how far above atMost we map (1.0 => atMost * 2)
  final bool showPercent;
  final Color bgColor;
  final Color greyColor;
  final Color greenColor;
  final Color midColor;   // explicit yellow/mid color (new)
  final Color redColor;

  const CalorieSemicircle({
    super.key,
    required this.currentCalories,
    required this.atLeastCalories,
    required this.atMostCalories,
    this.greenPercent = 0.6,
    this.yellowPercent = 0.8,
    this.strokeWidth = 18.0,
    this.size = 220.0,
    this.overflowFactor = 1.0,
    this.showPercent = true,
    this.bgColor = const Color(0xFFECEFF1),
    this.greyColor = const Color(0xFFD8D8D8),
    this.greenColor = const Color(0xFF8CE99A),
    this.midColor = const Color(0xFFFFE082), // default soft yellow
    this.redColor = const Color(0xFFFF6B6B),
  })  : assert(greenPercent > 0 && greenPercent < yellowPercent && yellowPercent < 1.0),
        assert(atLeastCalories > 0 && atMostCalories > atLeastCalories),
        assert(overflowFactor > 0);

  double _mapCaloriesToFraction(double value) {
    final a = atLeastCalories;
    final m = atMostCalories;
    final g = greenPercent;
    final y = yellowPercent;

    if (value <= a) return _mapBelowAtLeast(value, a, g);
    if (value <= m) return _mapBetween(value, a, m, g, y);
    return _mapOverflow(value, m, y);
  }

  double _mapBelowAtLeast(double value, double a, double g) => (value / a) * g;

  double _mapBetween(double value, double a, double m, double g, double y) {
    final ratio = (value - a) / (m - a); // 0..1
    return g + ratio * (y - g);
  }

  double _mapOverflow(double value, double m, double y) {
    final maxCal = m * (1.0 + overflowFactor);
    final t = ((value - m) / (maxCal - m)).clamp(0.0, 1.0);
    return y + t * (1.0 - y);
  }

  @override
  Widget build(BuildContext context) {
    final targetFrac = _mapCaloriesToFraction(currentCalories).clamp(0.0, 1.0);
    final atLeastFrac = _mapCaloriesToFraction(atLeastCalories).clamp(0.0, 1.0);
    final atMostFrac = _mapCaloriesToFraction(atMostCalories).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size / 2 + 64,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: targetFrac),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        builder: (_, animFrac, __) {
          final pct = (animFrac * 100).clamp(0, 999).toStringAsFixed(0);
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: size / 2 + strokeWidth / 2,
                child: CustomPaint(
                  painter: _SemiCirclePainter(
                    animFrac: animFrac,
                    strokeWidth: strokeWidth,
                    bgColor: bgColor,
                    greenColor: greenColor,    // fixed mapping: greenColor -> green segment
                    yellowColor: midColor,     // explicit middle/yellow color
                    redColor: redColor,
                    greenPercent: greenPercent,
                    yellowPercent: yellowPercent,
                    atLeastFrac: atLeastFrac,
                    atMostFrac: atMostFrac,
                    atLeastValue: atLeastCalories,
                    atMostValue: atMostCalories,
                  ),
                ),
              ),
              Positioned(
                top: size / 8 + 50,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${currentCalories.toStringAsFixed(0)} kcal',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    if (showPercent) const SizedBox(height: 6),
                    if (showPercent)
                      Text('$pct%',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Positioned(
                top: size / 2 + 40,
                left: 14,
                right: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0 kcal', style: TextStyle(fontSize: 11, color: Colors.grey[700])),
                    Text('\u221E kcal', style: TextStyle(fontSize: 11, color: Colors.grey[700])),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SemiCirclePainter extends CustomPainter {
  final double animFrac;
  final double strokeWidth;
  final Color bgColor, greenColor, yellowColor, redColor;
  final double greenPercent, yellowPercent;
  final double atLeastFrac, atMostFrac;
  final double atLeastValue, atMostValue;

  _SemiCirclePainter({
    required this.animFrac,
    required this.strokeWidth,
    required this.bgColor,
    required this.greenColor,
    required this.yellowColor,
    required this.redColor,
    required this.greenPercent,
    required this.yellowPercent,
    required this.atLeastFrac,
    required this.atMostFrac,
    required this.atLeastValue,
    required this.atMostValue,
  });

  @override
  void paint(Canvas c, Size s) {
    // Center is shifted downward intentionally so the semicircle sits within visible area
    final center = Offset(s.width / 2, s.height + 50);
    final r = s.width / 2;
    final rect = Rect.fromCircle(center: center, radius: r);
    const start = pi;
    const sweep = pi;

    // background semicircle
    c.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..color = bgColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt,
    );

    // compute sweeps for segments
    final gSweep = sweep * greenPercent;
    final ySweep = sweep * (yellowPercent - greenPercent);
    final rSweep = sweep * (1.0 - yellowPercent);

    var remain = sweep * animFrac;
    var curStart = start;

    final gDraw = remain > 0 ? min(remain, gSweep) : 0.0;
    remain -= gDraw;
    final yDraw = remain > 0 ? min(remain, ySweep) : 0.0;
    remain -= yDraw;
    final rDraw = remain > 0 ? min(remain, rSweep) : 0.0;

    // draw a segment and advance the current start angle
    void drawSegment(double sweepAngle, Color color) {
      if (sweepAngle <= 0) return;
      c.drawArc(
        rect,
        curStart,
        sweepAngle,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt,
      );
      curStart += sweepAngle;
    }

    drawSegment(gDraw, greenColor);
    drawSegment(yDraw, yellowColor);
    drawSegment(rDraw, redColor);

    // ticks
    final tickLenOuter = strokeWidth / 2 + 2;
    final tickLenInner = strokeWidth / 2 - 2;
    final tickP = Paint()..color = Colors.grey.shade500..strokeWidth = 1.2;

    void tickAt(double frac) {
      final a = start + sweep * frac;
      final p1 = Offset(center.dx + (r - tickLenInner) * cos(a), center.dy + (r - tickLenInner) * sin(a));
      final p2 = Offset(center.dx + (r + tickLenOuter) * cos(a), center.dy + (r + tickLenOuter) * sin(a));
      c.drawLine(p1, p2, tickP);
    }

    tickAt(atLeastFrac);
    tickAt(atMostFrac);

    // small labeled pills next to ticks
    void pill(double frac, String text) {
      final a = start + sweep * frac;
      final labelR = r + strokeWidth / 2 + 10;
      final pos = Offset(center.dx + labelR * cos(a), center.dy + labelR * sin(a));
      final tp = TextPainter(
        text: TextSpan(text: text, style: TextStyle(fontSize: 11, color: Colors.grey.shade900, fontWeight: FontWeight.w600)),
        textDirection: TextDirection.ltr,
      )..layout();

      final ph = 8.0, pv = 4.0;
      final rect = Rect.fromLTWH(pos.dx - tp.width / 2 - ph, pos.dy - tp.height / 2 - pv, tp.width + ph * 2, tp.height + pv * 2);
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(12));
      c.drawRRect(rrect, Paint()..color = Colors.white.withValues(alpha: 0.96));
      c.drawRRect(rrect, Paint()..color = Colors.grey.shade300..style = PaintingStyle.stroke..strokeWidth = 0.7);
      tp.paint(c, Offset(rect.left + ph, rect.top + pv));
    }

    pill(atLeastFrac, '${trimTrailingZero(atLeastValue)} kcal');
    pill(atMostFrac, '${trimTrailingZero(atMostValue)} kcal');
  }

  @override
  bool shouldRepaint(covariant _SemiCirclePainter o) {
    return o.animFrac != animFrac ||
        o.atLeastFrac != atLeastFrac ||
        o.atMostFrac != atMostFrac ||
        o.greenPercent != greenPercent ||
        o.yellowPercent != yellowPercent ||
        o.strokeWidth != strokeWidth ||
        o.bgColor != bgColor ||
        o.greenColor != greenColor ||
        o.yellowColor != yellowColor ||
        o.redColor != redColor;
  }
}
