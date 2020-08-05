
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/services/littlelight/littlelight_data.service.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'base_item_filter.dart';

class SeasonSlotFilter extends BaseItemFilter<Set<int>> {
  SeasonSlotFilter() : super(Set(), Set());
  List<int> seasonalSlots;
  
  clear(){
    availableValues.clear();
  }

  @override
  Future<List<ItemWithOwner>> filter(List<ItemWithOwner> items, {Map<int, DestinyInventoryItemDefinition> definitions}) async {
    clear();

    var gameData = await LittleLightDataService().getGameData();
    seasonalSlots = gameData.seasonalModSlots;
    Set<int> hashes = Set();
    for(var item in items){
      var def = definitions[item.item.itemHash];
      var entries = def.sockets?.socketEntries;
      if(entries == null) continue;
      for(var socket in entries){
        if(gameData?.seasonalModSlots?.contains(socket.singleInitialItemHash) ?? false){
          hashes.add(socket.singleInitialItemHash);
        }
      }
    }
    availableValues.addAll(hashes);

    this.available = availableValues.length > 1;
    if(available) availableValues.add(-1);
    value.retainAll(availableValues);
    return super.filter(items, definitions:definitions);
  }

  bool filterItem(ItemWithOwner item,
      {Map<int, DestinyInventoryItemDefinition> definitions}) {
    if(value?.length == 0){
      return true;
    }
    var def = definitions[item.item.itemHash];
    if(value.contains(-1)){
      var contains = false;
      if(def?.sockets?.socketEntries == null) return true;
      for(var socket in def.sockets.socketEntries){
        contains = contains || (seasonalSlots.contains(socket.singleInitialItemHash) ?? false);
      }
      if(!contains) return true;
    }
    if(def?.sockets?.socketCategories == null) return false;
    for(var socket in def?.sockets?.socketEntries){
      if(value.contains(socket.singleInitialItemHash) ?? false){
        return true;
      }
    }
    return false;
  }
}
