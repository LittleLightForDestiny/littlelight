import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class CornerBadgeDecoration extends Decoration {
  final List<Color> colors;
  final double badgeSize;

  const CornerBadgeDecoration(
      {@required this.colors, @required this.badgeSize});

  List<Color> get badgeColors => colors;

  @override
  BoxPainter createBoxPainter([onChanged]) => _BadgePainter(badgeColors, badgeSize);
}

class _BadgePainter extends BoxPainter {
  static const double CORNER_RADIUS = 0;
  final List<Color> colors;
  final double badgeSize;

  _BadgePainter(this.colors, this.badgeSize);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    double size = badgeSize ?? configuration.size.width;
    canvas.save();
    canvas.translate(
        offset.dx + configuration.size.width - size, offset.dy);
    canvas.drawPath(buildBadgePath(size), getBadgePaint(size));
    canvas.restore();
  }

  Paint getSingleColorPaint() => Paint()
    ..color = colors.single
    ..isAntiAlias = true;

  Paint getMultiColorPaint(double size) => Paint()
    ..shader = gradient(size)
    ..isAntiAlias = true;

  ui.Gradient gradient(double size){
    double partSize = 1/colors.length;
    var stops = colors.expand((element) => [colors.indexOf(element)*partSize, (colors.indexOf(element) + 1)*partSize + .001]).toList();
    var doubledColors = colors.expand((element) => [element, element]).toList();
    return ui.Gradient.linear(Offset(0,0), Offset(size, size), doubledColors, stops);
  }

  Paint getBadgePaint(double size) =>
      colors.length > 1 ? getMultiColorPaint(size) : getSingleColorPaint();

  Path buildBadgePath(double size) => Path.combine(
      PathOperation.difference,
      Path()
        ..addRRect(RRect.fromLTRBAndCorners(0, 0, size, size,
            topRight: Radius.circular(CORNER_RADIUS))),
      Path()
        ..lineTo(0, size)
        ..lineTo(size, size)
        ..close());
}
