
import 'package:bungie_api/enums/tier_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'base_item_filter.dart';

class FilterTierType{
  TierType tierType;
  String tierName;
  int tierHash;

  FilterTierType(this.tierType, this.tierName, this.tierHash);
  
  @override
  int get hashCode => 42 + (tierType?.hashCode ?? 0) + (tierName?.hashCode ?? 0) + (tierHash?.hashCode ?? 0);

  @override
  operator == (dynamic other){
    if(other is FilterTierType){
      return tierType == other.tierType;
    }
    if(other is TierType){
      return tierType == other;
    }
    if(other is int){
      return tierHash == other;
    }
    if(other is String){
      return tierName == other;
    }
    return this == other;
  }
}

class TierTypeFilter extends BaseItemFilter<Set<FilterTierType>> {
  TierTypeFilter() : super(Set(), Set());

  clear(){
    availableValues.clear();
  }

  @override
  Future<List<ItemWithOwner>> filter(List<ItemWithOwner> items, {Map<int, DestinyInventoryItemDefinition> definitions}) async {
    clear();
    var types = items.map((i){
      var inv = definitions[i?.item?.itemHash]?.inventory;
      return FilterTierType(inv?.tierType, inv?.tierTypeName, inv?.tierTypeHash);
    }).toSet().toList();
    types.sort((a,b)=>b?.tierType?.value?.compareTo(a.tierType.value ?? -1) ?? 0);
    this.availableValues = types.toSet();
    this.available = availableValues.length > 1;
    value.retainAll(availableValues);
    return super.filter(items, definitions:definitions);
  }

  bool filterItem(ItemWithOwner item,
      {Map<int, DestinyInventoryItemDefinition> definitions}) {
    if(value?.length == 0){
      return true;
    }
    var def = definitions[item?.item?.itemHash];
    return value.map((v)=>v.tierType).contains(def?.inventory?.tierType);
  }
}
