import 'package:bungie_api/enums/destiny_item_type.dart';
import 'package:bungie_api/enums/item_state.dart';
import 'package:bungie_api/enums/tier_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateless_item.widget.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/item_icon/engram_icon.widget.dart';
import 'package:little_light/widgets/common/item_icon/subclass_icon.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:shimmer/shimmer.dart';

class ItemIconWidget extends BaseDestinyStatelessItemWidget {
  final double iconBorderWidth;

  factory ItemIconWidget.builder(
      {DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      Key key,
      double iconBorderWidth = 2}) {
    switch (definition.itemType) {
      case DestinyItemType.Subclass:
        return SubclassIconWidget(item, definition, instanceInfo,
            key: key, iconBorderWidth: iconBorderWidth);

      case DestinyItemType.Engram:
        return EngramIconWidget(item, definition, instanceInfo,
            key: key, iconBorderWidth: iconBorderWidth);

      default:
        return ItemIconWidget(item, definition, instanceInfo,
            key: key, iconBorderWidth: iconBorderWidth);
    }
  }

  ItemIconWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      String characterId,
      this.iconBorderWidth = 2})
      : super(
            item: item,
            definition: definition,
            instanceInfo: instanceInfo,
            key: key,
            characterId: characterId);

  @override
  Widget build(BuildContext context) {
    ItemState state = item?.state ?? ItemState.None;
    if (state.contains(ItemState.Masterwork)) {}
    bool useBackgroundColor = true;
    if ([DestinyItemType.Subclass, DestinyItemType.Engram]
        .contains(definition?.itemType)) {
      useBackgroundColor = false;
    }
    return Stack(children: [
      Positioned.fill(
          child: Container(
              color: useBackgroundColor
                  ? DestinyData.getTierColor(definition.inventory.tierType)
                  : null,
              child: itemIconImage(context))),
      itemSeasonIcon(context),
      Positioned.fill(
          child: state.contains(ItemState.Masterwork)
              ? getMasterworkOutline()
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

  String seasonBadgeUrl(){
    try{
      return definition?.quality?.displayVersionWatermarkIcons?.first ?? "";
    }catch(_){}
    return "";
  }

  Widget itemSeasonIcon(BuildContext context) {
    if (seasonBadgeUrl() != "") {
      return QueuedNetworkImage(
        imageUrl: BungieApiService.url(
            seasonBadgeUrl()),
        fit: BoxFit.fill,
        placeholder: itemIconPlaceholder(context),
      );
    }
    return Container();
  }

  BoxDecoration iconBoxDecoration() {
    if (item?.bucketHash == InventoryBucket.engrams) {
      return null;
    }
    return BoxDecoration(
        border:
            Border.all(color: Colors.grey.shade300, width: iconBorderWidth));
  }

  Widget itemIconImage(BuildContext context) {
    if (item?.overrideStyleItemHash != null) {
      return DefinitionProviderWidget<DestinyInventoryItemDefinition>(
          item?.overrideStyleItemHash, (def) {
        return QueuedNetworkImage(
            imageUrl: BungieApiService.url(def.displayProperties.icon),
            fit: BoxFit.fill,
            placeholder: itemIconPlaceholder(context),
          );
      });
    }
    return QueuedNetworkImage(
      imageUrl: BungieApiService.url(definition.displayProperties.icon),
      fit: BoxFit.fill,
      placeholder: itemIconPlaceholder(context),
    );
  }

  Widget itemIconPlaceholder(BuildContext context) {
    return Container();
  }

  Widget getMasterworkOutline() {
    if (definition.inventory.tierType == TierType.Exotic) {
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
