import 'package:flutter/material.dart';

import '../pages/main/initial.page.dart';

class MainPageRoute extends MaterialPageRoute {
  MainPageRoute()
      : super(
          builder: (context) => const InitialPageContianer(),
        );
}
