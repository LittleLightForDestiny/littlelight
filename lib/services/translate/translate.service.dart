import 'dart:convert';
import 'dart:core';

import 'package:flutter/services.dart';
import 'package:little_light/exceptions/exception_handler.dart';
import 'package:little_light/services/translate/timeago_messages/cn_messages.dart';
import 'package:little_light/services/translate/timeago_messages/de_messages.dart';
import 'package:little_light/services/translate/timeago_messages/en_messages.dart';
import 'package:little_light/services/translate/timeago_messages/es_messages.dart';
import 'package:little_light/services/translate/timeago_messages/fr_messages.dart';
import 'package:little_light/services/translate/timeago_messages/it_messages.dart';
import 'package:little_light/services/translate/timeago_messages/ja_messages.dart';
import 'package:little_light/services/translate/timeago_messages/ko_messages.dart';
import 'package:little_light/services/translate/timeago_messages/pl_messages.dart';
import 'package:little_light/services/translate/timeago_messages/pt_messages.dart';
import 'package:little_light/services/translate/timeago_messages/ru_messages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class TranslateService {
  String fallbackLanguage = "en";
  String _currentLanguage;
  Map<String, Map<String, String>> _translationMaps = new Map();

  static TranslateService _singleton = TranslateService._internal();

  factory TranslateService() {
    return _singleton;
  }

  TranslateService._internal(){
    timeago.setLocaleMessages('de', DeMessages());
    timeago.setLocaleMessages('en', EnMessages());
    timeago.setLocaleMessages('es', EsMessages());
    timeago.setLocaleMessages('es-mx', EsMessages());
    timeago.setLocaleMessages('fr', FrMessages());
    timeago.setLocaleMessages('it', ItMessages());
    timeago.setLocaleMessages('ja', JaMessages());
    timeago.setLocaleMessages('ko', KoMessages());
    timeago.setLocaleMessages('pl', PlMessages());
    timeago.setLocaleMessages('pt-br', PtBrMessages());
    timeago.setLocaleMessages('ru', RuMessages());
    timeago.setLocaleMessages('zh-cht', ZhMessages());
    timeago.setLocaleMessages('zh-chs', ZhMessages());
  }

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

    if(!translationMap.containsKey("#####$text")){
      _reportMissingTranslation(code, text);
    }
    

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
