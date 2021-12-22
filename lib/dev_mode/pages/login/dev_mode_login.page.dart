//@dart=2.12

import 'package:flutter/material.dart';
import 'package:little_light/dev_mode/pages/login/dev_mode_login.page_widget.dart';

class DevModeLoginPageRoute extends MaterialPageRoute {
  DevModeLoginPageRoute(RouteSettings settings)
      : super(
            settings: settings, builder: (context) => DevModeLoginPageWidget());
}
