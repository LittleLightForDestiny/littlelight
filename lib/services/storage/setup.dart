import 'account_storage.service.dart';
import 'global_storage.service.dart';
import 'language_storage.service.dart';
import 'membership_storage.service.dart';

setupStorageService() async {
  await setupGlobalStorageService();
  await setupAccountStorageService();
  await setupMembershipStorageService();
  await setupLanguageStorageService();
}