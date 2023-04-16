import 'package:flutter/material.dart';
import 'package:little_light/core/routes/login_route.dart';
import 'package:little_light/core/utils/logger/logger.wrapper.dart';
import 'package:little_light/pages/initial/login.page_route.dart';
import 'package:little_light/pages/initial/main.page_route.dart';
import 'package:url_launcher/url_launcher.dart';

import 'route_parser.dart';

class LittleLightRouter {
  const LittleLightRouter();
  Route getPage(RouteSettings route) {
    final parsedRoute = LittleLightRouteParser().parseRoute(route);
    _closeWebView();
    if (parsedRoute is LittleLightLoginRoute) {
      return LoginPageRoute(parsedRoute);
    }
    return MainPageRoute();
  }

  void _closeWebView() async {
    try {
      await closeInAppWebView();
    } catch (e) {
      logger.error("can't close webview");
    }
  }
}
