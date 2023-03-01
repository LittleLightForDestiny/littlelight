import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';

abstract class BaseCharacterIconWidget extends StatelessWidget {
  final double borderWidth;

  const BaseCharacterIconWidget({Key? key, this.borderWidth = 1.5})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: borderWidth > 0
            ? Border.all(
                width: borderWidth,
                color: context.theme.onSurfaceLayers.layer0,
              )
            : null,
      ),
      child: buildIcon(context),
    );
  }

  Widget buildIcon(BuildContext context);
}
