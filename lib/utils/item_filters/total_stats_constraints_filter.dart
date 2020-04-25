import 'dart:math';

import 'package:bungie_api/enums/destiny_item_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'base_item_filter.dart';

class TotalStatsConstraints {
  bool includeNonArmorItems;
  int max;
  int min;
  TotalStatsConstraints(
      [this.min, this.max, this.includeNonArmorItems = true]);
}

class TotalStatsConstraintsFilter
    extends BaseItemFilter<TotalStatsConstraints> {
  TotalStatsConstraintsFilter(
      TotalStatsConstraints available, TotalStatsConstraints selected)
      : super(available, selected);

  @override
  Future<List<ItemWithOwner>> filter(List<ItemWithOwner> items,
      {Map<int, DestinyInventoryItemDefinition> definitions}) async {
    availableValues.includeNonArmorItems = false;
    availableValues.min = 9999;
    availableValues.max = -9999;
    for(var item in items){
      var def = definitions[item.item.itemHash];
      if(def.itemType == DestinyItemType.Armor){
        var stats = ProfileService().getPrecalculatedStats(item.item.itemInstanceId);
        var totalStats = stats.values.fold<int>(0, (t, s) =>t + (s.value ?? 0));
        availableValues.min = min(availableValues.min, totalStats);
        availableValues.max = max(availableValues.max, totalStats);
      }else{
        availableValues.includeNonArmorItems = true;
      }
    }
    
    this.available = (this.availableValues?.min ?? 9999) <
        (this.availableValues?.max ?? -9999);

    if (this.available) {
      this.value.max = min(this.availableValues.max, this.value.max ?? 9999);
      this.value.min = min(this.value.max,
          max(this.availableValues.min, this.value.min ?? -9999));
    }

    return super.filter(items, definitions: definitions);
  }

  bool filterItem(ItemWithOwner item,
      {Map<int, DestinyInventoryItemDefinition> definitions}) {
    var def = definitions[item.item.itemHash];
    if (def.itemType != DestinyItemType.Armor) return value.includeNonArmorItems;
    var stats = ProfileService().getPrecalculatedStats(item.item.itemInstanceId);
    var totalStats = stats.values.fold<int>(0, (t, s) =>t + (s.value ?? 0));
    if (totalStats < value.min) return false;
    if (totalStats > value.max) return false;
    return true;
  }
}
