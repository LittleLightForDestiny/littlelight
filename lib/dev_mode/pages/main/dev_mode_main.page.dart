import 'package:flutter/material.dart';

import 'dev_mode_main.page_widget.dart';


class DevModeMainPageRoute extends MaterialPageRoute {
  DevModeMainPageRoute():super(builder: (context)=>DevModeMainPageWidget());
}

class DevModeMainPage extends MaterialPage {
  DevModeMainPage() : super(child: DevModeMainPageWidget());
}
