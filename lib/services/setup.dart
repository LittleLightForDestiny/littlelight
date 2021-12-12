import 'package:get_it/get_it.dart';
import 'package:little_light/services/analytics/analytics.service.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/storage/export.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';

import 'littlelight/littlelight_api.service.dart';
import 'littlelight/loadouts.service.dart';
import 'littlelight/objectives.service.dart';
import 'manifest/manifest.service.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart' as dotEnv;

setupServices() async {
  await GetIt.I.reset();
  await setupAuthService();
  await setupStorageService();
  await setupAnalyticsService();
  await setupUserSettingsService();
}

initServices() async {
  final globalStorage = getInjectedGlobalStorage();
  final auth = getInjectedAuthService();
  await globalStorage.setup();
  auth.reset();
  await dotEnv.load(fileName: 'assets/_env');
  await LittleLightApiService().reset();
  await LoadoutsService().reset();
  await ObjectivesService().reset();
  await ManifestService().reset();
}
