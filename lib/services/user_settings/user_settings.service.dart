import 'dart:convert';

import 'package:little_light/utils/inventory_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettingsService {
  static const String _keepAwakeKey = "userpref_keepAwake";
  static const String _itemOrderingKey = "userpref_itemOrdering";
  static UserSettingsService _singleton = UserSettingsService._internal();
  SharedPreferences _prefs;

  factory UserSettingsService() {
    return _singleton;
  }

  UserSettingsService._internal(){
    load();
  }

  Future<SharedPreferences> load() async{
    if(_prefs != null){
      return _prefs;
    }
    _prefs = await SharedPreferences.getInstance();
    return _prefs;
  }


  bool get keepAwake{
    return _prefs.getBool(_keepAwakeKey) ?? false;
  }
  
  set keepAwake(bool value){
    _prefs.setBool(_keepAwakeKey, value);
  }

  List<SortParameter> get itemOrdering{
    List<dynamic> jsonList = jsonDecode(_prefs.getString(_itemOrderingKey) ?? "[]");
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
    _prefs.setString(_itemOrderingKey, json);
  }
}
