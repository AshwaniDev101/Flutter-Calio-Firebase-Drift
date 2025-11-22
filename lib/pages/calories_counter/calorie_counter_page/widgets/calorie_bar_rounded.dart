

import 'dart:math';
import 'package:flutter/material.dart';

String _trimTrailingZero(double v) {
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  return v.toString();
}

class CalorieSemicircleRefactored extends StatelessWidget {
  // required
  final double current;

  // sensible defaults (user may override)
  final double maxCalories; // what maps to the full semicircle (1.0)
  final double tick1;
  final double tick2;
  final double tick3;

  // zone colors (0..tick1, tick1..tick2, tick2..tick3, tick3..max)
  final Color color0;
  final Color color1;
  final Color color2;
  final Color color3;

  // visuals
  final double strokeWidth;
  final double size;
  final bool showCenterPercent;
  final Color bgColor;
  final Duration animationDuration;

  const CalorieSemicircleRefactored({
    super.key,
    required this.current,
    this.maxCalories = 3500.0,
    this.tick1 = 1500.0,
    this.tick2 = 1700.0,
    this.tick3 = 2500.0,
    // this.color0 = Colors.grey,
    this.color0 = const Color(0xFFD8D8D8),
    // this.color1 = Colors.green,
    this.color1  = const Color(0xFF10DA48),
    this.color2 = Colors.amber,
    // this.color3 = Colors.red,
    this.color3 = const Color(0xFFFF6B6B),
    this.strokeWidth = 18.0,
    this.size = 220.0,
    this.showCenterPercent = true,
    this.bgColor = const Color(0xFFECEFF1),
    this.animationDuration = const Duration(milliseconds: 420),
  })  : assert(maxCalories > 0),
        assert(0 <= tick1 && tick1 < tick2 && tick2 < tick3 && tick3 <= maxCalories);

  // numeric -> fraction helper (0..1)
  double _numToFrac(double value) => (value / maxCalories).clamp(0.0, 1.0).toDouble();

