// @dart=2.9

import 'package:flutter/material.dart';
import 'dart:math' as math;

class SmallRectRangeSliderValueIndicatorShape extends RangeSliderValueIndicatorShape {
  const SmallRectRangeSliderValueIndicatorShape();

  static const _SmallRectSliderTrackShapePathPainter _pathPainter = _SmallRectSliderTrackShapePathPainter();

  @override
  Size getPreferredSize(
    bool isEnabled,
    bool isDiscrete, {
    @required TextPainter labelPainter,
    double textScaleFactor,
  }) {
    assert(labelPainter != null);
    return _pathPainter.getPreferredSize(isEnabled, isDiscrete, labelPainter);
  }

  @override
  double getHorizontalShift({
    RenderBox parentBox,
    Offset center,
    TextPainter labelPainter,
    Animation<double> activationAnimation,
    double textScaleFactor,
    Size sizeWithOverflow,
  }) {
    return _pathPainter.getHorizontalShift(
      parentBox: parentBox,
      center: center,
      labelPainter: labelPainter,
      scale: activationAnimation.value,
    );
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    @required Animation<double> activationAnimation,
    @required Animation<double> enableAnimation,
    bool isDiscrete,
    bool isOnTop,
    @required TextPainter labelPainter,
    double textScaleFactor,
    Size sizeWithOverflow,
    @required RenderBox parentBox,
    @required SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
    Thumb thumb,
  }) {
    assert(context != null);
    assert(center != null);
    assert(activationAnimation != null);
    assert(enableAnimation != null);
    assert(labelPainter != null);
    assert(parentBox != null);
    assert(sliderTheme != null);
    final ColorTween enableColor = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.valueIndicatorColor,
    );
    // Add a stroke of 1dp around the top paddle.
    _pathPainter.drawValueIndicator(
      parentBox,
      context.canvas,
      center,
      Paint()..color = enableColor.evaluate(enableAnimation),
      activationAnimation.value,
      labelPainter,
      isOnTop ? sliderTheme.overlappingShapeStrokeColor : null,
    );
  }
}

class _SmallRectSliderTrackShapePathPainter {
  const _SmallRectSliderTrackShapePathPainter();

  // These constants define the shape of the default value indicator.
  // The value indicator changes shape based on the size of
  // the label: The top lobe spreads horizontally, and the
  // top arc on the neck moves down to keep it merging smoothly
  // with the top lobe as it expands.

  // Radius of the top lobe of the value indicator.
  static const double _topLobeRadius = 16.0;
  // Designed size of the label text. This is the size that the value indicator
  // was designed to contain. We scale it from here to fit other sizes.
  static const double _labelTextDesignSize = 14.0;
  // Radius of the bottom lobe of the value indicator.
  static const double _bottomLobeRadius = 10.0;
  static const double _labelPadding = 8.0;
  static const double _distanceBetweenTopBottomCenters = 30.0;
  static const Offset _topLobeCenter = Offset(0.0, -_distanceBetweenTopBottomCenters);
  static const double _preferredHeight = _distanceBetweenTopBottomCenters + _topLobeRadius + _bottomLobeRadius;

  Size getPreferredSize(
    bool isEnabled,
    bool isDiscrete,
    TextPainter labelPainter,
  ) {
    assert(labelPainter != null);
    final double textScaleFactor = labelPainter.height / _labelTextDesignSize;
    return Size(labelPainter.width + 2 * _labelPadding * textScaleFactor, _preferredHeight * textScaleFactor);
  }

  // Adds an arc to the path that has the attributes passed in. This is
  // a convenience to make adding arcs have less boilerplate.

  double getHorizontalShift({
    RenderBox parentBox,
    Offset center,
    TextPainter labelPainter,
    double scale,
  }) {
    final double textScaleFactor = labelPainter.height / _labelTextDesignSize;
    final double inverseTextScale = textScaleFactor != 0 ? 1.0 / textScaleFactor : 0.0;
    final double labelHalfWidth = labelPainter.width / 2.0;
    final double halfWidthNeeded = math.max(
      0.0,
      inverseTextScale * labelHalfWidth - (_topLobeRadius - _labelPadding),
    );
    final double shift = _getIdealOffset(parentBox, halfWidthNeeded, textScaleFactor * scale, center);
    return shift * textScaleFactor;
  }

