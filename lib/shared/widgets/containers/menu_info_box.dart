import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';

class MenuInfoBox extends StatelessWidget {
  final Widget? child;

  const MenuInfoBox({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: context.theme.surfaceLayers.layer1,
      ),
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(bottom: 4),
      child: buildContent(context),
    );
  }

  Widget buildContent(BuildContext context) => DefaultTextStyle(
        child: child ?? Container(),
        style: context.textTheme.button,
      );
}
