import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';

typedef OnButtonTap = void Function();

class FilterButtonWidget extends StatelessWidget {
  final Widget child;
  final bool selected;
  final OnButtonTap? onTap;
  final OnButtonTap? onLongPress;
  final Widget? background;
  const FilterButtonWidget(
    this.child, {
    Key? key,
    this.selected = false,
    this.onTap,
    this.onLongPress,
    this.background,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final background = this.background;
    return Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: context.theme.surfaceLayers.layer3,
          borderRadius: BorderRadius.circular(4),
        ),
        child: ClipRRect(
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                if (background != null) Positioned.fill(child: background),
                Material(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.transparent,
                    child: InkWell(
                      enableFeedback: false,
                      onTap: onTap,
                      onLongPress: onLongPress,
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: context.theme.onSurfaceLayers.layer0,
                                width: 3,
                                style: selected ? BorderStyle.solid : BorderStyle.none)),
                        constraints: const BoxConstraints(minWidth: double.infinity),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(4),
                        child: DefaultTextStyle(style: context.textTheme.button, child: child),
                      ),
                    )),
              ],
            )));
  }
}
