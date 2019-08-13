import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/destiny_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/inventory_item.mixin.dart';
import 'package:little_light/widgets/item_list/items/base/item_mods.widget.dart';
import 'package:little_light/widgets/item_list/items/base/item_perks.widget.dart';

class BaseInventoryItemWidget extends DestinyItemWidget
    with InventoryItemMixin {
  final String uniqueId;

  BaseInventoryItemWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key, @required String characterId, @required this.uniqueId})
      : super(item, definition, instanceInfo, key:key, characterId:characterId);


  @override
  Widget perksWidget(BuildContext context) {
    var sockets = item?.itemInstanceId == null ? null : profile.getItemSockets(item?.itemInstanceId);
    return Positioned(
      bottom:6,
      left:96,
      child:ItemPerksWidget(
      definition: definition,
      itemSockets: sockets,
      iconSize: 20,
    ));
  }

  @override
  Widget modsWidget(BuildContext context) {
    if(item?.itemInstanceId == null) return Container();
    return Positioned(
      bottom:6,
      right:6,
      child:ItemModsWidget(
      definition: definition,
      itemSockets: profile.getItemSockets(item?.itemInstanceId),
      iconSize: 22,
    ));
  }
}
