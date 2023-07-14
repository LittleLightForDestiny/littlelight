import 'package:get_it/get_it.dart';
import 'destiny_settings.service.dart';

DestinySettingsService getInjectedDestinySettingsService() => GetIt.I<DestinySettingsService>();

extension Service on DestinySettingsConsumer {
  DestinySettingsService get destinySettings => getInjectedDestinySettingsService();
}

mixin DestinySettingsConsumer {}
