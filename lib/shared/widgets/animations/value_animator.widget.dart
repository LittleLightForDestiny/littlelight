import 'package:flutter/material.dart';

typedef _Builder = Widget Function(BuildContext context, double value, Widget? child);

class ValueAnimatorWidget extends StatefulWidget {
  final double value;
  final _Builder builder;
  final Widget? child;

  final Duration duration;

  const ValueAnimatorWidget({
    Key? key,
    required this.value,
    required this.builder,
    this.child,
    this.duration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  _ValueAnimatorWidgetState createState() => _ValueAnimatorWidgetState();
}

class _ValueAnimatorWidgetState extends State<ValueAnimatorWidget> with TickerProviderStateMixin {
  late AnimationController animation;
  @override
  void initState() {
    super.initState();
    animation = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ValueAnimatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    this.animation.animateTo(widget.value, duration: widget.duration);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: this.animation,
      builder: (context, child) {
        return widget.builder(context, animation.value, child);
      },
      child: widget.child,
    );
  }
}
