import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:little_light/shared/utils/extensions/bucket_display_type_data.dart';
import 'package:little_light/shared/widgets/overlay/base_overlay_widget.dart';

typedef OnSelectDisplayOption = void Function(BucketDisplayType? type);

const _options = BucketDisplayType.values;

class BucketDisplayOptionsOverlayMenu extends BaseOverlayWidget {
  final OnSelectDisplayOption? onSelect;
  final BucketDisplayType currentValue;
  final bool canEquip;
  final Set<BucketDisplayType> availableOptions;

  const BucketDisplayOptionsOverlayMenu({
    Key? key,
    required this.currentValue,
    required RenderBox sourceRenderBox,
    required GlobalKey buttonKey,
    this.onSelect,
    this.canEquip = false,
    required Set<BucketDisplayType> this.availableOptions,
  }) : super(
          canDismissOnBackground: true,
          key: key,
          buttonKey: buttonKey,
        );

  @override
  Widget buildOverlay(
    BuildContext context, {
    required double sourceTop,
    required double sourceLeft,
    required double sourceBottom,
    required double sourceRight,
    required BoxConstraints constraints,
  }) {
    const itemSize = 52.0;
    final selectedIndex = _options.indexOf(currentValue).clamp(0, _options.length - 1);
    double top = sourceTop - 2 - itemSize * selectedIndex;
    final height = itemSize * _options.length;
    if (top + height > constraints.maxHeight) {
      final difference = ((top + height - constraints.maxHeight) / itemSize).ceil();
      top = sourceTop - 2 - itemSize * (selectedIndex + difference);
    }
    if (top < 0) {
      final difference = (top / itemSize).floor();
      top = sourceTop - 2 - itemSize * (selectedIndex + difference);
    }
    final canEquip = availableOptions.contains(BucketDisplayType.OnlyEquipped);
    return Stack(children: [
      Positioned(
          right: sourceRight - 4,
          top: top,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _options
                  .where((option) => availableOptions.contains(option))
                  .map(
                    (option) => SizedBox(
                      height: itemSize,
                      child: BucketDisplayMenuOptionWidget(
                        option,
                        canEquip: canEquip,
                        onTap: () {
                          onSelect?.call(option);
                        },
                        isSelected: option == currentValue,
                      ),
                    ),
                  )
                  .toList()))
    ]);
  }
}

class BucketDisplayMenuOptionWidget extends StatelessWidget {
  final BucketDisplayType option;
  final void Function()? onTap;
  final bool isSelected;
  final bool canEquip;

  const BucketDisplayMenuOptionWidget(
    this.option, {
    Key? key,
    this.isSelected = false,
    this.onTap,
    this.canEquip = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(4),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? context.theme.primaryLayers.layer0 : context.theme.surfaceLayers.layer1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(option.name),
                Container(
                  width: 8,
                ),
                Container(
                  width: 48,
                  alignment: Alignment.center,
                  child: Icon(
                    canEquip ? option.equippableIcon : option.nonEquippableIcon,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
