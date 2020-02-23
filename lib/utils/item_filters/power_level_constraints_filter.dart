import 'dart:math';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'base_item_filter.dart';

class PowerLevelConstraints {
  bool includePowerlessItems;
  int max;
  int min;
  PowerLevelConstraints(
      [this.min, this.max, this.includePowerlessItems = true]);
}

class PowerLevelConstraintsFilter
    extends BaseItemFilter<PowerLevelConstraints> {
  PowerLevelConstraintsFilter(
      PowerLevelConstraints available, PowerLevelConstraints selected)
      : super(available, selected);

  @override
  Future<List<ItemWithOwner>> filter(List<ItemWithOwner> items,
      {Map<int, DestinyInventoryItemDefinition> definitions}) async {
    availableValues.includePowerlessItems = false;
    availableValues.min = 9999;
    availableValues.max = -9999;
    items.forEach((element) {
      var instanceInfo =
          ProfileService().getInstanceInfo(element?.item?.itemInstanceId);
      var power = instanceInfo?.primaryStat?.value;
      if (power != null) {
        this.availableValues.min =
            min(this.availableValues?.min ?? power, power);
        this.availableValues.max =
            max(this.availableValues?.max ?? power, power);
      } else {
        availableValues.includePowerlessItems = true;
      }
    });

    this.available = (this.availableValues?.min ?? 9999) <
        (this.availableValues?.max ?? -9999);

    if (this.available) {
      this.value.max = min(this.availableValues.max, this.value.max ?? 9999);
      this.value.min = min(this.value.max, max(this.availableValues.min, this.value.min ?? -9999));
    }

    return super.filter(items, definitions: definitions);
  }

  bool filterItem(ItemWithOwner item,
      {Map<int, DestinyInventoryItemDefinition> definitions}) {
    var instanceInfo =
        ProfileService().getInstanceInfo(item?.item?.itemInstanceId);
    var power = instanceInfo?.primaryStat?.value;
    if(power == null) return value.includePowerlessItems;
    if(power < value.min) return false;
    if(power > value.max) return false;
    return true;
  }
  
}
