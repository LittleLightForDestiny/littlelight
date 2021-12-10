import 'package:little_light/core/routes/little_light_route.dart';
import 'package:little_light/core/routes/pages.dart';

class LittleLightLoginRoute extends LittleLightRoute {
  final String code;
  final String error;
  LittleLightLoginRoute({this.code, this.error}) : super(page: LittleLightPage.Login);
}
