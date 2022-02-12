//@dart=2.12
import 'dart:io';

class PlatformCapabilities {
  static bool get firebaseAnalyticsAvailable {
    return Platform.isAndroid || Platform.isIOS;
  }

  static bool get keepScreenOnAvailable {
    return Platform.isAndroid || Platform.isIOS;
  }
}
