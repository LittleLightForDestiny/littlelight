// @dart=2.9

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

enum CornerPosition {
  TopLeft,
  TopRight,
  BottomLeft,
  BottomRight,
}

class CornerBadgeDecoration extends Decoration {
  final List<Color> colors;
  final double badgeSize;
  final CornerPosition position;

  const CornerBadgeDecoration(
      {@required this.colors, @required this.badgeSize, this.position = CornerPosition.TopRight});

  List<Color> get badgeColors => colors;

  @override
  BoxPainter createBoxPainter([onChanged]) => CornerBadgePainter(badgeColors, badgeSize, this.position);
}

class CornerBadgePainter extends BoxPainter {
  static const double CORNER_RADIUS = 0;
  final List<Color> badgeColors;
  final double badgeSize;
  final CornerPosition position;

  CornerBadgePainter(this.badgeColors, this.badgeSize, this.position);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    double size = badgeSize ?? configuration.size.width;
    canvas.save();
    var points = getPoints(size);
    var o = getOffset(offset, configuration, size);
    canvas.translate(o.dx, o.dy);
    canvas.drawPath(buildBadgePath(points), getBadgePaint(points, badgeColors));
    canvas.restore();
  }

  List<Offset> getPoints(double size) {
    var topLeft = Offset(0, 0);
    var topRight = Offset(size, 0);
    var bottomLeft = Offset(0, size);
    var bottomRight = Offset(size, size);
    switch (this.position) {
      case CornerPosition.TopLeft:
        return [bottomLeft, bottomRight, topRight];
      case CornerPosition.TopRight:
        return [topLeft, bottomLeft, bottomRight];
      case CornerPosition.BottomLeft:
        return [topLeft, topRight, bottomRight];
      case CornerPosition.BottomRight:
        return [topRight, topLeft, bottomLeft];
    }
    return [bottomLeft, bottomRight, topRight];
  }

  Offset getOffset(Offset offset, ImageConfiguration configuration, double size) {
    switch (this.position) {
      case CornerPosition.TopLeft:
        return Offset(offset.dx, offset.dy);
      case CornerPosition.TopRight:
        return Offset(offset.dx + configuration.size.width - size, offset.dy);
      case CornerPosition.BottomLeft:
        return Offset(offset.dx, offset.dy + configuration.size.height - size);
      case CornerPosition.BottomRight:
        return Offset(offset.dx + configuration.size.width - size, offset.dy + configuration.size.height - size);
    }
    return Offset(0, 0);
  }

  Paint getSingleColorPaint(List<Color> colors) => Paint()
    ..color = colors?.single ?? Color(0x0000000)
    ..isAntiAlias = true;

  Paint getMultiColorPaint(List<Offset> points, List<Color> colors) => Paint()
    ..shader = gradient(points, colors)
    ..isAntiAlias = true;

  ui.Gradient gradient(List<Offset> points, List<Color> colors) {
    double partSize = 1 / (colors?.length ?? 1);
    var stops = colors
        .expand((element) => [colors.indexOf(element) * partSize, (colors.indexOf(element) + 1) * partSize + .001])
        .toList();
    var doubledColors = colors.expand((element) => [element, element]).toList();
    return ui.Gradient.linear(
        Offset(points[0].dx, points[0].dy), Offset(points[2].dx, points[2].dy), doubledColors, stops);
  }

  Paint getBadgePaint(List<Offset> points, List<Color> colors) =>
      (colors?.length ?? 0) > 1 ? getMultiColorPaint(points, colors) : getSingleColorPaint(colors);

  Path buildBadgePath(List<Offset> points) => Path.combine(
      PathOperation.difference,
      Path()
        ..addRRect(RRect.fromLTRBAndCorners(points[0].dx, points[0].dy, points[2].dx, points[2].dy,
            topRight: Radius.circular(CORNER_RADIUS))),
      Path()
        ..moveTo(points[0].dx, points[0].dy)
        ..lineTo(points[1].dx, points[1].dy)
        ..lineTo(points[2].dx, points[2].dy)
        ..close());
}
