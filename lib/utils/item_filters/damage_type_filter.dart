
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'base_item_filter.dart';

class DamageTypeFilter extends BaseItemFilter<Set<int>> {
  DamageTypeFilter() : super(Set(), Set());

  clear(){
    availableValues.clear();
  }

  @override
  Future<List<ItemWithOwner>> filter(List<ItemWithOwner> items, {Map<int, DestinyInventoryItemDefinition> definitions}) async {
    clear();
    var damageTypeHashes = items.map<int>((i){
      var instanceInfo = ProfileService().getInstanceInfo(i?.item?.itemInstanceId);
      return instanceInfo?.damageTypeHash;
    }).toSet();
    availableValues.addAll(damageTypeHashes);
    this.available = availableValues.length > 1;
    value.retainAll(availableValues);
    return super.filter(items, definitions:definitions);
  }

  bool filterItem(ItemWithOwner item,
      {Map<int, DestinyInventoryItemDefinition> definitions}) {
    if(value?.length == 0){
      return true;
    }
    var instanceInfo = ProfileService().getInstanceInfo(item?.item?.itemInstanceId);
    return value.contains(instanceInfo?.damageTypeHash);
  }
}
