//@dart=2.12

import 'package:flutter/material.dart';
import 'package:little_light/core/router/route_parser.dart';
import 'package:little_light/core/routes/login_route.dart';
import 'package:little_light/dev_mode/pages/login/dev_mode_login.page.dart';
import 'package:little_light/dev_mode/pages/main/dev_mode_main.page.dart';
import 'package:url_launcher/url_launcher.dart';

class DevModeRouter {
  const DevModeRouter();
  Route getPage(RouteSettings route) {
    final parsedRoute = LittleLightRouteParser().parseRoute(route);
    _closeWebView();
    if (parsedRoute is LittleLightLoginRoute) {
      return DevModeLoginPageRoute(parsedRoute);
    }
    return DevModeMainPageRoute();
  }

  void _closeWebView() async {
    try{
      await closeWebView();
    }catch(e){
      print("can't close webview");
    }
  }
}
