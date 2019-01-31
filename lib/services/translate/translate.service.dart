import 'dart:convert';
import 'dart:core';

import 'package:flutter/services.dart';
import 'package:little_light/exceptions/exception_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslateService {
  String fallbackLanguage = "en";
  String _currentLanguage;
  Map<String, Map<String, String>> _translationMaps = new Map();

  static TranslateService _singleton = TranslateService._internal();

  factory TranslateService() {
    return _singleton;
  }

  TranslateService._internal();

  Map<String, String> languageNames = {
    'de': "Deutsch",
    'en': "English",
    'es': "Español",
    'es-mx': "Español mexicano",
    'fr': "Français",
    'it': "Italiano",
    'ja': "日本語",
    'ko': "한국어",
    'pl': "Polski",
    'pt-br': "Português Brasileiro",
    'ru': "Русский",
    'zh-cht': "中文",
    'zh-chs': "简化字"
  };

  Future<String> getLanguage() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    if (_prefs.getString('selected_language') != null) {
      _currentLanguage = _prefs.getString('selected_language');
      return _currentLanguage;
    }
    return null;
  }

  set currentLanguage(String lang) {
    _currentLanguage = lang;
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    _prefs.then((pref) {
      pref.setString('selected_language', lang);
    });
  }

  Future<String> getTranslation(String text, {String languageCode, Map<String, String> replace = const {}}) async {
    if(text == null || text.length == 0) return "";
    String code = languageCode;
    if (code == null) {
      code = await this.getLanguage();
    }
    if (code == null) {
      code = this.fallbackLanguage;
    }
    
    Map<String, String> translationMap = await _getTranslationMap(code);
    if(translationMap != null && translationMap.containsKey(text)){
      return _replace(translationMap[text], replace);
    }

    _reportMissingTranslation(code, text);

    translationMap = await _getTranslationMap(fallbackLanguage);
    if(translationMap != null && translationMap.containsKey(text)){
      return _replace(translationMap[text], replace);
    }

    return _replace(text, replace);
  }

  String _replace(String text, Map<String, String> replace){
    replace.forEach((String index, String replaceText){
      text = text.replaceAll("{$index}", replaceText);
    });
    return text;
  }

  _reportMissingTranslation(String language, String text){
    ExceptionHandler.reportToSentry("Missing translation: $language - $text");
  }



  Future<Map<String, String>> _getTranslationMap(String languageCode) async {
    if (_translationMaps.containsKey(languageCode)) {
      return _translationMaps[languageCode];
    }
    return _loadTranslationMap(languageCode);
  }

  Future<Map<String, String>> _loadTranslationMap(String languageCode) async{
    try{
      String mapString =  await rootBundle.loadString("assets/i18n/$languageCode.json");
      _translationMaps[languageCode] = jsonDecode(mapString).cast<String, String>();
      return _translationMaps[languageCode];
    }catch(e){
      print(e);
    }
    return null;
  }
}
