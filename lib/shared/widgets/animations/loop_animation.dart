import 'package:flutter/material.dart';
import 'base_animation.dart';

class LoopAnimationBuilder extends BaseAnimationBuilder {
  final bool playing;
  const LoopAnimationBuilder(
    AnimationBuilder builder, {
    this.playing = false,
    Duration duration = const Duration(milliseconds: 300),
  }) : super(builder, duration: duration);

  @override
  State<BaseAnimationBuilder> createState() => LoopAnimationBuilderState();
}

class LoopAnimationBuilderState extends BaseAnimationBuilderState<LoopAnimationBuilder> {
  @override
  void updateAnimation(AnimationController controller) {
    if (widget.playing) {
      controller.repeat();
    } else {
      controller.animateTo(1.0);
    }
  }
}
