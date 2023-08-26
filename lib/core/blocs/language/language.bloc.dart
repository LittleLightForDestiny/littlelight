import 'dart:convert';
import 'dart:core';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:little_light/core/utils/logger/logger.wrapper.dart';
import 'package:little_light/models/language_info.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/storage/export.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'timeago_messages/translated_lookup_messages.dart';
import 'timeago_messages/translated_short_lookup_messages.dart';

setupLanguageService() {
  GetIt.I.registerSingleton<LanguageBloc>(LanguageBloc._internal());
}

class LanguageBloc extends ChangeNotifier with StorageConsumer, ManifestConsumer {
  final _fallbackLanguage = "en";
  String? _systemLanguage;
  String? get selectedLanguage => globalStorage.currentLanguage;
  set selectedLanguage(String? value) {
    manifest.closeDB();
    globalStorage.currentLanguage = value;
    _loadTranslations();
  }

  String get currentLanguage => selectedLanguage ?? _systemLanguage ?? _fallbackLanguage;
  final Map<String, Map<String, String>> _translationMaps = {};
  final Map<String, bool> _loading = {};

  LanguageBloc._internal();

  init(BuildContext context) {
    timeago.setLocaleMessages('auto', TranslatedLookupMessages(this));
    timeago.setLocaleMessages('short_auto', ShortTranslatedLookupMessages(this));
    timeago.setDefaultLocale('auto');

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

    _loadTranslations();
  }

  _loadTranslations([String? code]) async {
    code ??= currentLanguage;
    if (_loading[code] ?? false) {
      return;
    }
    _loading[code] = true;
    final savedTranslations = await _loadTranslationMapFromSavedData(code);
    if (savedTranslations != null) {
      notifyListeners();
    }
    final webTranslations = await _updateTranslationsFromWeb(code);
    if (webTranslations != null) {
      notifyListeners();
    }
    _loading[code] = false;
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

  String translate(String text,
      {String? languageCode, Map<String, String> replace = const {}, String? overrideDefaultText}) {
    String code = languageCode ?? currentLanguage;
    Map<String, String>? translationMap = _translationMaps[code];
    if (translationMap == null) {
      _loadTranslations(code);
    }
    if (_loading[code] ?? false) {
      return "";
    }
    String? translatedText = translationMap?[text];

    if (overrideDefaultText != null) {
      final shouldOverride = translatedText == text || translatedText == null;
      if (shouldOverride) translatedText = overrideDefaultText;
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
    Map<String, String> translation;
    try {
      var url =
          "https://fastly.jsdelivr.net/gh/LittleLightForDestiny/LittleLightTranslations/languages/$languageCode.json";
      var req = await http.get(Uri.parse(url));
      var raw = req.body;
      translation = Map<String, String>.from(jsonDecode(raw));
    } catch (e) {
      logger.error("couldn't fetch translations from repository");
      return null;
    }

    await languageStorage(languageCode).saveTranslations(translation);
    _translationMaps[languageCode] = translation;
    return _translationMaps[languageCode];
  }

  Future<Map<String, String>?> _loadTranslationMapFromSavedData(String languageCode) async {
    final translations = await languageStorage(languageCode).getTranslations();
    if (translations != null) {
      _translationMaps[languageCode] = translations;
    }
    return translations;
  }

  Future<List<LanguageInfo>> getManifestSizes() async {
    final languages = this.languages;
    for (final language in languages) {
      final file = await languageStorage(language.code).getManifestDatabaseFile();
      final stat = await file?.stat();
      final exists = await file?.exists() ?? false;
      final size = stat?.size;
      if (size != null && exists) {
        language.sizeInKB = (size / 1024).floor();
      } else {
        language.sizeInKB = null;
      }
    }
    return languages;
  }

  Future<void> deleteLanguage(String code) async {
    await languageStorage(code).purge();
  }
}
