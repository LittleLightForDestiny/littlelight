import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';

typedef OnButtonTap = void Function();

class FilterButtonWidget extends StatelessWidget {
  final bool selected;
  final Widget child;
  final OnButtonTap? onTap;
  final OnButtonTap? onLongPress;
  const FilterButtonWidget(
    this.child, {
    Key? key,
    this.selected = false,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
          color: context.theme.surfaceLayers.layer3,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
              color: context.theme.primaryLayers.layer0,
              width: 3,
              style: selected ? BorderStyle.solid : BorderStyle.none)),
      child: Material(
        borderRadius: BorderRadius.circular(4),
        color: Colors.transparent,
        child: InkWell(
          enableFeedback: false,
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            constraints: const BoxConstraints(minWidth: double.infinity),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(4),
            child: DefaultTextStyle(
              style: context.textTheme.button,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
