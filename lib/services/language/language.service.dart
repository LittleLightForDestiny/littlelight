import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:little_light/services/storage/export.dart';
import 'package:little_light/services/language/timeago_messages/cn_messages.dart';
import 'package:little_light/services/language/timeago_messages/de_messages.dart';
import 'package:little_light/services/language/timeago_messages/en_messages.dart';
import 'package:little_light/services/language/timeago_messages/es_messages.dart';
import 'package:little_light/services/language/timeago_messages/fr_messages.dart';
import 'package:little_light/services/language/timeago_messages/it_messages.dart';
import 'package:little_light/services/language/timeago_messages/ja_messages.dart';
import 'package:little_light/services/language/timeago_messages/ko_messages.dart';
import 'package:little_light/services/language/timeago_messages/pl_messages.dart';
import 'package:little_light/services/language/timeago_messages/pt_messages.dart';
import 'package:little_light/services/language/timeago_messages/ru_messages.dart';
import 'package:timeago/timeago.dart' as timeago;

setupLanguageService() {
  GetIt.I.registerSingleton<LanguageService>(LanguageService._internal());
}

class LanguageService with StorageConsumer {
  final _fallbackLanguage = "en";
  String _systemLanguage;
  String get selectedLanguage => globalStorage.currentLanguage;
  set selectedLanguage(String value) => globalStorage.currentLanguage = value;
  String get currentLanguage =>
      selectedLanguage ?? _systemLanguage ?? _fallbackLanguage;
  Map<String, Map<String, String>> _translationMaps = new Map();

  LanguageService._internal();

  init(BuildContext context) {
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

    Locale locale = Localizations.localeOf(context);
    if (locale != null) {
      _systemLanguage = languageNames.keys.firstWhere(
          (language) =>
              locale.countryCode != null &&
              locale.languageCode != null &&
              language.startsWith(locale.languageCode?.toLowerCase()) &&
              language.endsWith(locale.countryCode?.toLowerCase()),
          orElse: () => null);
      _systemLanguage ??= languageNames.keys.firstWhere((language) =>
          language.startsWith(locale.languageCode?.toLowerCase()));
    }
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
    'zh-cht': "繁體中文",
    'zh-chs': "简体中文"
  };

  Future<String> getTranslation(String text,
      {String languageCode, Map<String, String> replace = const {}}) async {
    if (text == null || text.length == 0) return "";
    String code = languageCode ?? currentLanguage;

    Map<String, String> translationMap = await _getTranslationMap(code);
    if (translationMap != null && translationMap.containsKey(text)) {
      return _replace(translationMap[text], replace);
    }

    translationMap = await _getTranslationMap(_fallbackLanguage);
    if (translationMap != null && translationMap.containsKey(text)) {
      return _replace(translationMap[text], replace);
    }

    return _replace(text, replace);
  }

  String _replace(String text, Map<String, String> replace) {
    replace.forEach((String index, String replaceText) {
      text = text.replaceAll("{$index}", replaceText);
    });
    return text;
  }

  Future<Map<String, String>> _getTranslationMap(String languageCode) async {
    if (_translationMaps.containsKey(languageCode)) {
      return _translationMaps[languageCode];
    }
    var translations = await _loadTranslationMapFromSavedData(languageCode);
    if (translations == null) {
      translations = await _updateTranslationsFromWeb(languageCode);
      return translations;
    } else {
      _updateTranslationsFromWeb(languageCode);
    }
    return translations;
  }

  Future<Map<String, String>> _updateTranslationsFromWeb(
      String languageCode) async {
    var url =
        "https://cdn.jsdelivr.net/gh/LittleLightForDestiny/LittleLightTranslations/languages/$languageCode.json";
    var req = await http.get(Uri.parse(url));
    var raw = req.body;

    ///Add method to cache translations files
    // StorageService.language(languageCode).saveRawFile(
    //     StorageKeys.rawData, StorageKeys.littleLightTranslation.path, raw);
    Map<String, String> translation = Map<String, String>.from(jsonDecode(raw));
    _translationMaps[languageCode] = translation;
    return _translationMaps[languageCode];
  }

  Future<Map<String, String>> _loadTranslationMapFromSavedData(
      String languageCode) async {
    try {
      ///Add method to load cached translations files
      // var storage = StorageService.language(languageCode);
      // String raw = await storage.getRawFile(
      // StorageKeys.rawData, StorageKeys.littleLightTranslation.path);
      // Map<String, String> translation =
      // Map<String, String>.from(jsonDecode(raw));
      // _translationMaps[languageCode] = translation;
      return _translationMaps[languageCode];
    } catch (e) {
      print(e);
    }
    return null;
  }
}
