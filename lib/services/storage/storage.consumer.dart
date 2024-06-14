import 'package:get_it/get_it.dart';
import 'package:little_light/exceptions/not_initialized.exception.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import '../../core/blocs/storage/account/account_storage.service.dart';
import '../../core/blocs/storage/global/global_storage.bloc.dart';
import '../../core/blocs/storage/language/language_storage.service.dart';
import '../../core/blocs/storage/membership/membership_storage.service.dart';

GlobalStorageBloc getInjectedGlobalStorage() => GetIt.I<GlobalStorageBloc>();
AccountStorage getInjectedAccountStorage(String accountID) => GetIt.I<AccountStorage>(param1: accountID);
MembershipStorage getInjectedMembershipStorage(String membershipID) => GetIt.I<MembershipStorage>(param1: membershipID);
LanguageStorage getInjectedLanguageStorage(String languageCode) => GetIt.I<LanguageStorage>(param1: languageCode);

extension Storages on StorageConsumer {
  GlobalStorageBloc get globalStorage => getInjectedGlobalStorage();

  AccountStorage accountStorage(String accountID) => getInjectedAccountStorage(accountID);

  AccountStorage get currentAccountStorage {
    final accountID = globalStorage.currentAccountID;
    if (accountID == null) {
      throw NotInitializedException(Exception("currentMembershipStorage was called before currentAccountID was set"));
    }
    return getInjectedAccountStorage(accountID);
  }

  MembershipStorage membershipStorage(String membershipID) => getInjectedMembershipStorage(membershipID);

  MembershipStorage get currentMembershipStorage {
    final membershipID = globalStorage.currentMembershipID;
    if (membershipID == null) {
      throw NotInitializedException(
          Exception("currentMembershipStorage was called before currentMembershipID was set"));
    }
    return getInjectedMembershipStorage(membershipID);
  }

  LanguageStorage languageStorage(String code) => getInjectedLanguageStorage(code);

  LanguageStorage get currentLanguageStorage {
    final language = getInjectedLanguageService().currentLanguage;
    return getInjectedLanguageStorage(language);
  }
}

mixin StorageConsumer {}
