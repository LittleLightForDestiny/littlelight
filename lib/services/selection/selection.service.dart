import 'dart:async';

import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:little_light/services/inventory/inventory.service.dart';

class SelectionService {
  static final SelectionService _singleton = new SelectionService._internal();
  factory SelectionService() {
    return _singleton;
  }
  SelectionService._internal();

  List<ItemInventoryState> _selectedItems = [];

  Stream<List<ItemInventoryState>> _eventsStream;
  StreamController<List<ItemInventoryState>> _streamController =
      StreamController.broadcast();

  
  bool get multiselectActivated=>_selectedItems.length > 0;
  

  Stream<List<ItemInventoryState>> get broadcaster {
    if (_eventsStream != null) {
      return _eventsStream;
    }
    _eventsStream = _streamController.stream;
    return _eventsStream;
  }

  _onUpdate() {
    _streamController.add(_selectedItems);
  }

  isSelected(DestinyItemComponent item, String characterId){
    return _selectedItems.any((i)=>i.item?.itemHash == item?.itemHash && i.characterId == characterId);
  }

  addItem(DestinyItemComponent item, String characterId) {
    ItemInventoryState alreadyAdded = _selectedItems.firstWhere((i){
      if(item.itemInstanceId != null){
        return i.item.itemInstanceId == item.itemInstanceId;
      }
      return i.item.itemHash == item.itemHash && i.characterId == characterId;
    }, orElse: ()=>null);
    if(alreadyAdded != null){
      return removeItem(item, characterId);
    }

    _selectedItems.add(ItemInventoryState(
        characterId, item));

    _onUpdate();
  }

  removeItem(DestinyItemComponent item, String characterId) {
    if(item.itemInstanceId != null){
      _selectedItems.removeWhere((i) =>i.item.itemInstanceId == item.itemInstanceId);
    }else{
      _selectedItems.removeWhere((i) =>
        i.item.itemHash == item.itemHash && 
        i.characterId == characterId);
    }

    
    _onUpdate();
  }

  clear() {
    _selectedItems.clear();
    _onUpdate();
  }
}
