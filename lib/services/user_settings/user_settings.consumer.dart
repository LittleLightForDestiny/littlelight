//@dart=2.12
import 'package:get_it/get_it.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/user_settings/user_settings.service.dart';

UserSettingsService getInjectedUserSettings() =>
    GetIt.I<UserSettingsService>();

mixin UserSettingsConsumer {
  UserSettingsService get userSettings => getInjectedUserSettings();
}