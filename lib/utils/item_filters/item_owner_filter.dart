// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'base_item_filter.dart';

class ItemOwnerFilter extends BaseItemFilter<Set<String>> {
  ItemOwnerFilter(Set<String> selected, {bool enabled = true})
      : super(<String>{}, selected ?? <String>{}, enabled: enabled);

  clear() {
    availableValues.clear();
  }

  @override
  Future<List<ItemWithOwner>> filter(List<ItemWithOwner> items,
      {Map<int, DestinyInventoryItemDefinition> definitions}) {
    clear();
    var ownerIds = items?.map((i) => i.ownerId)?.toSet();
    availableValues.addAll(ownerIds);
    available = availableValues.length > 1;
    value.retainAll(availableValues);
    return super.filter(items, definitions: definitions);
  }

  @override
  bool filterItem(ItemWithOwner item, {Map<int, DestinyInventoryItemDefinition> definitions}) {
    if (value.isEmpty) return true;
    if (value.contains(item?.ownerId)) {
      return true;
    }
    return false;
  }
}
