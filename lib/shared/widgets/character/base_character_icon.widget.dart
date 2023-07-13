import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:bungie_api/src/enums/destiny_class.dart';

const characterIconDefaultBorderWidth = 1.5;

abstract class BaseCharacterIconWidget extends StatelessWidget {
  final double borderWidth;
  final bool hideClassIcon;

  const BaseCharacterIconWidget({
    Key? key,
    this.borderWidth = characterIconDefaultBorderWidth,
    this.hideClassIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final classType = getClassType(context);
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
      if (!hideClassIcon && classType == DestinyClass.Titan)
        Positioned(
          left: borderWidth * 2,
          bottom: borderWidth * 1,
          child: Container(child: Image.asset("assets/imgs/class_titan_bordered.png", scale: 1.0)),
        ),
      if (!hideClassIcon && classType == DestinyClass.Warlock)
        Positioned(
          left: borderWidth * 1,
          bottom: borderWidth * 2,
          child: Container(child: Image.asset("assets/imgs/class_warlock_bordered.png", scale: 1.0)),
        ),
      if (!hideClassIcon && classType == DestinyClass.Hunter)
        Positioned(
          left: borderWidth * 2,
          bottom: borderWidth * 2,
          child: Container(child: Image.asset("assets/imgs/class_hunter_bordered.png", scale: 1.0)),
        )
    ]);
  }

  Widget buildIcon(BuildContext context);

  DestinyClass? getClassType(BuildContext context) => null;
}
