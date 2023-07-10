import 'package:collection/collection.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/setup.dart';
import 'package:little_light/services/user_settings/little_light_persistent_page.dart';
import 'package:little_light/utils/platform_capabilities.dart';

setupAnalyticsService() async {
  if (PlatformCapabilities.firebaseAnalyticsAvailable) {
    await Firebase.initializeApp();
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }
  final isRegistered = getItCoreInstance?.isRegistered<AnalyticsService>() ?? false;
  if (!isRegistered) {
    getItCoreInstance?.registerSingleton<AnalyticsService>(AnalyticsService._internal());
  }
}

class AnalyticsService with AuthConsumer {
  FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;

  AnalyticsService._internal();

  List<NavigatorObserver> get observers =>
      PlatformCapabilities.firebaseAnalyticsAvailable ? [FirebaseAnalyticsObserver(analytics: _analytics)] : [];

  registerPageOpen(LittleLightPersistentPage page) {
    if (PlatformCapabilities.firebaseAnalyticsAvailable) {
      _analytics.setCurrentScreen(screenName: page.name, screenClassOverride: page.name);
    }
  }

  void registerNonFatal(e, StackTrace? stackTrace, {Map<String, String>? additionalInfo}) {
    if (!PlatformCapabilities.firebaseAnalyticsAvailable) return;
    if (additionalInfo != null) {
      for (final key in additionalInfo.keys) {
        FirebaseCrashlytics.instance.log("$key : ${additionalInfo[key]}");
      }
    }

    FirebaseCrashlytics.instance.recordError(e, stackTrace);
  }

  void registerUserFeedback(FlutterErrorDetails e, String userIdentifier, Map<String, String> customData) {
    if (!PlatformCapabilities.firebaseAnalyticsAvailable) return;
    FirebaseCrashlytics.instance.setUserIdentifier(userIdentifier);
    for (final key in customData.keys) {
      if (customData[key] != null) {
        FirebaseCrashlytics.instance.setCustomKey(key, customData[key]!);
      }
    }
    FirebaseCrashlytics.instance.recordFlutterError(e);
  }

  void updateCurrentUser() async {
    if (!PlatformCapabilities.firebaseAnalyticsAvailable) return;
    final membershipData = await auth.getMembershipData();
    final currentMembership =
        membershipData?.destinyMemberships?.firstWhereOrNull((m) => m.membershipId == auth.currentMembershipID);
    final membershipID = auth.currentMembershipID;
    final accountID = auth.currentAccountID;
    final membershipDisplayName = currentMembership?.displayName;
    final accountUniqueName = membershipData?.bungieNetUser?.uniqueName;
    final userIdentifier = accountUniqueName ?? membershipDisplayName ?? membershipID;
    if (userIdentifier != null) {
      FirebaseCrashlytics.instance.setUserIdentifier(userIdentifier);
    }
    if (membershipID != null) {
      FirebaseCrashlytics.instance.setCustomKey("membershipID", membershipID);
    }
    if (accountID != null) {
      FirebaseCrashlytics.instance.setCustomKey("accountID", accountID);
    }
    if (membershipDisplayName != null) {
      FirebaseCrashlytics.instance.setCustomKey("membershipDisplayName", membershipDisplayName);
    }
    if (accountUniqueName != null) {
      FirebaseCrashlytics.instance.setCustomKey("accountUniqueName", accountUniqueName);
    }
  }
}
