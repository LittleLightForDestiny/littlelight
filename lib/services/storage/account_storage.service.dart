import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:get_it/get_it.dart';
import 'package:little_light/core/utils/logger/logger.wrapper.dart';

import 'account_storage.keys.dart';
import 'storage.base.dart';

setupAccountStorageService() async {
  GetIt.I.registerFactoryParam<AccountStorage, String, void>((accountID, _) => AccountStorage._internal(accountID));
}

class AccountStorage extends StorageBase<AccountStorageKeys> {
  AccountStorage._internal(String _accountID) : super("accounts/$_accountID");

  @override
  String getKeyPath(AccountStorageKeys? key) {
    return key?.path ?? "";
  }

  Future<BungieNetToken?> getLatestToken() async {
    try {
      final Map<String, dynamic> json = await getJson(AccountStorageKeys.latestToken);
      return BungieNetToken.fromJson(json);
    } catch (e) {
      logger.error("can't parse latest token", error: e);
    }
    return null;
  }

  DateTime? getLatestTokenDate() => getDate(AccountStorageKeys.latestTokenDate);

  Future<void> saveLatestToken(BungieNetToken token) async {
    await setJson(AccountStorageKeys.latestToken, token);
    await setDate(AccountStorageKeys.latestTokenDate, DateTime.now());
  }

  Future<void> clearToken() async {
    await setJson(AccountStorageKeys.latestToken, null);
  }

  Future<void> saveMembershipData(UserMembershipData membershipData) async {
    await setJson(AccountStorageKeys.membershipData, membershipData.toJson());
  }

  Future<UserMembershipData?> getMembershipData() async {
    try {
      final Map<String, dynamic> json = await getJson(AccountStorageKeys.membershipData);
      return UserMembershipData.fromJson(json);
    } catch (e) {
      logger.error("can't parse latest token", error: e);
    }
    return null;
  }

  Future<void> purge() async {
    for (var key in AccountStorageKeys.values) {
      await clearKey(key);
    }
    final accountRoot = getFilePath(null);
    await deleteFile(accountRoot);
  }
}
