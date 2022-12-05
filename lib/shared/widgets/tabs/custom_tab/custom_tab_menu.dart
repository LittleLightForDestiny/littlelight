import 'package:flutter/material.dart';
import 'package:little_light/shared/widgets/tabs/custom_tab/custom_tab.dart';

abstract class CustomTabMenu extends StatelessWidget {
  final Axis direction;
  final CustomTabController controller;

  double getButtonSize(BuildContext context);

  CustomTabMenu(this.controller, {this.direction = Axis.horizontal});

  @override
  Widget build(BuildContext context) {
    if (this.direction == Axis.vertical) {
      return buildVertical(context);
    }
    return buildHorizontal(context);
  }

  Widget buildVertical(BuildContext context) {
    final itemSize = getButtonSize(context);
    return Stack(children: [
      Positioned(
        right: 0,
        left: 0,
        top: 0,
        height: itemSize * controller.length,
        child: buildSelectedBackgroundAnimation(context, itemSize),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(
          controller.length,
          (index) => buildAnimatedButton(context, index, itemSize),
        ),
      ),
      Positioned(
        right: 0,
        left: 0,
        top: 0,
        height: itemSize * controller.length,
        child: buildSelectedIndicatorAnimation(context, itemSize),
      ),
    ]);
  }

  Widget buildHorizontal(BuildContext context) {
    final itemWidth = getButtonSize(context);
    return Stack(children: [
      Positioned(
        left: 0,
        top: 0,
        bottom: 0,
        width: itemWidth * controller.length,
        child: buildSelectedBackgroundAnimation(context, itemWidth),
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(
          controller.length,
          (index) => buildAnimatedButton(context, index, itemWidth),
        ),
      ),
      Positioned(
        left: 0,
        top: 0,
        bottom: 0,
        width: itemWidth * controller.length,
        child: buildSelectedIndicatorAnimation(context, itemWidth),
      ),
    ]);
  }

  Alignment getIndicatorAlignment(BuildContext context) {
    return direction == Axis.vertical
        ? Alignment(0, controller.animation.value - 1)
        : Alignment(controller.animation.value - 1, 0);
  }

  Widget buildSelectedIndicatorAnimation(BuildContext context, double buttonSize) {
    final child = buildSelectedIndicator(context);
    if (child == null) return Container();
    return AnimatedBuilder(
      animation: controller.animation,
      builder: (context, child) => Container(
        alignment: getIndicatorAlignment(context),
        child: child,
      ),
      child: Container(
        width: direction == Axis.horizontal ? buttonSize : null,
        height: direction == Axis.vertical ? buttonSize : null,
        child: child,
      ),
    );
  }

  Widget? buildSelectedIndicator(BuildContext context);

  Widget buildSelectedBackgroundAnimation(BuildContext context, double buttonSize) {
    final child = buildSelectedBackground(context);
    if (child == null) return Container();
    return AnimatedBuilder(
      animation: controller.animation,
      builder: (context, child) => Container(
        alignment: getIndicatorAlignment(context),
        child: child,
      ),
      child: Container(
        width: direction == Axis.horizontal ? buttonSize : null,
        height: direction == Axis.vertical ? buttonSize : null,
        child: child,
      ),
    );
  }

  Widget? buildSelectedBackground(BuildContext context);

  Widget buildAnimatedButton(BuildContext context, int index, double buttonSize) {
    return Stack(children: [
      AnimatedBuilder(
        animation: controller.animation,
        builder: (context, child) => Container(
          width: direction == Axis.horizontal ? buttonSize : null,
          height: direction == Axis.vertical ? buttonSize : null,
          child: buildButton(context, index),
        ),
      ),
      Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              onItemSelect(index);
            },
          ),
        ),
      ),
    ]);
  }

  void onItemSelect(int index) {
    controller.goToPage(index);
  }

  Widget buildButton(BuildContext context, int index);
}
