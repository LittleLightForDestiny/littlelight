import 'package:flutter/material.dart';
import 'base_animation.dart';

class PingPongAnimationBuilder extends BaseAnimationBuilder {
  final double position;

  const PingPongAnimationBuilder(
    AnimationBuilder builder, {
    Key? key,
    this.position = 0.0,
    Duration duration = const Duration(milliseconds: 300),
  }) : super(builder, key: key, duration: duration);

  @override
  PingPongAnimationBuilderState createState() =>
      PingPongAnimationBuilderState();
}

class PingPongAnimationBuilderState
    extends BaseAnimationBuilderState<PingPongAnimationBuilder> {
  @override
  void updateAnimation(AnimationController controller) {
    controller.animateTo(widget.position);
  }
}
