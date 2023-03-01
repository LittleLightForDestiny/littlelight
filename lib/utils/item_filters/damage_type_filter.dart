// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'base_item_filter.dart';

class DamageTypeFilter extends BaseItemFilter<Set<int>> {
  DamageTypeFilter() : super(<int>{}, <int>{});

  clear() {
    availableValues.clear();
  }

  @override
  Future<List<ItemWithOwner>> filter(List<ItemWithOwner> items,
      {Map<int, DestinyInventoryItemDefinition> definitions}) async {
    if (items == null) return items;
    clear();
    var damageTypeHashes = items.map<int>((i) {
      var instanceInfo = profile.getInstanceInfo(i?.item?.itemInstanceId);
      return instanceInfo?.damageTypeHash;
    }).toSet();
    availableValues.addAll(damageTypeHashes);
    available = availableValues.length > 1;
    value.retainAll(availableValues);
    return super.filter(items, definitions: definitions);
  }

  @override
  bool filterItem(ItemWithOwner item,
      {Map<int, DestinyInventoryItemDefinition> definitions}) {
    if (value.isEmpty) {
      return true;
    }
    var instanceInfo = profile.getInstanceInfo(item?.item?.itemInstanceId);
    return value.contains(instanceInfo?.damageTypeHash);
  }
}
