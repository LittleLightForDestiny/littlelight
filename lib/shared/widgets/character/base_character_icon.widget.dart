import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';

const characterIconDefaultFontSize = 10.0;
const characterIconDefaultBorderWidth = 1.5;

abstract class BaseCharacterIconWidget extends StatelessWidget {
  final double borderWidth;
  final double fontSize;
  final bool hideName;

  const BaseCharacterIconWidget({
    Key? key,
    this.borderWidth = characterIconDefaultBorderWidth,
    this.hideName = false,
    this.fontSize = characterIconDefaultFontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = context.textTheme.highlight.copyWith(fontSize: fontSize);
    final name = getName(context)?.toUpperCase();
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
      if (name != null && name.isNotEmpty && !hideName)
        Positioned(
          left: borderWidth * 3,
          right: borderWidth * 3,
          bottom: borderWidth * 2,
          child: Text(
            name,
            style: textStyle.copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3),
            textAlign: TextAlign.center,
            softWrap: false,
          ),
        ),
      if (name != null && name.isNotEmpty && !hideName)
        Positioned(
          left: borderWidth * 3,
          right: borderWidth * 3,
          bottom: borderWidth * 2,
          child: Text(
            name,
            style: textStyle,
            textAlign: TextAlign.center,
            softWrap: false,
          ),
        ),
    ]);
  }

  Widget buildIcon(BuildContext context);

  String? getName(BuildContext context);
}
