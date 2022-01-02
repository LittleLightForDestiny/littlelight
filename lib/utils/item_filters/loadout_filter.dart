import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/services/littlelight/loadouts.consumer.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'base_item_filter.dart';

class LoadoutFilter extends BaseItemFilter<Set<String>> with LoadoutsConsumer{
  Map<String, Loadout> allLoadouts;

  LoadoutFilter() : super(Set(), Set());

  clear() {
    availableValues.clear();
  }

  @override
  Future<List<ItemWithOwner>> filter(List<ItemWithOwner> items,
      {Map<int, DestinyInventoryItemDefinition> definitions}) async {
    clear();

    allLoadouts = Map<String, Loadout>.fromIterable(
        await loadoutService.getLoadouts(),
        key: (loadout) => loadout.assignedId,
        value: (loadout) => loadout);
    for (var item in items) {
      var loadouts = allLoadouts.values.where((l) {
        var equipped = l.equipped
            .where((e) => e.itemInstanceId == item.item.itemInstanceId)
            .toList();
        var unequipped = l.unequipped
            .where((e) => e.itemInstanceId == item.item.itemInstanceId)
            .toList();
        return equipped.length > 0 || unequipped.length > 0;
      }).toSet();
      availableValues.addAll(loadouts.map((l) => l.assignedId));
    }

    this.available = availableValues.length > 1;
    value.retainAll(availableValues);
    return super.filter(items, definitions: definitions);
  }

  bool filterItem(ItemWithOwner item,
      {Map<int, DestinyInventoryItemDefinition> definitions}) {
    if (value?.length == 0) {
      return true;
    }

    for (var assignedId in value) {
      var loadout = allLoadouts[assignedId];
      if (loadout.equipped
              .where((e) => e.itemInstanceId == item.item.itemInstanceId)
              .length >
          0) return true;

      if (loadout.unequipped
              .where((e) => e.itemInstanceId == item.item.itemInstanceId)
              .length >
          0) return true;
    }
    return false;
  }
}
