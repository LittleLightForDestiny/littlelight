import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';

const characterIconDefaultBorderWidth = 1.5;

abstract class BaseCharacterIconWidget extends StatelessWidget {
  final double borderWidth;

  const BaseCharacterIconWidget({
    Key? key,
    this.borderWidth = characterIconDefaultBorderWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final overlays = buildOverlays(context);
    return Stack(children: [
      Container(
        decoration: BoxDecoration(
          border: borderWidth > 0
              ? Border.all(
                  width: borderWidth,
                  color: context.theme.onSurfaceLayers.layer0,
                )
              : null,
        ),
        child: buildIcon(context),
      ),
      if (overlays != null) ...overlays,
    ]);
  }

  List<Positioned>? buildOverlays(BuildContext context) => null;

  Widget buildIcon(BuildContext context);
}
