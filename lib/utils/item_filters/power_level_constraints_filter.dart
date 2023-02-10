// @dart=2.9

import 'dart:math';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'base_item_filter.dart';

class PowerLevelConstraints {
  bool includePowerlessItems;
  int max;
  int min;
  PowerLevelConstraints([this.min, this.max, this.includePowerlessItems = true]);
}

class PowerLevelConstraintsFilter extends BaseItemFilter<PowerLevelConstraints> {
  PowerLevelConstraintsFilter(PowerLevelConstraints available, PowerLevelConstraints selected)
      : super(available, selected);

  @override
  Future<List<ItemWithOwner>> filter(List<ItemWithOwner> items,
      {Map<int, DestinyInventoryItemDefinition> definitions}) async {
    availableValues.includePowerlessItems = false;
    availableValues.min = 9999;
    availableValues.max = -9999;
    for (var element in items) {
      var instanceInfo = profile.getInstanceInfo(element?.item?.itemInstanceId);
      var power = instanceInfo?.primaryStat?.value;
      if (power != null) {
        availableValues.min = min(availableValues?.min ?? power, power);
        availableValues.max = max(availableValues?.max ?? power, power);
      } else {
        availableValues.includePowerlessItems = true;
      }
    }

    available = (availableValues?.min ?? 9999) < (availableValues?.max ?? -9999);

    if (available) {
      value.max = min(availableValues.max, value.max ?? 9999);
      value.min = min(value.max, max(availableValues.min, value.min ?? -9999));
    }

    return super.filter(items, definitions: definitions);
  }

  @override
  bool filterItem(ItemWithOwner item, {Map<int, DestinyInventoryItemDefinition> definitions}) {
    var instanceInfo = profile.getInstanceInfo(item?.item?.itemInstanceId);
    var power = instanceInfo?.primaryStat?.value;
    if (power == null) return value.includePowerlessItems;
    if (power < value.min) return false;
    if (power > value.max) return false;
    return true;
  }
}
