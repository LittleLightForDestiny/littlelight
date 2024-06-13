import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:little_light/core/theme/littlelight.theme.dart';

class FilledCircularProgressIndicator extends ProgressIndicator {
  const FilledCircularProgressIndicator({
    Key? key,
    double? value,
    Color? backgroundColor,
    Animation<Color>? valueColor,
    String? semanticsLabel,
    String? semanticsValue,
  }) : super(
          key: key,
          value: value,
          backgroundColor: backgroundColor,
          valueColor: valueColor,
          semanticsLabel: semanticsLabel,
          semanticsValue: semanticsValue,
        );

  Widget _buildSemanticsWrapper({
    required BuildContext context,
    required Widget child,
  }) {
    final value = this.value;
    String? expandedSemanticsValue = semanticsValue;
    if (value != null && value.isFinite) {
      expandedSemanticsValue ??= '${(value * 100).round()}%';
    }
    return Semantics(
      label: semanticsLabel,
      value: expandedSemanticsValue,
      child: child,
    );
  }

  Color _getValueColor(BuildContext context) => valueColor?.value ?? context.theme.upgradeLayers;

  @override
  _FilledCircularProgressIndicatorState createState() => _FilledCircularProgressIndicatorState();
}

// Tweens used by circular progress indicator
final Animatable<double> _kStrokeHeadTween = CurveTween(
  curve: const Interval(0.0, 0.5, curve: Curves.fastOutSlowIn),
).chain(CurveTween(
  curve: const SawTooth(5),
));

final Animatable<double> _kStrokeTailTween = CurveTween(
  curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
).chain(CurveTween(
  curve: const SawTooth(5),
));

final Animatable<int> _kStepTween = StepTween(begin: 0, end: 5);

final Animatable<double> _kRotationTween = CurveTween(curve: const SawTooth(5));

class _FilledCircularProgressIndicatorState extends State<FilledCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    if (widget.value == null) _controller?.repeat();
  }

  @override
  void didUpdateWidget(FilledCircularProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isAnimating = _controller?.isAnimating ?? false;
    if (widget.value == null && !isAnimating) {
      _controller?.repeat();
    } else if (widget.value != null && isAnimating) {
      _controller?.stop();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildIndicator(
      BuildContext context, double headValue, double tailValue, int stepValue, double rotationValue) {
    return widget._buildSemanticsWrapper(
      context: context,
      child: Container(
        child: CustomPaint(
          painter: _CircularProgressIndicatorPainter(
            backgroundColor: widget.backgroundColor,
            valueColor: widget._getValueColor(context),
            value: widget.value, // may be null
            headValue: headValue, // remaining arguments are ignored if widget.value is not null
            tailValue: tailValue,
            stepValue: stepValue,
            rotationValue: rotationValue,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimation() {
    final controller = _controller;
    if (controller == null) return Container();
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        return _buildIndicator(
          context,
          _kStrokeHeadTween.evaluate(controller),
          _kStrokeTailTween.evaluate(controller),
          _kStepTween.evaluate(controller),
          _kRotationTween.evaluate(controller),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.value != null) return _buildIndicator(context, 0.0, 0.0, 0, 0.0);
    return _buildAnimation();
  }
}

class _CircularProgressIndicatorPainter extends CustomPainter {
  _CircularProgressIndicatorPainter({
    required this.backgroundColor,
    required this.valueColor,
    this.value,
    required this.headValue,
    required this.tailValue,
    required this.stepValue,
    required this.rotationValue,
  })  : arcStart = value != null
            ? _startAngle
            : _startAngle + tailValue * 3 / 2 * math.pi + rotationValue * math.pi * 1.7 - stepValue * 0.8 * math.pi,
        arcSweep = value != null
            ? value.clamp(0.0, 1.0) * _sweep
            : math.max(headValue * 3 / 2 * math.pi - tailValue * 3 / 2 * math.pi, _epsilon);

  final Color? backgroundColor;
  final Color valueColor;
  final double? value;
  final double headValue;
  final double tailValue;
  final int stepValue;
  final double rotationValue;
  final double arcStart;
  final double arcSweep;

  static const double _twoPi = math.pi * 2.0;
  static const double _epsilon = .001;
  // Canvas.drawArc(r, 0, 2*PI) doesn't draw anything, so just get close.
  static const double _sweep = _twoPi - _epsilon;
  static const double _startAngle = -math.pi / 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = valueColor
      ..style = PaintingStyle.fill;

    final backgroundColor = this.backgroundColor;
    if (backgroundColor != null) {
      final Paint backgroundPaint = Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.fill;
      canvas.drawArc(Offset.zero & size, 0, _sweep, true, backgroundPaint);
    }

    if (value == null) {
      paint.strokeCap = StrokeCap.square;
    }

    canvas.drawArc(Offset.zero & size, arcStart, arcSweep, true, paint);
  }

  @override
  bool shouldRepaint(_CircularProgressIndicatorPainter oldPainter) {
    return oldPainter.backgroundColor != backgroundColor ||
        oldPainter.valueColor != valueColor ||
        oldPainter.value != value ||
        oldPainter.headValue != headValue ||
        oldPainter.tailValue != tailValue ||
        oldPainter.stepValue != stepValue ||
        oldPainter.rotationValue != rotationValue;
  }
}
