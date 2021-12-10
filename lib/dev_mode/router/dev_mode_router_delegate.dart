import 'package:flutter/material.dart';
import 'package:little_light/core/routes/little_light_route.dart';
import 'package:little_light/core/routes/login_route.dart';
import 'package:little_light/dev_mode/pages/login/dev_mode_login.page.dart';
import 'package:little_light/dev_mode/pages/main/dev_mode_main.page.dart';

class DevModeRouterDelegate extends RouterDelegate<LittleLightRoute> with ChangeNotifier, PopNavigatorRouterDelegateMixin{
  LittleLightRoute route;


  @override
  Widget build(BuildContext context) {
      return Navigator(
        onPopPage: onPopPage,
        pages:[
          route is LittleLightLoginRoute ? loginPage(route) : mainPage(route)
        ]);

  }

  MaterialPage loginPage(LittleLightLoginRoute route)=>DevModeLoginPage(route.code, route.error);
  MaterialPage mainPage(LittleLightRoute route)=>DevModeMainPage();

  @override
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();

  @override
  Future<void> setNewRoutePath(LittleLightRoute route) async{
    this.route = route;
    notifyListeners();
  }

  bool  onPopPage(Route<dynamic> route, dynamic result) {
    final  bool success = route.didPop(result);
    if (success) {
        this.route = LittleLightRoute();
        notifyListeners();
    }
    return success;
}
  
}