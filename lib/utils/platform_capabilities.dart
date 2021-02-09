import 'dart:io';

import 'package:flutter/material.dart';

class PlatformCapabilities {
  static bool get firebaseAnalyticsAvailable {
    return Platform.isAndroid || Platform.isIOS;
  }

  static bool get keepScreenOnAvailable {
    return Platform.isAndroid || Platform.isIOS;
  }
}
