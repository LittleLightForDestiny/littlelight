import 'package:flutter/material.dart';

Path _getEngramPath(Size size) {
  final path = Path();
  path.moveTo(size.width * .28, size.height * .04);
  path.lineTo(size.width * .70, size.height * .04);
  path.lineTo(size.width * .77, size.height * .09);
  path.lineTo(size.width * .98, size.height * .42);
  path.lineTo(size.width * .98, size.height * .58);
  path.lineTo(size.width * .77, size.height * .88);
  path.lineTo(size.width * .70, size.height * .93);
  path.lineTo(size.width * .28, size.height * .93);
  path.lineTo(size.width * .20, size.height * .88);
  path.lineTo(size.width * .20, size.height * .88);
  path.lineTo(size.width * .01, size.height * .58);
  path.lineTo(size.width * .01, size.height * .42);
  path.lineTo(size.width * .20, size.height * .09);
  path.close();
  return path;
}

class EngramShapePainter extends CustomPainter {
  final Paint _paint;

  EngramShapePainter._(this._paint);
  factory EngramShapePainter.color(Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    return EngramShapePainter._(paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final fill = _getEngramPath(size);
    canvas.drawPath(fill, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EngramBorder extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final fill = _getEngramPath(rect.size);
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
