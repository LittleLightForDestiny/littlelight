import 'package:flutter/material.dart';

mixin RouteParams<T> {
  T getRouteParams(BuildContext context) =>
      ModalRoute.of(context)?.settings?.arguments;
}
