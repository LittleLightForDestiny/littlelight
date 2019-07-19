import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final LinearGradient begin;
  final LinearGradient end;

  const AnimatedBackground({
    Key key,
    @required this.begin,
    @required this.end,
  }) : super(key: key);

  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>  with SingleTickerProviderStateMixin<AnimatedBackground>{
  Animation<LinearGradient> _animation;
   AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _animation = LinearGradientTween(
      begin: widget.begin,
      end: widget.end,
    ).animate(_controller);
    _controller.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: _animation.value,
          ),
        );
      },
    );
  }
}

/// An interpolation between two LinearGradients.
///
/// This class specializes the interpolation of [Tween] to use
/// [LinearGradient.lerp].
///
/// See [Tween] for a discussion on how to use interpolation objects.
class LinearGradientTween extends Tween<LinearGradient> {
  /// Provide a begin and end Gradient. To fade between.
  LinearGradientTween({
    LinearGradient begin,
    LinearGradient end,
  }) : super(begin: begin, end: end);

  @override
  LinearGradient lerp(double t) => LinearGradient.lerp(begin, end, t);
}