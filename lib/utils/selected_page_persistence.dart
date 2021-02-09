import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/storage/storage.service.dart';
import 'package:little_light/utils/platform_capabilities.dart';

FirebaseAnalytics _analytics = FirebaseAnalytics();

class SelectedPagePersistence {
  static const String equipment = "Equipment";
  static const String collections = "Collections";
  static const String triumphs = "Triumphs";
  static const String loadouts = "Loadouts";
  static const String progress = "Progress";
  static const String duplicatedItems = "DuplicatedItems";
  static const String search = "Search";
  static const String armory = "Armory";
  static const List<String> logged = [equipment, loadouts, progress, search];
  static const List<String> public = [collections, triumphs, armory];

  static Future<String> getLatestScreen() async {
    StorageService _prefs = StorageService.global();
    String latest = _prefs.getString(StorageKeys.latestScreen);
    AuthService auth = new AuthService();
    if (auth.isLogged) {
      List<String> all = logged + public;
      if (all.contains(latest)) {
        return latest;
      }
      return all.first;
    }
    if (public.contains(latest)) {
      return latest;
    }
    return public.first;
  }

  static saveLatestScreen(String screen) async {
    if (PlatformCapabilities.firebaseAnalyticsAvailable) {
      _analytics.setCurrentScreen(
          screenName: screen, screenClassOverride: screen);
    }

    StorageService _prefs = StorageService.global();
    _prefs.setString(StorageKeys.latestScreen, screen);
  }
}
