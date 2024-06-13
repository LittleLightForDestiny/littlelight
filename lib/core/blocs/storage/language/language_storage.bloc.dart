import 'package:little_light/services/storage/export.dart';
import 'package:little_light/services/storage/global_storage.service.dart';
import 'package:little_light/services/storage/language_storage.service.dart';

class LanguageStorageBloc {
  Map<String, LanguageStorage> _storages = {};
  GlobalStorage _globalStorageBloc = getInjectedGlobalStorage();
  LanguageStorage get(String language) {
    return _storages[language] ??= getInjectedLanguageStorage(language);
  }

  LanguageStorage? get current {
    final language = _globalStorageBloc.currentLanguage;
    if (language == null) return null;
    return get(language);
  }
}
