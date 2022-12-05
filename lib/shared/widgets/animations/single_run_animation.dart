import 'package:flutter/material.dart';
import 'base_animation.dart';

class SingleRunAnimationBuilder extends BaseAnimationBuilder {
  final double from;
  final double to;

  const SingleRunAnimationBuilder(
    AnimationBuilder builder, {
    Key? key,
    this.from = 0.0,
    this.to = 1.0,
    Duration duration = const Duration(milliseconds: 300),
  }) : super(builder, key: key, duration: duration);

  @override
  SingleRunAnimationBuilderState createState() => SingleRunAnimationBuilderState();
}

class SingleRunAnimationBuilderState extends BaseAnimationBuilderState<SingleRunAnimationBuilder> {
  @override
  void initState() {
    super.initState();
    controller.animateTo(widget.to);
  }

  @override
  void updateAnimation(AnimationController controller) {}
}
