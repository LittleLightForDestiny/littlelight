import 'package:flutter/material.dart';
import 'package:little_light/pages/initial/initial.page_container.dart';

class LoginPageRoute extends MaterialPageRoute {
  LoginPageRoute(RouteSettings settings)
      : super(
          settings: settings,
          builder: (context) => InitialPageContianer(),
        );
}
