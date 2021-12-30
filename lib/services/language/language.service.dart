//@dart=2.12
import 'dart:convert';
import 'dart:core';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:little_light/models/language_info.dart';
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
import 'package:little_light/services/storage/export.dart';
import 'package:timeago/timeago.dart' as timeago;

setupLanguageService() {
  GetIt.I.registerSingleton<LanguageService>(LanguageService._internal());
}

class LanguageService with StorageConsumer {
  final _fallbackLanguage = "en";
  String? _systemLanguage;
  String? get selectedLanguage => globalStorage.currentLanguage;
  set selectedLanguage(String? value) => globalStorage.currentLanguage = value;
  String get currentLanguage => selectedLanguage ?? _systemLanguage ?? _fallbackLanguage;
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
    final languageCode = locale.languageCode;
    final countryCode = locale.countryCode;

    if (countryCode != null) {
      _systemLanguage = languages
          .firstWhereOrNull((language) =>
              language.code.startsWith(languageCode.toLowerCase()) && language.code.endsWith(countryCode.toLowerCase()))
          ?.code;
    }

    _systemLanguage ??= languages.firstWhereOrNull((language) => language.code.startsWith(locale.languageCode))?.code;
  }

  List<LanguageInfo> languages = [
    LanguageInfo(code: 'de', name: "Deutsch"),
    LanguageInfo(code: 'en', name: "English"),
    LanguageInfo(code: 'es', name: "Español"),
    LanguageInfo(code: 'es-mx', name: "Español mexicano"),
    LanguageInfo(code: 'fr', name: "Français"),
    LanguageInfo(code: 'it', name: "Italiano"),
    LanguageInfo(code: 'ja', name: "日本語"),
    LanguageInfo(code: 'ko', name: "한국어"),
    LanguageInfo(code: 'pl', name: "Polski"),
    LanguageInfo(code: 'pt-br', name: "Português Brasileiro"),
    LanguageInfo(code: 'ru', name: "Русский"),
    LanguageInfo(code: 'zh-cht', name: "繁體中文"),
    LanguageInfo(code: 'zh-chs', name: "简体中文")
  ];

  Future<String> getTranslation(String text, {String? languageCode, Map<String, String> replace = const {}}) async {
    String code = languageCode ?? currentLanguage;
    Map<String, String>? translationMap = await _getTranslationMap(code);
    String? translatedText = translationMap?[text];
    if (translatedText == null) {
      translationMap = await _getTranslationMap(_fallbackLanguage);
      translatedText = translationMap?[text];
    }
    translatedText ??= text;
    return _replace(translatedText, replace);
  }

  String _replace(String text, Map<String, String> replace) {
    replace.forEach((String index, String replaceText) {
      text = text.replaceAll("{$index}", replaceText);
    });
    return text;
  }

  Future<Map<String, String>?> _getTranslationMap(String languageCode) async {
    if (_translationMaps.containsKey(languageCode)) {
      return _translationMaps[languageCode];
    }
    var translations = await _loadTranslationMapFromSavedData(languageCode);
    if (translations == null) {
      translations = await _updateTranslationsFromWeb(languageCode);
      return translations;
    }
    _updateTranslationsFromWeb(languageCode);

    return translations;
  }

  Future<Map<String, String>?> _updateTranslationsFromWeb(String languageCode) async {
    var url = "https://cdn.jsdelivr.net/gh/LittleLightForDestiny/LittleLightTranslations/languages/$languageCode.json";
    var req = await http.get(Uri.parse(url));
    var raw = req.body;
    Map<String, String> translation = Map<String, String>.from(jsonDecode(raw));
    await languageStorage(languageCode).saveTranslations(translation);
    _translationMaps[languageCode] = translation;
    return _translationMaps[languageCode];
  }

  Future<Map<String, String>?> _loadTranslationMapFromSavedData(String languageCode) async {
    final translations = await languageStorage(languageCode).getTranslations();
    return translations;
  }

  Future<List<LanguageInfo>> getManifestSizes() async {
    final languages = this.languages;
    for (final language in languages) {
      final file = await languageStorage(language.code).getManifestDatabaseFile();
      final stat = await file?.stat();
      final size = stat?.size;
      if (size != null) {
        language.sizeInKB = (size / 1024).floor();
      }
    }
    return languages;
  }

  Future<void> deleteLanguage(String code) async {
    await languageStorage(code).purge();
  }
}
