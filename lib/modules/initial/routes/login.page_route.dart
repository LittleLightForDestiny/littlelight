import 'package:flutter/material.dart';

import '../pages/initial/initial.page.dart';

class LoginPageRoute extends MaterialPageRoute {
  LoginPageRoute(RouteSettings settings)
    : super(
        settings: settings,
        builder: (context) => const InitialPageContainer(),
      );
}
