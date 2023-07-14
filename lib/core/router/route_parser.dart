import 'package:flutter/material.dart';
import 'package:little_light/core/routes/little_light_route.dart';
import 'package:little_light/core/routes/login_route.dart';
import 'package:little_light/core/routes/main_route.dart';
import 'package:little_light/core/routes/pages.dart';

const Map<String, LittleLightRoutePage> _segmentsToPage = {
  "login": LittleLightRoutePage.Login,
  "": LittleLightRoutePage.Main
};

class LittleLightRouteParser {
  LittleLightRoute parseRoute(RouteSettings route) {
    if (route is LittleLightRoute) {
      return route;
    }
    final uri = Uri.tryParse(route.name ?? "");
    final firstSegment = _getUriSegmentByIndex(uri);
    final page = _getPageBySegmentName(firstSegment);
    if (page == LittleLightRoutePage.Login && uri != null) {
      final args = LittleLightLoginArguments.fromUri(uri);
      return LittleLightLoginRoute(arguments: args);
    }
    return LittleLightMainRoute();
  }

  LittleLightRoutePage? _getPageBySegmentName(String? name) {
    if (_segmentsToPage.containsKey(name)) {
      return _segmentsToPage[name];
    }
    return LittleLightRoutePage.Main;
  }

  String? _getUriSegmentByIndex(Uri? uri, [int index = 0]) {
    try {
      return uri?.pathSegments[index];
    } catch (e) {
      return null;
    }
  }
}
