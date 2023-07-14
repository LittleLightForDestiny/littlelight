import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';

class MenuBox extends StatelessWidget {
  final Color? backgroundColor;
  final Widget child;

  const MenuBox({Key? key, required this.child, this.backgroundColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: context.theme.secondarySurfaceLayers.layer3,
            blurRadius: 3,
          )
        ],
        borderRadius: BorderRadius.circular(4),
        color: getBackgroundColor(context),
      ),
      padding: EdgeInsets.all(4),
      margin: EdgeInsets.only(bottom: 8),
      child: child,
    );
  }

  Color getBackgroundColor(BuildContext context) => backgroundColor ?? context.theme.surfaceLayers.layer3;
}
