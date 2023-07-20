import 'package:flutter/material.dart';
import '../../../pages/initial/initial.page_container.dart';

class MainPageRoute extends MaterialPageRoute {
  MainPageRoute()
      : super(
          builder: (context) => const InitialPageContianer(),
        );
}
