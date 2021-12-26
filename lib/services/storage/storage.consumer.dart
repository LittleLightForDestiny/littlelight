//@dart=2.12
import 'package:get_it/get_it.dart';
import 'package:little_light/services/language/language.consumer.dart';

import 'account_storage.service.dart';
import 'global_storage.service.dart';
import 'language_storage.service.dart';
import 'membership_storage.service.dart';

GlobalStorage getInjectedGlobalStorage() => GetIt.I<GlobalStorage>();
AccountStorage getInjectedAccountStorage(String accountID) =>
    GetIt.I<AccountStorage>(param1: accountID);
MembershipStorage getInjectedMembershipStorage(String membershipID) =>
    GetIt.I<MembershipStorage>(param1: membershipID);
LanguageStorage getInjectedLanguageStorage(String languageCode) =>
    GetIt.I<LanguageStorage>(param1: languageCode);

mixin StorageConsumer {
  GlobalStorage get globalStorage => getInjectedGlobalStorage();
  
  AccountStorage accountStorage(String accountID) =>
      getInjectedAccountStorage(accountID);

  AccountStorage get currentAccountStorage =>
      getInjectedAccountStorage(globalStorage.currentAccountID!);

  MembershipStorage membershipStorage(String membershipID) =>
      getInjectedMembershipStorage(membershipID);

  MembershipStorage get currentMembershipStorage =>
      getInjectedMembershipStorage(globalStorage.currentMembershipID!);

  LanguageStorage languageStorage(String code) =>
      getInjectedLanguageStorage(code);

  LanguageStorage get currentLanguageStorage {
    final language = getInjectedLanguageService().currentLanguage;
    return getInjectedLanguageStorage(language);
  }
}
