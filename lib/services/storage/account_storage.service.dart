//@dart=2.12

import 'package:get_it/get_it.dart';

import 'account_storage.keys.dart';
import 'storage.base.dart';

setupAccountStorageService() async {
  GetIt.I.registerFactoryParam<AccountStorage, String, void>(
      (accountID, _) => AccountStorage._internal(accountID));
}

class AccountStorage extends StorageBase<AccountStorageKeys> {
  AccountStorage._internal(_accountID):super("accounts/$_accountID");

  @override
  String getKeyPath(AccountStorageKeys? key) {
    return key?.path ?? "";
  }
}
