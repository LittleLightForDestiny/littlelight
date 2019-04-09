import 'package:shared_preferences/shared_preferences.dart';

class UserSettingsService {
  static const String _keepAwakeKey = "userpref_keepAwake";
  static UserSettingsService _singleton = UserSettingsService._internal();
  SharedPreferences __prefs;

  factory UserSettingsService() {
    return _singleton;
  }

  UserSettingsService._internal();

  Future<SharedPreferences> get _prefs async{
    if(__prefs != null){
      return __prefs;
    }
    __prefs = await SharedPreferences.getInstance();
    return __prefs;
  }


  Future<bool> get keepAwake async{
    return (await _prefs).getBool(_keepAwakeKey) ?? false;
  }
  
  setKeepAwake(bool value) async{
    (await _prefs).setBool(_keepAwakeKey, value);
  } 
  
}
