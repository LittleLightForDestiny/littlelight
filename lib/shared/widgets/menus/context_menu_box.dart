import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';

class ContextMenuBox extends StatelessWidget {
  final Widget child;

  const ContextMenuBox({Key? key, required this.child}) : super(key: key);

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
        color: context.theme.surfaceLayers.layer3,
      ),
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(bottom: 8),
      child: child,
    );
  }
}
