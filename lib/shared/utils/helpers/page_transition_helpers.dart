import 'package:flutter/material.dart';

extension PageTransitionHelpers on BuildContext {
  Future<void> waitForPageTransitionToFinish() async {
    await Future.delayed(Duration(milliseconds: 1));
    final modalRouteAnimation = ModalRoute.of(this)?.animation;
    if (modalRouteAnimation != null) {
      while (!modalRouteAnimation.isCompleted) {
        await Future.delayed(Duration(milliseconds: 10));
      }
    }
  }
}
