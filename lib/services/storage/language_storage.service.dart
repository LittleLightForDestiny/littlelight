//@dart=2.12

import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:get_it/get_it.dart';

import 'language_storage.keys.dart';
import 'storage.base.dart';

setupLanguageStorageService() async {
  GetIt.I.registerFactoryParam<LanguageStorage, String, void>(
      (accountID, _) => LanguageStorage._internal(accountID));
}

class LanguageStorage extends StorageBase<LanguageStorageKeys> {
  LanguageStorage._internal(_accountID):super("accounts/$_accountID");

  @override
  String getKeyPath(LanguageStorageKeys? key) {
    return key?.path ?? "";
  }
}
