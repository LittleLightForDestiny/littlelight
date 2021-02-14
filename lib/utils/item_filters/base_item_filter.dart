import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/item_with_owner.dart';

abstract class BaseItemFilter<T> {
  T availableValues;
  T value;

  bool available = true;
  bool enabled;

  BaseItemFilter(this.availableValues, this.value, {this.enabled = false});

  @mustCallSuper
  Future<List<ItemWithOwner>> filter(List<ItemWithOwner> items,
      {Map<int, DestinyInventoryItemDefinition> definitions}) async {
    if (!available || !enabled) return items.toList();
    return items
            ?.where((item) => filterItem(item, definitions: definitions))
            ?.toList(growable: false) ??
        items;
  }

  bool filterItem(ItemWithOwner item,
      {Map<int, DestinyInventoryItemDefinition> definitions});
}
