import 'package:little_light/core/blocs/storage/global/global_storage.bloc.dart';
import 'package:little_light/services/storage/export.dart';

import 'membership_storage.service.dart';

class MembershipStorageBloc {
  Map<String, MembershipStorage> _storages = {};
  GlobalStorageBloc _globalStorageBloc = getInjectedGlobalStorage();
  MembershipStorage get(String language) {
    return _storages[language] ??= getInjectedMembershipStorage(language);
  }

  MembershipStorage? get current {
    final language = _globalStorageBloc.currentAccountID;
    if (language == null) return null;
    return get(language);
  }
}
