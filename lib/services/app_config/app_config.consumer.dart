import 'package:get_it/get_it.dart';
import 'app_config.dart';

AppConfig getInjectedAppConfig() => GetIt.I<AppConfig>();

extension AppConfigProvider on AppConfigConsumer {
  @deprecated
  AppConfig get appConfig => getInjectedAppConfig();
}

mixin AppConfigConsumer {}
