import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/item_list/items/base/inventory_item.mixin.dart';

class BaseInventoryItemWidget extends StatelessWidget with InventoryItemMixin {
  final DestinyItemComponent item;
  final DestinyInventoryItemDefinition definition;
  final DestinyItemInstanceComponent instanceInfo;

  BaseInventoryItemWidget(this.item, this.definition, this.instanceInfo);
}