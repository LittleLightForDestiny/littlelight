import 'package:flutter/material.dart';

import '../pages/main/initial.page.dart';

class LoginPageRoute extends MaterialPageRoute {
  LoginPageRoute(RouteSettings settings)
      : super(
          settings: settings,
          builder: (context) => const InitialPageContianer(),
        );
}
