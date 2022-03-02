import 'package:bungie_api/enums/destiny_item_type.dart';
import 'package:bungie_api/enums/item_state.dart';
import 'package:bungie_api/enums/tier_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateless_item.widget.dart';
import 'package:little_light/widgets/common/item_icon/engram_icon.widget.dart';
import 'package:little_light/widgets/common/item_icon/subclass_icon.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:shimmer/shimmer.dart';

class ItemIconWidget extends BaseDestinyStatelessItemWidget {
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
    ItemState state = item?.state ?? ItemState.None;
    if (state.contains(ItemState.Masterwork)) {}
    final tierType = definition?.inventory?.tierType;
    bool useBackgroundColor = true;
    if ([DestinyItemType.Subclass, DestinyItemType.Engram].contains(definition?.itemType) ||
        definition?.inventory?.bucketTypeHash == InventoryBucket.subclass) {
      useBackgroundColor = false;
    }

    return Stack(children: [
      Positioned.fill(
          child: Container(
              color: useBackgroundColor && tierType != null ? DestinyData.getTierColor(tierType) : null,
              child: itemIconImage(context))),
      itemSeasonIcon(context),
      itemDeepSightIcon(),
      Positioned.fill(
          child: state.contains(ItemState.Masterwork)
              ? getMasterworkOutline()
              : state.contains(ItemState.HighlightedObjective)
                  ? Container(
                      decoration: highlightedObjectiveBoxDecoration(context),
                    )
                  : Container(
                      decoration: iconBoxDecoration(),
                    )),
      state.contains(ItemState.Masterwork)
          ? Positioned.fill(
              child: Shimmer.fromColors(
              baseColor: Colors.amber.withOpacity(.2),
              highlightColor: Colors.amber.shade100,
              child: getMasterworkOutline(),
              period: Duration(seconds: 5),
            ))
          : Container()
    ]);
  }

  Widget itemDeepSightIcon() {
    if (item?.state?.contains(ItemState.Crafted) ?? false) {
      return Image.asset(
        "assets/imgs/crafted-icon-overlay.png",
        fit: BoxFit.fill,
      );
    }
    return Container();
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

  BoxDecoration? highlightedObjectiveBoxDecoration(BuildContext context) {
    if ([InventoryBucket.engrams, InventoryBucket.subclass].contains(item?.bucketHash)) {
      return null;
    }
    return BoxDecoration(
        border: Border.all(color: LittleLightTheme.of(context).highlightedObjectiveLayers, width: iconBorderWidth));
  }

  BoxDecoration? iconBoxDecoration() {
    if ([InventoryBucket.engrams, InventoryBucket.subclass].contains(item?.bucketHash)) {
      return null;
    }
    return BoxDecoration(border: Border.all(color: Colors.grey.shade300, width: iconBorderWidth));
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

  Widget getMasterworkOutline() {
    final tierType = definition?.inventory?.tierType;
    if (tierType == null) return Container();
    if (tierType == TierType.Exotic) {
      return Image.asset(
        "assets/imgs/masterwork-outline-exotic.png",
        fit: BoxFit.cover,
      );
    }
    return Image.asset(
      "assets/imgs/masterwork-outline.png",
      fit: BoxFit.cover,
    );
  }
}
