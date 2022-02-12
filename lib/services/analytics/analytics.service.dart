//@dart=2.12
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:little_light/services/user_settings/little_light_persistent_page.dart';
import 'package:little_light/utils/platform_capabilities.dart';

setupAnalyticsService() async {
  await Firebase.initializeApp();
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  GetIt.I.registerSingleton<AnalyticsService>(AnalyticsService._internal());
}

class AnalyticsService {
  FirebaseAnalytics _analytics = FirebaseAnalytics();

  AnalyticsService._internal();

  List<NavigatorObserver> get observers =>
      PlatformCapabilities.firebaseAnalyticsAvailable ? [FirebaseAnalyticsObserver(analytics: _analytics)] : [];

  registerPageOpen(LittleLightPersistentPage page) {
    if (PlatformCapabilities.firebaseAnalyticsAvailable) {
      _analytics.setCurrentScreen(screenName: page.name, screenClassOverride: page.name);
    }
  }

  void registerNonFatal(e, StackTrace? stackTrace) {
    FirebaseCrashlytics.instance.recordError(e, stackTrace);
  }

  void registerUserFeedback(FlutterErrorDetails e, String userIdentifier, Map<String, String> customData) {
    FirebaseCrashlytics.instance.setUserIdentifier(userIdentifier);
    for (final key in customData.keys) {
      if (customData[key] != null) {
        FirebaseCrashlytics.instance.setCustomKey(key, customData[key]!);
      }
    }
    FirebaseCrashlytics.instance.recordFlutterError(e);
  }
}
