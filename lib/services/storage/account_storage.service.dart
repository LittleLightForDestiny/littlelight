//@dart=2.12

import 'package:bungie_api/helpers/bungie_net_token.dart';
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

  Future<BungieNetToken?> getLatestToken() async {
    try {
      final Map<String, dynamic> json = await getJson(AccountStorageKeys.latestToken);
      return BungieNetToken.fromJson(json);
    } catch (e) {
      print("can't parse latest token");
      print(e);
    }
    return null;
  }

  Future<void> saveLatestToken(BungieNetToken token) async {
    await setJson(AccountStorageKeys.latestToken, token);
  }
}
