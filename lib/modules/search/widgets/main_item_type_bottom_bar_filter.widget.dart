import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/search/blocs/filter_options/main_item_type_filter_options.dart';
import 'package:little_light/modules/search/widgets/drawer_filters/base_drawer_filter.widget.dart';
import 'package:little_light/modules/search/widgets/drawer_filters/base_filter.widget.dart';
import 'package:little_light/shared/utils/helpers/bucket_type_groups.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

const _weaponIconPresentationNodeHash = 2214408526;
const _armorIconPresentationNodeHash = 615947643;
const _otherIconPresentationNodeHash = 3517356538;
const iconWidth = 92.0;
const _animationDuration = const Duration(milliseconds: 300);

class MainItemTypeBottomBarFilterWidget extends BaseFilterWidget<MainItemTypeFilterOptions> {
  MainItemTypeBottomBarFilterWidget({Key? key}) : super();

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }

  @override
  Widget buildWithData(BuildContext context, MainItemTypeFilterOptions data) {
    final bottomPadding = context.mediaQuery.viewPadding.bottom;
    return Container(
      height: bottomPadding + kToolbarHeight,
      decoration: BoxDecoration(
          color: context.theme.surfaceLayers,
          border: Border(top: BorderSide(width: .5, color: context.theme.surfaceLayers.layer3))),
      child: Row(
          children: EquipmentBucketGroup.values //
              .map((type) => buildButton(
                    context,
                    type: type,
                    selected: data.value.contains(type),
                    onTap: () => updateOption(context, data, type, false),
                    onHold: () => updateOption(context, data, type, true),
                  ))
              .toList()),
    );
  }

  Widget buildButton(
    BuildContext context, {
    required EquipmentBucketGroup type,
    required bool selected,
    required VoidCallback onTap,
    required VoidCallback onHold,
  }) {
    final mq = MediaQuery.of(context);
    return Stack(children: [
      Positioned.fill(child: buildSelectedBackground(context, selected)),
      Container(
        width: iconWidth,
        padding: const EdgeInsets.all(4) + EdgeInsets.only(bottom: mq.viewPadding.bottom),
        child: AnimatedOpacity(
          duration: _animationDuration,
          opacity: selected ? 1 : .7,
          child: buildIcon(context, type),
        ),
      ),
      Positioned(
        child: buildSelectedIndicator(context, selected),
        top: 0,
        left: 0,
        right: 0,
      ),
      Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onHold,
          ),
        ),
      ),
    ]);
  }

  Widget buildIcon(BuildContext context, EquipmentBucketGroup type) {
    switch (type) {
      case EquipmentBucketGroup.Weapons:
        return ManifestImageWidget<DestinyPresentationNodeDefinition>(
          _weaponIconPresentationNodeHash,
          color: context.theme.onSurfaceLayers,
        );
      case EquipmentBucketGroup.Armor:
        return ManifestImageWidget<DestinyPresentationNodeDefinition>(
          _armorIconPresentationNodeHash,
          color: context.theme.onSurfaceLayers,
        );
      case EquipmentBucketGroup.Inventory:
        return ManifestImageWidget<DestinyPresentationNodeDefinition>(
          _otherIconPresentationNodeHash,
          color: context.theme.onSurfaceLayers,
        );
    }
  }

  Widget buildSelectedBackground(BuildContext context, bool selected) {
    return AnimatedOpacity(
      duration: _animationDuration,
      opacity: selected ? 1 : 0,
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [
            context.theme.surfaceLayers.layer2,
            context.theme.surfaceLayers.layer2.withOpacity(0),
          ],
          end: Alignment.bottomCenter,
        )),
      ),
    );
  }

  Widget buildSelectedIndicator(BuildContext context, bool selected) {
    return AnimatedFractionallySizedBox(
      duration: _animationDuration,
      widthFactor: selected ? 1 : 0,
      child: Container(
        height: 2,
        color: Colors.white,
      ),
    );
  }
}
