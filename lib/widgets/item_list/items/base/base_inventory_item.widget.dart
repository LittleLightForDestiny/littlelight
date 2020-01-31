import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateless_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/inventory_item.mixin.dart';
import 'package:little_light/widgets/item_list/items/base/item_armor_tier.widget.dart';
import 'package:little_light/widgets/item_list/items/base/item_mods.widget.dart';
import 'package:little_light/widgets/item_list/items/base/item_perks.widget.dart';

class BaseInventoryItemWidget extends BaseDestinyStatelessItemWidget
    with InventoryItemMixin {
  final String uniqueId;
  final Widget trailing;

  BaseInventoryItemWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      @required String characterId,
      this.trailing,
      @required this.uniqueId})
      : super(
            item: item,
            definition: definition,
            instanceInfo: instanceInfo,
            key: key,
            characterId: characterId,
            );

  @override
  Widget perksWidget(BuildContext context) {
    var sockets = item?.itemInstanceId == null
        ? null
        : profile.getItemSockets(item?.itemInstanceId);
    var socketCategoryHashes =
        definition?.sockets?.socketCategories?.map((s) => s.socketCategoryHash);
    var perksCategoryHash = socketCategoryHashes?.firstWhere(
        (s) => DestinyData.socketCategoryPerkHashes.contains(s),
        orElse: () => null);
    var tierCategoryHash = socketCategoryHashes?.firstWhere(
        (s) => DestinyData.socketCategoryTierHashes.contains(s),
        orElse: () => null);
    if (perksCategoryHash != null) {
      return Positioned(
          bottom: 6,
          left: 96,
          child: ItemPerksWidget(
            socketCategoryHash: perksCategoryHash,
            definition: definition,
            itemSockets: sockets,
            iconSize: 20,
          ));
    }
    if (tierCategoryHash != null) {
      return Positioned(
          bottom: 6,
          left: 96,
          child: ItemArmorTierWidget(
            socketCategoryHash: tierCategoryHash,
            definition: definition,
            itemSockets: sockets,
            iconSize: 20,
          ));
    }
    return Container();
  }

  @override
  Widget modsWidget(BuildContext context) {
    if (item?.itemInstanceId == null) return Container();
    return Positioned(
        bottom: 6,
        right: 6,
        child: ItemModsWidget(
          definition: definition,
          itemSockets: profile.getItemSockets(item?.itemInstanceId),
          iconSize: 28,
        ));
  }

  @override
  Widget primaryStatWidget(BuildContext context) {
    if ((item?.quantity ?? 0) > 1) {
      return Positioned(
          bottom: 4,
          right: 4,
          child: Container(child: Text("x${item.quantity}",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          )));
    }
    return super.primaryStatWidget(context);
  }

}
