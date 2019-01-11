import 'package:bungie_api/enums/item_state_enum.dart';
import 'package:bungie_api/enums/tier_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/bungie_api/enums/item_type.enum.dart';
import 'package:little_light/utils/shimmer_helper.dart';
import 'package:little_light/widgets/common/destiny_item.widget.dart';
import 'package:little_light/widgets/common/item_icon/engram_icon.widget.dart';
import 'package:little_light/widgets/common/item_icon/subclass_icon.widget.dart';
import 'package:shimmer/shimmer.dart';

class ItemIconWidget extends DestinyItemWidget {
  final double iconBorderWidth;

  factory ItemIconWidget.builder(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      double iconBorderWidth = 2}) {
    switch (definition.itemType) {
      case ItemType.subclasses:
        return SubclassIconWidget(item, definition, instanceInfo,
            key: key, iconBorderWidth: iconBorderWidth);
      
      case ItemType.engrams:
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
      : super(item, definition, instanceInfo, key: key, characterId:characterId);

  @override
  Widget build(BuildContext context) {
    if (item.state & ItemState.Masterwork == ItemState.Masterwork) {
      return Stack(children: [
        itemIconImage(context),
        Positioned.fill(child: getMasterworkOutline()),
        Positioned.fill(
            child: Shimmer.fromColors(
          baseColor: Colors.amber.withOpacity(.2),
          highlightColor: Colors.amber.shade100,
          child: getMasterworkOutline(),
          period: Duration(seconds: 5),
        ))
      ]);
    }
    return Container(
        foregroundDecoration: iconBoxDecoration(),
        child: itemIconImage(context));
  }

  BoxDecoration iconBoxDecoration() {
    if (item.bucketHash == InventoryBucket.engrams) {
      return null;
    }
    return BoxDecoration(
        border:
            Border.all(color: Colors.grey.shade300, width: iconBorderWidth));
  }

  Widget itemIconImage(BuildContext context) {
    return CachedNetworkImage(
      imageUrl:
          "${BungieApiService.baseUrl}${definition.displayProperties.icon}",
      fit: BoxFit.fill,
      placeholder: itemIconPlaceholder(context),
    );
  }

  Widget itemIconPlaceholder(BuildContext context) {
    return ShimmerHelper.getDefaultShimmer(context);
  }

  Image getMasterworkOutline() {
    if (definition.inventory.tierType == TierType.Exotic) {
      return Image.asset("assets/imgs/masterwork-outline-exotic.png");
    }
    return Image.asset("assets/imgs/masterwork-outline.png");
  }
}
