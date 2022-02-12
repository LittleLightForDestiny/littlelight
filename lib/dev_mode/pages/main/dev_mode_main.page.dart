//@dart=2.12
import 'package:flutter/material.dart';

import 'dev_mode_main.page_widget.dart';


class DevModeMainPageRoute extends MaterialPageRoute {
  DevModeMainPageRoute():super(
    settings: RouteSettings(),
    builder: (context)=>DevModeMainPageWidget());
}