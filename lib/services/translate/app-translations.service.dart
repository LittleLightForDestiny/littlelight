import 'dart:core';

import 'package:little_light/services/translate/common-translation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTranslations{
  static String defaultLanguage = "en";
  static CommonTranslation common = new CommonTranslation();
  static String _currentLanguage;

  static List<String> supportedLanguages = ['en','fr','es','de','it','ja','pt-br','es-mx','ru','pl','ko','zh-cht'];

  static Future<bool> init(){
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    return _prefs.then((value){
      if(value.getString('selected_language') != null){
        AppTranslations._currentLanguage  = value.getString('selected_language');
        return true;
      }
      return false;
    });
  }
  
  static String get currentLanguage{
    if(_currentLanguage != null){
      return _currentLanguage;
    }
    return AppTranslations.defaultLanguage;
  }

  static set currentLanguage(String lang){
    AppTranslations._currentLanguage = lang;
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    _prefs.then((pref){
      pref.setString('selected_language', lang);
    });
  }
}