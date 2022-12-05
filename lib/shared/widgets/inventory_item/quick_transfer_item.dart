import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';

class QuickTransferItem extends StatelessWidget {
  final double borderWidth;
  const QuickTransferItem({Key? key, this.borderWidth = 2}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        buildBackground(context),
        buildInkwell(context),
      ],
    );
  }

  Widget buildBackground(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        color: context.theme?.surfaceLayers.layer1,
        border: Border.all(
          width: borderWidth,
          color: context.theme?.onSurfaceLayers.layer3 ?? Colors.transparent,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.add_circle_outline,
          color: context.theme?.onSurfaceLayers.layer3,
        ),
      ),
    );
  }

  Widget buildInkwell(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        onLongPress: () {},
      ),
    );
  }
}
