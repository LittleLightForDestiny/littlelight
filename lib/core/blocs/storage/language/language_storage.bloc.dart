import 'package:little_light/core/blocs/storage/global/global_storage.bloc.dart';
import 'package:little_light/services/storage/export.dart';

import 'language_storage.service.dart';

class LanguageStorageBloc {
  Map<String, LanguageStorage> _storages = {};
  GlobalStorageBloc _globalStorageBloc = getInjectedGlobalStorage();
  LanguageStorage get(String language) {
    return _storages[language] ??= getInjectedLanguageStorage(language);
  }

  LanguageStorage? get current {
    final language = _globalStorageBloc.currentLanguage;
    if (language == null) return null;
    return get(language);
  }
}
