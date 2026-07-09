import 'dart:io';

import 'package:flutter/foundation.dart';

class PlatformCapabilities {
  static bool get firebaseAnalyticsAvailable {
    if (kDebugMode) return false;
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
  }

  static bool get keepScreenOnAvailable {
    return Platform.isAndroid || Platform.isIOS;
  }
}
