//@dart=2.12
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:little_light/services/analytics/analytics.service.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/language/language.consumer.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/language/language.service.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/storage/export.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/user_settings/user_settings.service.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'littlelight/littlelight_api.service.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'littlelight/loadouts.service.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'littlelight/objectives.service.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'manifest/manifest.service.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotEnv;

setupServices() async {
  await GetIt.I.reset();
  await setupAnalyticsService();
  await setupAuthService();
  await setupStorageService();
  await setupLanguageService();
  await setupUserSettingsService();
  await setupManifest();
}

initServices(BuildContext context) async {
  final globalStorage = getInjectedGlobalStorage();
  final auth = getInjectedAuthService();
  final language = getInjectedLanguageService();
  await globalStorage.setup();
  auth.setup();
  await dotEnv.load(fileName: 'assets/_env');
  await language.init(context);
  await LittleLightApiService().reset();
  await LoadoutsService().reset();
  await ObjectivesService().reset();
  await ManifestService().reset();
}
