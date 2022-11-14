import 'package:get_it/get_it.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';

UserSettingsBloc getInjectedUserSettings() => GetIt.I<UserSettingsBloc>();

mixin UserSettingsConsumer {
  UserSettingsBloc get userSettings => getInjectedUserSettings();
}