  @override
  Widget build(BuildContext context) {
    final targetFrac = _numToFrac(current);

    final f1 = _numToFrac(tick1);
    final f2 = _numToFrac(tick2);
    final f3 = _numToFrac(tick3);

    return SizedBox(
      width: size,
      height: size / 2 + 84, // extra space for bottom labels & tick labels
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: targetFrac),
        duration: animationDuration,
        curve: Curves.easeOutCubic,
        builder: (_, animFrac, __) {
          final pct = (animFrac * 100).clamp(0, 999).toStringAsFixed(0);

          return Stack(
            alignment: Alignment.topCenter,
            children: [
              // The semicircle painter
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: size / 2 + strokeWidth / 2,
                child: CustomPaint(
                  painter: _RefactoredPainter(
                    animFrac: animFrac,
                    strokeWidth: strokeWidth,
                    bgColor: bgColor,
                    segFrac0: f1,
                    segFrac1: (f2 - f1).clamp(0.0, 1.0),
                    segFrac2: (f3 - f2).clamp(0.0, 1.0),
                    segFrac3: (1.0 - f3).clamp(0.0, 1.0),
                    segColor0: color0,
                    segColor1: color1,
                    segColor2: color2,
                    segColor3: color3,
                    tick1Frac: f1,
                    tick2Frac: f2,
                    tick3Frac: f3,
                    tick1Value: tick1,
                    tick2Value: tick2,
                    tick3Value: tick3,
                    maxCalories: maxCalories,
                  ),
                ),
              ),

              // Center text: current value (+ percent if enabled)
              Positioned(
                top: size / 8 + 40,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_trimTrailingZero(current)} kcal',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    if (showCenterPercent) const SizedBox(height: 6),
                    if (showCenterPercent)
                      Text(
                        '$pct%',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),

              // Bottom row: 0 kcal (left), 'kcal' (center), ∞ kcal (right)
              Positioned(
                top: size / 2 + 44,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0 kcal', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                    // Text('kcal', style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w600)),
                    Text('\u221E kcal', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
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

class _RefactoredPainter extends CustomPainter {
  final double animFrac; // 0..1
  final double strokeWidth;
  final Color bgColor;

  final double segFrac0, segFrac1, segFrac2, segFrac3;
  final Color segColor0, segColor1, segColor2, segColor3;

  final double tick1Frac, tick2Frac, tick3Frac;
  final double tick1Value, tick2Value, tick3Value;
  final double maxCalories;

  _RefactoredPainter({
    required this.animFrac,
    required this.strokeWidth,
    required this.bgColor,
    required this.segFrac0,
    required this.segFrac1,
    required this.segFrac2,
    required this.segFrac3,
    required this.segColor0,
    required this.segColor1,
    required this.segColor2,
    required this.segColor3,
    required this.tick1Frac,
    required this.tick2Frac,
    required this.tick3Frac,
    required this.tick1Value,
    required this.tick2Value,
    required this.tick3Value,
    required this.maxCalories,
  });

  @override
  void paint(Canvas c, Size s) {
    // center moved slightly down so semicircle fits with labels above/below
    final center = Offset(s.width / 2, s.height + 50);
    final r = s.width / 2;
    final rect = Rect.fromCircle(center: center, radius: r);

    const start = pi;
    const totalSweep = pi;

    // Background arc (flat edges)
    final bg = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    c.drawArc(rect, start, totalSweep, false, bg);

    // Compute segment sweeps
    final s0 = totalSweep * segFrac0;
    final s1 = totalSweep * segFrac1;
    final s2 = totalSweep * segFrac2;
    final s3 = totalSweep * segFrac3;

    // Fill the arc up to animFrac (in order of segments)
    double remain = totalSweep * animFrac;
    double curStart = start;

    void drawSegment(double segSweep, Color color) {
      if (segSweep <= 0) {
        curStart += segSweep;
        return;
      }
      final toDraw = remain > 0 ? min(remain, segSweep) : 0.0;
      if (toDraw > 0) {
        c.drawArc(
          rect,
          curStart,
          toDraw,
          false,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.butt,
        );
      }
      curStart += segSweep;
      remain -= toDraw;
    }

    drawSegment(s0, segColor0);
    drawSegment(s1, segColor1);
    drawSegment(s2, segColor2);
    drawSegment(s3, segColor3);

    // Ticks: make them longer and more visible
    final tickPaint = Paint()
      ..color = Colors.grey.shade800
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.butt;

    // Increase outer length and inner length so ticks cut across the arc thickness
    final tickOuter = strokeWidth / 2 + 10; // extends outside arc
    final tickInner = strokeWidth / 2 + 0;  // extends inside arc

    void drawTick(double frac, Color color, double value) {
      final angle = start + totalSweep * frac;
      final p1 = Offset(center.dx + (r - tickInner) * cos(angle), center.dy + (r - tickInner) * sin(angle));
      final p2 = Offset(center.dx + (r + tickOuter) * cos(angle), center.dy + (r + tickOuter) * sin(angle));
      // color the tick using the segment color passed in
      tickPaint.color = color;
      c.drawLine(p1, p2, tickPaint);

      // label: show the configured tick VALUE (not fraction*max)
      final labelR = r + strokeWidth / 2 + 20;
      final pos = Offset(center.dx + labelR * cos(angle), center.dy + labelR * sin(angle));

      final tp = TextPainter(
        text: TextSpan(
          text: _trimTrailingZero(value),
          style: TextStyle(fontSize: 11, color: Colors.grey.shade900),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // shift label slightly outward so it doesn't overlap tick
      tp.paint(c, pos - Offset(tp.width / 2, tp.height / 2));
    }

    // Draw ticks with their zone colors
    drawTick(tick1Frac, segColor1, tick1Value);
    drawTick(tick2Frac, segColor2, tick2Value);
    drawTick(tick3Frac, segColor3, tick3Value);
  }

  @override
  bool shouldRepaint(covariant _RefactoredPainter old) {
    return old.animFrac != animFrac ||
        old.segFrac0 != segFrac0 ||
        old.segFrac1 != segFrac1 ||
        old.segFrac2 != segFrac2 ||
        old.segFrac3 != segFrac3 ||
        old.segColor0 != segColor0 ||
        old.segColor1 != segColor1 ||
        old.segColor2 != segColor2 ||
        old.segColor3 != segColor3 ||
        old.tick1Frac != tick1Frac ||
        old.tick2Frac != tick2Frac ||
        old.tick3Frac != tick3Frac;
  }
}
