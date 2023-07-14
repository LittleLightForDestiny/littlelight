import 'package:flutter/material.dart';
import 'package:little_light/core/routes/pages.dart';

abstract class LittleLightRoute<T extends Object> extends RouteSettings {
  final LittleLightRoutePage page;
  @override
  T get arguments => super.arguments as T;
  LittleLightRoute({this.page = LittleLightRoutePage.Main, T? arguments})
      : super(name: page.name, arguments: arguments);
}
