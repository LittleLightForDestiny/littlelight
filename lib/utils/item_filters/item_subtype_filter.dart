import 'package:bungie_api/enums/destiny_item_sub_type.dart';
import 'package:bungie_api/enums/destiny_item_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/utils/item_filters/base_item_filter.dart';
import 'package:little_light/utils/item_with_owner.dart';

class FilterSubType{
  DestinyItemSubType subType;
  DestinyItemType type;
  String subTypeName;
  

  FilterSubType(this.type, this.subType, this.subTypeName);
  
  @override
  int get hashCode => 1241 + (subTypeName?.hashCode ?? 0);

  @override
  operator == (dynamic other){
    if(other is FilterSubType){
      return subTypeName == other.subTypeName;
    }
    if(other is DestinyItemSubType){
      return subType == other;
    }
    if(other is String){
      return subTypeName == other;
    }
    return this == other;
  }
}

class ItemSubtypeFilter extends BaseItemFilter<Set<FilterSubType>> {
  ItemSubtypeFilter() : super(Set(), Set());
  
  clear(){
    availableValues.clear();
  }

  @override
  Future<List<ItemWithOwner>> filter(List<ItemWithOwner> items, {Map<int, DestinyInventoryItemDefinition> definitions}) async {
    clear();
    var subTypes = items.map<FilterSubType>((i){
      var def = definitions[i?.item?.itemHash];
      return FilterSubType(def?.itemType, def?.itemSubType, def?.itemTypeDisplayName);
    }).toList().toSet().toList();
    subTypes.sort((a, b){
      var type = a?.type?.value?.compareTo(b?.type?.value ?? 0) ?? 0;
      if(type != 0) return type;
      var sub = a?.subType?.value?.compareTo(b?.subType?.value ?? 0) ?? 0;
      if(sub != 0) return sub;
      return a?.subTypeName?.compareTo(b?.subTypeName);
    });
    availableValues.addAll(subTypes);
    
    this.available = availableValues.length > 1;
    value.retainAll(availableValues);
    if(value?.length == 0) return items;
    return super.filter(items, definitions:definitions);
  }

  @override
  bool filterItem(ItemWithOwner item,
      {Map<int, DestinyInventoryItemDefinition> definitions}) {
    var def = definitions[item?.item?.itemHash];
    if(value.any((v)=>v.subTypeName == def?.itemTypeDisplayName)) return true;
    return false;
  }
}
