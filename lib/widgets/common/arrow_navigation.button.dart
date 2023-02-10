// @dart=2.9

import 'package:flutter/material.dart';

class ArrowNavigationButton extends StatelessWidget {
  final TabController controller;
  final IconData icon;
  final int index;

  const ArrowNavigationButton({Key key, this.controller, @required this.icon, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = CurvedAnimation(
      parent: controller.animation,
      curve: Curves.fastOutSlowIn,
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) => buildArrow(context),
    );
  }

  Widget buildArrow(BuildContext context) {
    double value = index.toDouble() - controller.animation.value;
    value = value.abs().clamp(0.0, 1.0);
    bool enabled = value > 0.5;
    return Opacity(
        opacity: 0.5 + 0.5 * value,
        child: Material(
            color: Theme.of(context).primaryTextTheme.button.color.withOpacity(.3),
            child: InkWell(
              onTap: enabled
                  ? () {
                      var direction = controller.index > index ? -1 : 1;
                      var page = controller.index + direction;
                      controller.animateTo(page.clamp(0, controller.length));
                    }
                  : null,
              child: Icon(
                icon,
                color: Theme.of(context).primaryTextTheme.button.color,
              ),
            )));
  }
}
