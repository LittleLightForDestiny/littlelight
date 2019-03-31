import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';


class BaseItemInstanceWidget extends BaseInventoryItemWidget {
  BaseItemInstanceWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition itemDefinition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key, @required String uniqueId, @required String characterId})
      : super(item, itemDefinition, instanceInfo, key:key, characterId:characterId, uniqueId:uniqueId);
}
