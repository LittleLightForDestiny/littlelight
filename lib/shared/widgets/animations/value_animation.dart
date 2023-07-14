import 'package:flutter/material.dart';
import 'base_animation.dart';

class ValueAnimationBuilder extends BaseAnimationBuilder {
  final double position;

  const ValueAnimationBuilder(
    AnimationBuilder builder, {
    Key? key,
    this.position = 0.0,
    Duration duration = const Duration(milliseconds: 300),
  }) : super(builder, key: key, duration: duration);

  @override
  ValueAnimationBuilderState createState() => ValueAnimationBuilderState();
}

class ValueAnimationBuilderState extends BaseAnimationBuilderState<ValueAnimationBuilder> {
  @override
  void initState() {
    super.initState();
    controller.animateTo(widget.position, duration: Duration.zero);
  }

  @override
  void updateAnimation(AnimationController controller) {
    controller.animateTo(widget.position);
  }
}
