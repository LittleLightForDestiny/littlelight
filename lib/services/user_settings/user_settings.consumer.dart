import 'package:get_it/get_it.dart';
import 'package:little_light/core/repositories/user_settings/user_settings.repository.dart';

UserSettingsRepository getInjectedUserSettings() => GetIt.I<UserSettingsRepository>();

mixin UserSettingsConsumer {
  UserSettingsRepository get userSettings => getInjectedUserSettings();
}
