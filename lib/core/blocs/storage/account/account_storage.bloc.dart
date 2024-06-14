import 'package:little_light/core/blocs/storage/global/global_storage.bloc.dart';
import 'package:little_light/services/storage/export.dart';

import 'account_storage.service.dart';

class AccountStorageBloc {
  Map<String, AccountStorage> _storages = {};
  GlobalStorageBloc _globalStorageBloc = getInjectedGlobalStorage();
  AccountStorage get(String language) {
    return _storages[language] ??= getInjectedAccountStorage(language);
  }

  AccountStorage? get current {
    final language = _globalStorageBloc.currentAccountID;
    if (language == null) return null;
    return get(language);
  }
}
