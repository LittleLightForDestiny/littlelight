import 'package:flutter/material.dart';

import 'dev_mode_main.page_widget.dart';

class DevModeMainPageRoute extends MaterialPageRoute {
  DevModeMainPageRoute()
      : super(
            settings: const RouteSettings(),
            builder: (context) => const DevModeMainPageWidget());
}
