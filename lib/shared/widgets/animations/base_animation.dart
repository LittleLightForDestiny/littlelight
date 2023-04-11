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
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void dispose() {
    controller.stop();
    controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (controller.duration != widget.duration) {
      controller.duration = widget.duration;
    }
    updateAnimation(controller);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(controller);
  }

  void updateAnimation(AnimationController controller);
}