  // Determines the "best" offset to keep the bubble within the slider. The
  // calling code will bound that with the available movement in the paddle shape.
  double _getIdealOffset(
    RenderBox parentBox,
    double halfWidthNeeded,
    double scale,
    Offset center,
  ) {
    const double edgeMargin = 4.0;
    final Rect topLobeRect = Rect.fromLTWH(
      -_topLobeRadius - halfWidthNeeded,
      -_topLobeRadius - _distanceBetweenTopBottomCenters,
      2.0 * (_topLobeRadius + halfWidthNeeded),
      2.0 * _topLobeRadius,
    );
    // We can just multiply by scale instead of a transform, since we're scaling
    // around (0, 0).
    final Offset topLeft = (topLobeRect.topLeft * scale) + center;
    final Offset bottomRight = (topLobeRect.bottomRight * scale) + center;
    double shift = 0.0;

    final double startGlobal = parentBox.localToGlobal(Offset.zero).dx;
    if (topLeft.dx < startGlobal + edgeMargin) {
      shift = startGlobal + edgeMargin - topLeft.dx;
    }

    final double endGlobal = parentBox.localToGlobal(Offset(parentBox.size.width, parentBox.size.height)).dx;
    if (bottomRight.dx > endGlobal - edgeMargin) {
      shift = endGlobal - edgeMargin - bottomRight.dx;
    }

    shift = scale == 0.0 ? 0.0 : shift / scale;
    if (shift < 0.0) {
      // Shifting to the left.
      shift = math.max(shift, -halfWidthNeeded);
    } else {
      // Shifting to the right.
      shift = math.min(shift, halfWidthNeeded);
    }
    return shift;
  }

  void drawValueIndicator(
    RenderBox parentBox,
    Canvas canvas,
    Offset center,
    Paint paint,
    double scale,
    TextPainter labelPainter,
    Color strokePaintColor,
  ) {
    if (scale == 0.0) {
      // Zero scale essentially means "do not draw anything", so it's safe to just return. Otherwise,
      // our math below will attempt to divide by zero and send needless NaNs to the engine.
      return;
    }

    // The entire value indicator should scale with the size of the label,
    // to keep it large enough to encompass the label text.
    final double textScaleFactor = labelPainter.height / _labelTextDesignSize;
    final double overallScale = scale * textScaleFactor;
    final double inverseTextScale = textScaleFactor != 0 ? 1.0 / textScaleFactor : 0.0;
    final double labelHalfWidth = labelPainter.width / 2.0;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(overallScale, overallScale);

    // This is the needed extra width for the label.  It is only positive when
    // the label exceeds the minimum size contained by the round top lobe.
    final double halfWidthNeeded = math.max(
      0.0,
      inverseTextScale * labelHalfWidth - (_topLobeRadius - _labelPadding),
    );

    final double shift = _getIdealOffset(parentBox, halfWidthNeeded, overallScale, center);
    final double leftWidthNeeded = halfWidthNeeded - shift;
    final double rightWidthNeeded = halfWidthNeeded + shift;

    final Offset leftCenter = _topLobeCenter - Offset(leftWidthNeeded, 0.0);
    final Offset rightCenter = _topLobeCenter + Offset(rightWidthNeeded, 0.0);
    final Rect valueRect = Rect.fromLTRB(
      leftCenter.dx - _topLobeRadius,
      leftCenter.dy - _topLobeRadius,
      rightCenter.dx + _topLobeRadius,
      rightCenter.dy + _topLobeRadius,
    );
    final RRect rRect = RRect.fromRectAndRadius(valueRect, const Radius.circular(8));

    if (strokePaintColor != null) {
      final Paint strokePaint = Paint()
        ..color = strokePaintColor
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(rRect, strokePaint);
    }

    canvas.drawRRect(rRect, paint);

    // Draw the label.
    canvas.save();
    canvas.translate(shift, -_distanceBetweenTopBottomCenters);
    canvas.scale(inverseTextScale, inverseTextScale);
    labelPainter.paint(canvas, Offset.zero - Offset(labelHalfWidth, labelPainter.height / 2.0));
    canvas.restore();
    canvas.restore();
  }
}
