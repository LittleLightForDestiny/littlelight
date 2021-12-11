import 'package:flutter/material.dart';
import 'package:little_light/core/routes/little_light_route.dart';
import 'package:little_light/core/routes/login_route.dart';
import 'package:little_light/core/routes/pages.dart';

const Map<String, LittleLightRoutePage> _segmentsToPage = {
  "login" : LittleLightRoutePage.Login,
  "" : LittleLightRoutePage.Main
};

class LittleLightRouteInformationParser extends RouteInformationParser<LittleLightRoute>{
  
  @override
  Future<LittleLightRoute> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = Uri.tryParse(routeInformation.location);
    final firstSegment = _getUriSegmentByIndex(uri);
    final page = _getPageBySegmentName(firstSegment);
    if(page == LittleLightRoutePage.Login) {
      return LittleLightLoginRoute(code:uri.queryParameters["code"], error:uri.queryParameters["error"]);
    }
    return LittleLightRoute();
  }

  LittleLightRoutePage _getPageBySegmentName(String name){
    if(_segmentsToPage.containsKey(name)){
      return _segmentsToPage[name];
    }
    return LittleLightRoutePage.Main;
  }

  String _getUriSegmentByIndex(Uri uri, [int index = 0]){
    try {
      return uri.pathSegments[index];
    }catch(e){
      return null;
    }
  }

}