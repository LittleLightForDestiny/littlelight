// @dart=2.9

import 'package:flutter/material.dart';

class TabPageSelectorWidget extends StatelessWidget {
  final TabController controller;
  final _forwardTween = ColorTween(begin: Colors.grey.shade100, end: Colors.grey.shade100.withOpacity(.5));

  TabPageSelectorWidget({this.controller});

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = CurvedAnimation(
      parent: controller.animation,
      curve: Curves.fastOutSlowIn,
    );
    return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget child) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(controller.length, (index) => selector(context, index)),
            ));
  }

  selector(BuildContext context, int index) {
    double value = index.toDouble() - controller.animation.value;
    value = value.abs().clamp(0.0, 1.0);
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 8), width: 36, height: 4, color: _forwardTween.lerp(value));
  }
}
