import 'package:flutter/material.dart';

Path _getDiamondPath(Size size) {
  final path = Path();
  path.moveTo(0, size.height / 2);
  path.lineTo(size.width / 2, size.height);
  path.lineTo(size.width, size.height / 2);
  path.lineTo(size.width / 2, 0);
  return path;
}

class DiamondShapePainter extends CustomPainter {
  final Paint _paint;

  DiamondShapePainter._(this._paint);
  factory DiamondShapePainter.color(Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    return DiamondShapePainter._(paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final fill = _getDiamondPath(size);
    canvas.drawPath(fill, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DiamondBorder extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final fill = _getDiamondPath(rect.size);
    return fill;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return getInnerPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    canvas.drawPath(getInnerPath(rect), Paint());
  }

  @override
  ShapeBorder scale(double t) {
    return this;
  }
}
