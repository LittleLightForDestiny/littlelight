import 'package:flutter/material.dart';
import 'dart:math' as math;

class DirectionStatBarWidget extends StatelessWidget {
  final int currentValue;
  final Color currentColor;
  final int equippedValue;
  final Color backgroundColor;
  final Color equippedColor;
  DirectionStatBarWidget(
      {this.currentValue = 0,
      this.currentColor,
      this.equippedValue,
      this.backgroundColor,
      this.equippedColor});

  @override
  Widget build(BuildContext context) {
    var currentDirection = calculateDirection(currentValue);
    var equippedDirection = calculateDirection(equippedValue);
    return Container(
        child: Stack(children: [
      Positioned.fill(child: CustomPaint(painter: _SemiCirclePainter(color: backgroundColor))),
      Positioned.fill(
          child: CustomPaint(
              painter: _SemiCirclePainter(
        color: equippedColor,
        arcStart: equippedDirection.min,
        arcEnd: equippedDirection.max,
      ))),
      Positioned.fill(
          child: CustomPaint(
              painter: _SemiCirclePainter(
        color: currentColor,
        arcStart: currentDirection.min,
        arcEnd: currentDirection.max,
      )))
    ]));
  }

  _DirectionRange calculateDirection(int value) {
    value = math.max(0, math.min(100, value));
    double direction =
        math.sin((value + 5) * ((2 * math.pi) / 20)) * (100 - value) / 100;
    double centralDirection = (direction + 1) * math.pi / 2;
    double spread = math.max(.1, (math.pi / 3) * (100 - value) / 100);

    return _DirectionRange(
        centralDirection - spread, centralDirection + spread);
  }
}

class _DirectionRange {
  final double min;
  final double max;

  _DirectionRange(this.min, this.max);
}

class _SemiCirclePainter extends CustomPainter {
  final Color color;
  final double arcStart;
  final double arcEnd;
  _SemiCirclePainter(
      {this.color = Colors.grey, this.arcStart = 0, this.arcEnd = math.pi});

  @override
  void paint(Canvas canvas, Size size) {
    var clip = Path();
    clip.moveTo(size.width / 2, size.height);
    clip.lineTo(size.width / 2, size.height);
    clip.lineTo(size.width, size.height / 2);
    clip.lineTo(size.width / 2, 0);
    // canvas.clipPath(clip, doAntiAlias: true);
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawArc(Rect.fromLTRB(0, 0, size.width, size.height * 2),
        arcStart + math.pi, arcEnd - arcStart, true, paint);
  }

  @override
  bool shouldRepaint(_SemiCirclePainter oldPainter) {
    return true;
  }
}
