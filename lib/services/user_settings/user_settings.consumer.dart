import 'package:get_it/get_it.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';

UserSettingsService getInjectedUserSettings() =>
    GetIt.I<UserSettingsService>();

mixin UserSettingsConsumer {
  UserSettingsService get userSettings => getInjectedUserSettings();
}