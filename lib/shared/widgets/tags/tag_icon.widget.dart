import 'package:flutter/material.dart';
import 'package:little_light/models/item_notes_tag.dart';

const _defaultTagSize = 24.0;
const _defaultBorderWidth = 1.0;

class TagIconWidget extends StatelessWidget {
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final double size;
  final double borderWidth;

  factory TagIconWidget.fromTag(
    ItemNotesTag tag, {
    double size = _defaultTagSize,
    double borderWidth = _defaultBorderWidth,
  }) {
    return TagIconWidget(
      backgroundColor: tag.backgroundColor,
      foregroundColor: tag.foregroundColor,
      icon: tag.iconData,
      size: size,
      borderWidth: borderWidth,
    );
  }

  const TagIconWidget({
    Key? key,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.size = _defaultTagSize,
    this.borderWidth = _defaultBorderWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(size),
          border: Border.all(
            width: borderWidth,
            color: foregroundColor ?? backgroundColor ?? Colors.transparent,
          ),
        ),
        child: Icon(
          icon,
          size: size * .6,
          color: foregroundColor,
        ),
      );
}
