import 'dart:convert';

import 'package:little_light/services/storage/storage.service.dart';
import 'package:little_light/utils/inventory_utils.dart';

class UserSettingsService {
  static const String _keepAwakeKey = "userpref_keepAwake";
  static const String _itemOrderingKey = "userpref_itemOrdering";
  static UserSettingsService _singleton = UserSettingsService._internal();
  StorageService get storage => StorageService.membership();

  factory UserSettingsService() {
    return _singleton;
  }

  UserSettingsService._internal();
  


  bool get keepAwake{
    return storage.getBool(_keepAwakeKey) ?? false;
  }
  
  set keepAwake(bool value){
    storage.setBool(_keepAwakeKey, value);
  }

  List<SortParameter> get itemOrdering{
    List<dynamic> jsonList = jsonDecode(storage.getString(_itemOrderingKey) ?? "[]");
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
    storage.setString(_itemOrderingKey, json);
  }

  CharacterSortParameter get characterOrdering{
    var jsonStr = storage.getString(StorageServiceKeys.charOrdering);
    if(jsonStr == null) return CharacterSortParameter();
    return CharacterSortParameter.fromJson(jsonDecode(jsonStr));
  }
}
