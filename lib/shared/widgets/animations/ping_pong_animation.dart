import 'package:flutter/material.dart';
import 'base_animation.dart';

class PingPongAnimationBuilder extends BaseAnimationBuilder {
  final bool playing;
  const PingPongAnimationBuilder(
    AnimationBuilder builder, {
    this.playing = false,
    Duration duration = const Duration(milliseconds: 300),
  }) : super(builder, duration: duration);

  @override
  State<BaseAnimationBuilder> createState() => PingPongAnimationBuilderState();
}

class PingPongAnimationBuilderState extends BaseAnimationBuilderState<PingPongAnimationBuilder> {
  @override
  void initState() {
    super.initState();
    controller.addListener(directionListener);
  }

  void directionListener() {
    if (!widget.playing) return;
    if (controller.value <= 0) controller.animateTo(1.0, duration: widget.duration);
    if (controller.value >= 1) controller.animateBack(0, duration: widget.duration);
  }

  @override
  void updateAnimation(AnimationController controller) {
    if (widget.playing) {
      controller.animateTo(1.0);
    }
  }
}
