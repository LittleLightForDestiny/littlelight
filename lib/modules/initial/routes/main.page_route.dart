import 'package:flutter/material.dart';

import '../pages/initial/initial.page.dart';

class MainPageRoute extends MaterialPageRoute {
  MainPageRoute()
    : super(
        builder: (context) => const InitialPageContainer(),
      );
}
