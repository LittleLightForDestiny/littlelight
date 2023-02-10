import 'package:bungie_api/enums/destiny_item_type.dart';
import 'package:bungie_api/enums/item_state.dart';
import 'package:bungie_api/enums/tier_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/mixins/deepsight_helper.mixin.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/shared/utils/extensions/tier_type_data.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateless_item.widget.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/widgets/common/corner_badge.decoration.dart';
import 'package:little_light/widgets/common/item_icon/engram_icon.widget.dart';
import 'package:little_light/widgets/common/item_icon/subclass_icon.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:shimmer/shimmer.dart';

class ItemIconWidget extends BaseDestinyStatelessItemWidget with DeepSightHelper {
  final double iconBorderWidth;

  factory ItemIconWidget.builder(
      {DestinyItemComponent? item,
      required DestinyInventoryItemDefinition? definition,
      DestinyItemInstanceComponent? instanceInfo,
      Key? key,
      double iconBorderWidth = 2}) {
    switch (definition?.itemType) {
      case DestinyItemType.Subclass:
        return SubclassIconWidget(item, definition, instanceInfo, key: key);

      case DestinyItemType.Engram:
        return EngramIconWidget(item, definition, instanceInfo, key: key);

      default:
        return ItemIconWidget(item, definition, instanceInfo, key: key, iconBorderWidth: iconBorderWidth);
    }
  }

  ItemIconWidget(DestinyItemComponent? item, DestinyInventoryItemDefinition? definition,
      DestinyItemInstanceComponent? instanceInfo,
      {Key? key, String? characterId, this.iconBorderWidth = 2})
      : super(item: item, definition: definition, instanceInfo: instanceInfo, key: key, characterId: characterId);

  @override
  Widget build(BuildContext context) {
    final tierType = definition?.inventory?.tierType;
    bool useBackgroundColor = true;
    if ([DestinyItemType.Subclass, DestinyItemType.Engram].contains(definition?.itemType) ||
        definition?.inventory?.bucketTypeHash == InventoryBucket.subclass) {
      useBackgroundColor = false;
    }

    return Stack(children: [
      Positioned.fill(
          child: Container(
              color: useBackgroundColor && tierType != null ? tierType.getColor(context) : null,
              child: itemIconImage(context))),
      itemSeasonIcon(context),
      Positioned.fill(child: itemStateOverlay(context)),
    ]);
  }

  Widget masterworkOverlay(BuildContext context) {
    final tierType = definition?.inventory?.tierType;
    final isExotic = tierType == TierType.Exotic;
    final imgPath = isExotic ? "assets/imgs/masterwork-outline-exotic.png" : "assets/imgs/masterwork-outline.png";
    final img = Image.asset(
      imgPath,
      fit: BoxFit.cover,
    );
    final masterworkLayers = LittleLightTheme.of(context).achievementLayers;
    return Stack(children: [
      img,
      Positioned.fill(
          child: Shimmer.fromColors(
        baseColor: masterworkLayers.withOpacity(.2),
        highlightColor: masterworkLayers.layer3,
        period: const Duration(seconds: 5),
        child: img,
      ))
    ]);
  }

  Widget itemStateOverlay(BuildContext context) {
    if ([InventoryBucket.engrams, InventoryBucket.subclass].contains(item?.bucketHash)) {
      return Container();
    }
    ItemState state = item?.state ?? ItemState.None;
    if (state.contains(ItemState.Masterwork)) {
      return masterworkOverlay(context);
    }
    if (state.contains(ItemState.HighlightedObjective)) {
      return deepsightOverlay(context);
    }
    if (state.contains(ItemState.Crafted)) {
      return craftedWeaponOverlay(context);
    }
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: LittleLightTheme.of(context).onSurfaceLayers, width: iconBorderWidth)),
    );
  }

  Widget deepsightOverlay(BuildContext context) {
    final color = LittleLightTheme.of(context).highlightedObjectiveLayers;
    final instanceID = item?.itemInstanceId;
    if (instanceID == null) return Container();
    final isComplete = isDeepSightObjectiveCompleted(instanceID);
    return LayoutBuilder(
        builder: (context, constraints) => Container(
            decoration: BoxDecoration(
              border:
                  Border.all(color: LittleLightTheme.of(context).highlightedObjectiveLayers, width: iconBorderWidth),
            ),
            child: Stack(children: [
              Container(
                  decoration: CornerBadgeDecoration(
                colors: [color],
                badgeSize: constraints.maxWidth * .4,
                position: CornerPosition.BottomLeft,
              )),
              if (isComplete)
                Positioned(
                    bottom: 0,
                    left: constraints.maxWidth * .07,
                    child: Text(
                      "!",
                      style:
                          LittleLightTheme.of(context).textTheme.button.copyWith(fontSize: constraints.maxWidth * .2),
                    ))
            ])));
  }

  Widget craftedWeaponOverlay(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(color: LittleLightTheme.of(context).onSurfaceLayers, width: iconBorderWidth)),
        child: Image.asset(
          "assets/imgs/crafted-icon-overlay.png",
          fit: BoxFit.fill,
        ));
  }

  String? seasonBadgeUrl() {
    final versionNumber = item?.versionNumber;
    if (versionNumber == null) return null;
    var version = definition?.quality?.displayVersionWatermarkIcons?[versionNumber];
    if (version?.isNotEmpty ?? false) return version;
    return null;
  }

  Widget itemSeasonIcon(BuildContext context) {
    final badgeURL = seasonBadgeUrl();
    if (badgeURL != null) {
      return QueuedNetworkImage.fromBungie(
        badgeURL,
        fit: BoxFit.fill,
        placeholder: itemIconPlaceholder(context),
      );
    }
    return Container();
  }

  Widget itemIconImage(BuildContext context) {
    final overrideStyleItemHash = item?.overrideStyleItemHash;
    if (overrideStyleItemHash != null) {
      return ManifestImageWidget<DestinyInventoryItemDefinition>(
        overrideStyleItemHash,
        fit: BoxFit.fill,
        placeholder: itemIconPlaceholder(context),
      );
    }
    return ManifestImageWidget<DestinyInventoryItemDefinition>(
      definition?.hash,
      fit: BoxFit.fill,
      placeholder: itemIconPlaceholder(context),
    );
  }

  Widget itemIconPlaceholder(BuildContext context) {
    return Container();
  }
}
