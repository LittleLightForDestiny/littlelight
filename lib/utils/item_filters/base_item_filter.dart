import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/utils/item_with_owner.dart';

abstract class BaseItemFilter<T> {
  T availableValues;

  T value;

  BaseItemFilter(this.availableValues, this.value);

  bool filter(ItemWithOwner item,
      {Map<int, DestinyInventoryItemDefinition> definitions}) {
    return true;
  }
}
