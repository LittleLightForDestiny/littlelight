import 'package:little_light/services/storage/storage.service.dart';

import 'character_sort_parameter.dart';
import 'item_sort_parameter.dart';

class UserSettingsService {
  static UserSettingsService _singleton = UserSettingsService._internal();
  StorageService get globalStorage => StorageService.global();
  StorageService get membershipStorage => StorageService.membership();
  List<ItemSortParameter> _itemOrdering;
  List<ItemSortParameter> _pursuitOrdering;
  CharacterSortParameter _characterOrdering;

  factory UserSettingsService() {
    return _singleton;
  }
  UserSettingsService._internal();
  init() async{
    await initItemOrdering();
    await initPursuitOrdering();
    await initCharacterOrdering();
  }

  initItemOrdering() async{
    List<dynamic> jsonList = await globalStorage.getJson(StorageKeys.pursuitOrdering);
    List<ItemSortParameter> savedParams = (jsonList ?? []).map((j)=>ItemSortParameter.fromJson(j)).toList();
    List<ItemSortParameterType> presentParams = savedParams.map((p)=>p.type).toList();
    var defaults = ItemSortParameter.defaultPursuitList;
    var defaultParams = defaults.map((p)=>p.type);
    savedParams.removeWhere((p)=>!defaultParams.contains(p.type));
    defaults.forEach((p){
      if(!presentParams.contains(p.type)){
        savedParams.add(p);
      }
    });
    _pursuitOrdering = savedParams;
  }

  initPursuitOrdering() async{
    List<dynamic> jsonList = await globalStorage.getJson(StorageKeys.pursuitOrdering);
    List<ItemSortParameter> savedParams = (jsonList ?? []).map((j)=>ItemSortParameter.fromJson(j)).toList();
    Iterable<ItemSortParameterType> presentParams = savedParams.map((p)=>p.type);
    var defaults = ItemSortParameter.defaultItemList;
    var defaultParams = defaults.map((p)=>p.type);
    savedParams.removeWhere((p)=>!defaultParams.contains(p.type));
    defaults.forEach((p){
      if(!presentParams.contains(p.type)){
        savedParams.add(p);
      }
    });
    _itemOrdering = savedParams;
  }

  initCharacterOrdering() async{
    dynamic json = await membershipStorage.getJson(StorageKeys.characterOrdering);
    if(json == null){
      _characterOrdering = CharacterSortParameter();  
      return;
    }
    _characterOrdering = CharacterSortParameter.fromJson(json);
  }


  bool get keepAwake{
    return globalStorage.getBool(StorageKeys.keepAwake) ?? false;
  }
  
  set keepAwake(bool value){
    globalStorage.setBool(StorageKeys.keepAwake, value);
  }

  List<ItemSortParameter> get itemOrdering =>_itemOrdering;

  set itemOrdering(List<ItemSortParameter> ordering){
    _itemOrdering = ordering;
    var json = ordering.map((p)=>p.toJson()).toList();
    globalStorage.setJson(StorageKeys.itemOrdering, json);
  }

  List<ItemSortParameter> get pursuitOrdering =>_pursuitOrdering;

  set pursuitOrdering(List<ItemSortParameter> ordering){
    _pursuitOrdering = ordering;
    var json = ordering.map((p)=>p.toJson()).toList();
    globalStorage.setJson(StorageKeys.pursuitOrdering, json);
  }
  
  CharacterSortParameter get characterOrdering=>_characterOrdering;

  set characterOrdering(CharacterSortParameter ordering){
    _characterOrdering = ordering;
    var json = ordering.toJson();
    membershipStorage.setJson(StorageKeys.characterOrdering, json);
  }
}
