import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/app/app.bloc.dart';
import 'package:little_light/core/blocs/language/language.bloc.dart';
import 'package:little_light/core/blocs/storage/language/language_storage.bloc.dart';
import 'package:provider/provider.dart';

class ChangeLanguageBloc extends ChangeNotifier {
  final AppBloc _appBloc;
  final LanguageBloc _languageBloc;
  final LanguageStorageBloc _languageStorageBloc;

  List<String>? _availableLanguages;
  String? _currentLanguage;
  String? _selectedLanguage;
  Map<String, int>? _languageSizes;

  factory ChangeLanguageBloc(BuildContext context) {
    return ChangeLanguageBloc._internal(
      languageBloc: context.read<LanguageBloc>(),
      languageStorageBloc: context.read<LanguageStorageBloc>(),
      appBloc: context.read<AppBloc>(),
    );
  }

  ChangeLanguageBloc._internal({
    required LanguageBloc languageBloc,
    required LanguageStorageBloc languageStorageBloc,
    required AppBloc appBloc,
  })  : _languageBloc = languageBloc,
        _languageStorageBloc = languageStorageBloc,
        _appBloc = appBloc,
        super() {
    _init();
  }

  void _init() {
    _loadLanguageSizes();
  }

  List<String>? get availableLanguages => _availableLanguages;

  String? get currentLanguage => _currentLanguage;

  String? get selectedLanguage => _selectedLanguage;
  set selectedLanguage(String? value) {
    _selectedLanguage = value;
    notifyListeners();
  }

  bool get loaded => _languageSizes != null;

  bool get canSave => _currentLanguage != _selectedLanguage;

  bool canDeleteLanguage(String language) => _languageSizes?[language] != null && language != currentLanguage;

  int? getLanguageSize(String language) {
    final sizeInKb = _languageSizes?[language];
    if (sizeInKb == null) return null;
    final sizeInMb = (sizeInKb / 1024).floor();
    return sizeInMb;
  }

  void _loadLanguageSizes() async {
    _currentLanguage = _selectedLanguage = _languageBloc.currentLanguage;
    final languages = this._languageBloc.availableLanguages;
    final sizeMap = <String, int>{};
    for (final language in languages) {
      final file = await _languageStorageBloc.get(language).getManifestDatabaseFile();
      final stat = await file?.stat();
      final exists = await file?.exists() ?? false;
      final size = stat?.size;
      if (size != null && exists) {
        sizeMap[language] = (size / 1024).floor();
      }
    }
    this._availableLanguages = languages;
    this._languageSizes = sizeMap;
    notifyListeners();
  }

  void save() {
    _languageBloc.selectedLanguage = selectedLanguage;
    _appBloc.restart();
  }

  void delete(String language) async {
    await _languageBloc.deleteLanguage(language);
    _loadLanguageSizes();
  }
}
