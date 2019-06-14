import 'dart:convert';

import 'package:little_light/services/storage/storage.service.dart';
import 'package:little_light/utils/inventory_utils.dart';

class UserSettingsService {
  static const String _keepAwakeKey = "userpref_keepAwake";
  static const String _itemOrderingKey = "userpref_itemOrdering";
  static UserSettingsService _singleton = UserSettingsService._internal();
  StorageService get globalStorage => StorageService.global();

  factory UserSettingsService() {
    return _singleton;
  }

  UserSettingsService._internal();
  


  bool get keepAwake{
    return globalStorage.getBool(_keepAwakeKey) ?? false;
  }
  
  set keepAwake(bool value){
    globalStorage.setBool(_keepAwakeKey, value);
  }

  List<SortParameter> get itemOrdering{
    List<dynamic> jsonList = jsonDecode(globalStorage.getString(_itemOrderingKey) ?? "[]");
    var savedParams = SortParameter.fromList(jsonList);
    Iterable<SortParameterType> presentParams = savedParams.map((p)=>p.type);
    var defaults = SortParameter.defaultList;
    defaults.forEach((p){
      if(!presentParams.contains(p.type)){
        savedParams.add(p);
      }
    });
    return savedParams;
  }

  set itemOrdering(List<SortParameter> ordering){
    var json = jsonEncode(ordering.map((p)=>p.toJson()).toList());
    globalStorage.setString(_itemOrderingKey, json);
  }

  CharacterSortParameter get characterOrdering{
    var jsonStr = globalStorage.getString(StorageServiceKeys.charOrdering);
    if(jsonStr == null) return CharacterSortParameter();
    return CharacterSortParameter.fromJson(jsonDecode(jsonStr));
  }
}
