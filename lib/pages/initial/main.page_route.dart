//@dart=2.12
import 'package:flutter/material.dart';
import 'initial.page_container.dart';

class MainPageRoute extends MaterialPageRoute {
  MainPageRoute()
      : super(
          builder: (context) => InitialPageContianer(),
        );
}
