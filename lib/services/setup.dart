//@dart=2.12
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:little_light/services/analytics/analytics.service.dart';
import 'package:little_light/services/app_config/app_config.consumer.dart';
import 'package:little_light/services/app_config/app_config.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/inventory/inventory.service.dart';
import 'package:little_light/services/language/language.consumer.dart';
import 'package:little_light/services/language/language.service.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/littlelight/item_notes.service.dart';
import 'package:little_light/services/littlelight/littlelight_data.service.dart';
import 'package:little_light/services/littlelight/loadouts.service.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/destiny_settings.consumer.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/profile/destiny_settings.service.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/profile/profile.service.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/selection/selection.service.dart';
import 'package:little_light/services/storage/export.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/user_settings/user_settings.service.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'littlelight/littlelight_api.service.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'littlelight/objectives.service.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'manifest/manifest.service.dart';

final getItCoreInstance = GetIt.asNewInstance();

Future<void> setupCoreServices() async {
  getItCoreInstance.reset();
  await setupAnalyticsService();
}

Future<void> setupServices() async {
  await GetIt.I.reset();
  await setupStorageService();
  await setupAppConfig();
  await setupAuthService();
  await setupLanguageService();
  await setupUserSettingsService();
  await setupManifest();
  await setupProfileService();
  await setupLittleLightDataService();
  await setupWishlistsService();
  await setupBungieApiService();
  await setupLoadoutsService();
  await setupNotificationService();
  await setupSelectionService();
  await setupitemNotes();
  await setupInventoryService();
  await setupDestinySettingsService();
}

initServices(BuildContext context) async {
  final appConfig = getInjectedAppConfig();
  final globalStorage = getInjectedGlobalStorage();
  final auth = getInjectedAuthService();
  final language = getInjectedLanguageService();
  final manifest = getInjectedManifestService();
  await appConfig.setup();
  await globalStorage.setup();
  auth.setup();
  await language.init(context);
  await LittleLightApiService().reset();
  await ObjectivesService().reset();
  await manifest.setup();
}

initPostLoadingServices(BuildContext context) async {
  final settings = getInjectedUserSettings();
  await settings.init();
  final destinySettings = getInjectedDestinySettingsService();
  await destinySettings.init();
  final profile = getInjectedProfileService();
  await profile.init();
}
