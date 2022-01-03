
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'base_item_filter.dart';

class EnergyTypeFilter extends BaseItemFilter<Set<int>> {
  EnergyTypeFilter() : super(Set(), Set());

  clear(){
    availableValues.clear();
  }

  @override
  Future<List<ItemWithOwner>> filter(List<ItemWithOwner> items, {Map<int, DestinyInventoryItemDefinition> definitions}) async {
    clear();
    var energyTypeHashes = items.map<int>((i){
      var instanceInfo = profile.getInstanceInfo(i?.item?.itemInstanceId);
      return instanceInfo?.energy?.energyTypeHash;
    }).toSet();
    availableValues.addAll(energyTypeHashes);
    this.available = availableValues.length > 1;
    value.retainAll(availableValues);
    return super.filter(items, definitions:definitions);
  }

  bool filterItem(ItemWithOwner item,
      {Map<int, DestinyInventoryItemDefinition> definitions}) {
    if(value?.length == 0){
      return true;
    }
    var instanceInfo = profile.getInstanceInfo(item?.item?.itemInstanceId);
    return value.contains(instanceInfo?.energy?.energyTypeHash);
  }
}
