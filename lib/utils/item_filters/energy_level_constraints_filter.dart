// @dart=2.9

import 'dart:math';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'base_item_filter.dart';

class EnergyLevelConstraints {
  bool includeEnergylessItems;
  int max;
  int min;
  EnergyLevelConstraints([this.min, this.max, this.includeEnergylessItems = true]);
}

class EnergyLevelConstraintsFilter extends BaseItemFilter<EnergyLevelConstraints> {
  EnergyLevelConstraintsFilter(EnergyLevelConstraints available, EnergyLevelConstraints selected)
      : super(available, selected);

  @override
  Future<List<ItemWithOwner>> filter(List<ItemWithOwner> items,
      {Map<int, DestinyInventoryItemDefinition> definitions}) async {
    availableValues.includeEnergylessItems = false;
    availableValues.min = 9999;
    availableValues.max = -9999;
    for (var item in items) {
      var instanceInfo = profile.getInstanceInfo(item.item.itemInstanceId);
      if (instanceInfo?.energy?.energyCapacity != null) {
        availableValues.min = min(availableValues.min, instanceInfo.energy.energyCapacity);
        availableValues.max = max(availableValues.max, instanceInfo.energy.energyCapacity);
      } else {
        availableValues.includeEnergylessItems = true;
      }
    }

    this.available = (this.availableValues?.min ?? 9999) < (this.availableValues?.max ?? -9999);

    if (this.available) {
      this.value.max = min(this.availableValues.max, this.value.max ?? 9999);
      this.value.min = min(this.value.max, max(this.availableValues.min, this.value.min ?? -9999));
    }

    return super.filter(items, definitions: definitions);
  }

  bool filterItem(ItemWithOwner item, {Map<int, DestinyInventoryItemDefinition> definitions}) {
    var instanceInfo = profile.getInstanceInfo(item?.item?.itemInstanceId);
    var energy = instanceInfo?.energy?.energyCapacity;
    if (energy == null) return value.includeEnergylessItems;
    if (energy < value.min) return false;
    if (energy > value.max) return false;
    return true;
  }
}
