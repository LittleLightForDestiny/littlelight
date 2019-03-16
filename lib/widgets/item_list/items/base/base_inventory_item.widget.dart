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
    return Positioned(
      top:50,
      left:96,
      child:ItemPerksWidget(
      item,
      definition,
      instanceInfo,
      characterId: characterId,
      iconSize: 14,
    ));
  }

  @override
  Widget modsWidget(BuildContext context) {
    return Positioned(
      bottom:8,
      left:96,
      child:ItemModsWidget(
      item,
      definition,
      instanceInfo,
      characterId: characterId,
      iconSize: 20,
    ));
  }
}
