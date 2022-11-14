import 'package:flutter/material.dart';

typedef AnimationBuilder = Widget Function(AnimationController controller);

abstract class BaseAnimationBuilder extends StatefulWidget {
  final Duration duration;
  final AnimationBuilder builder;

  const BaseAnimationBuilder(
    this.builder, {
    Key? key,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);
  @override
  State<BaseAnimationBuilder> createState();
}

abstract class BaseAnimationBuilderState<T extends BaseAnimationBuilder> extends State<T>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    updateAnimation(_controller);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_controller);
  }

  void updateAnimation(AnimationController controller);
}
