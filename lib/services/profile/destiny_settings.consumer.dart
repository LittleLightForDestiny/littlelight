//@dart=2.12
import 'package:get_it/get_it.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'destiny_settings.service.dart';

DestinySettingsService getInjectedDestinySettingsService() => GetIt.I<DestinySettingsService>();

extension Service on DestinySettingsConsumer {
  DestinySettingsService get destinySettings => getInjectedDestinySettingsService();
}

mixin DestinySettingsConsumer {}
