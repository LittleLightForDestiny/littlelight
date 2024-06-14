import '../../core/blocs/storage/account/account_storage.service.dart';
import '../../core/blocs/storage/global/global_storage.bloc.dart';
import '../../core/blocs/storage/language/language_storage.service.dart';
import '../../core/blocs/storage/membership/membership_storage.service.dart';

setupStorageService() async {
  await setupGlobalStorageService();
  await setupAccountStorageService();
  await setupMembershipStorageService();
  await setupLanguageStorageService();
}
