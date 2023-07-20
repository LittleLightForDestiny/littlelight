import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:little_light/shared/blocs/bucket_options/bucket_options.bloc.dart';
import 'package:little_light/shared/utils/extensions/bucket_display_type_data.dart';
import 'package:little_light/shared/widgets/overlay/base_overlay_widget.dart';
import 'package:provider/provider.dart';

class BucketDisplayOptionsOverlayMenuView extends BaseOverlayWidget {
  final bool canEquip;
  final List<BucketDisplayType> availableOptions;
  final String identifier;
  final BucketDisplayType defaultValue;

  const BucketDisplayOptionsOverlayMenuView({
    Key? key,
    required GlobalKey buttonKey,
    this.canEquip = false,
    required this.availableOptions,
    required Animation animation,
    required this.defaultValue,
    required this.identifier,
  }) : super(canDismissOnBackground: true, key: key, buttonKey: buttonKey, animation: animation);

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
    final currentValue = context.watch<ItemSectionOptionsBloc>().getDisplayTypeForItemSection(
          identifier,
          defaultValue: defaultValue,
        );
    final selectedIndex = availableOptions.indexOf(currentValue).clamp(0, availableOptions.length - 1);
    double top = sourceTop - 2 - itemSize * selectedIndex;
    final height = itemSize * availableOptions.length;
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
              children: availableOptions
                  .map(
                    (option) => SizedBox(
                      height: itemSize,
                      child: BucketDisplayMenuOptionWidget(
                        option,
                        canEquip: canEquip,
                        onTap: () {
                          Navigator.of(context).pop(option);
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
