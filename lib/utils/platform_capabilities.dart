import 'dart:io';

class PlatformCapabilities {
  static bool get firebaseAnalyticsAvailable {
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
  }

  static bool get keepScreenOnAvailable {
    return Platform.isAndroid || Platform.isIOS;
  }
}
