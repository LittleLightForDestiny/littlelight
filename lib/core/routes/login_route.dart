import 'package:little_light/core/routes/little_light_route.dart';
import 'package:little_light/core/routes/pages.dart';

class LittleLightLoginArguments {
  final String? code;
  final String? error;
  LittleLightLoginArguments({this.code, this.error});
  factory LittleLightLoginArguments.fromUri(Uri uri) =>
      LittleLightLoginArguments(code: uri.queryParameters["code"], error: uri.queryParameters["error"]);
}

class LittleLightLoginRoute extends LittleLightRoute<LittleLightLoginArguments> {
  LittleLightLoginRoute({required LittleLightLoginArguments arguments})
      : super(page: LittleLightRoutePage.Login, arguments: arguments);

  LittleLightLoginArguments get loginArguments => arguments;
}
