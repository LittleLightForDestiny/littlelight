import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/destiny-item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/inventory_item.mixin.dart';

class BaseInventoryItemWidget extends DestinyItemWidget
    with InventoryItemMixin {
  BaseInventoryItemWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key})
      : super(item, definition, instanceInfo, key:key);
}
