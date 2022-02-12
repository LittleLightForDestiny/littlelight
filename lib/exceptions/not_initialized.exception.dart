//@dart=2.12
import 'package:little_light/exceptions/littlelight.exception.base.dart';

class NotInitializedException extends LittleLightBaseException {
  NotInitializedException(dynamic sourceException) : super(sourceException);
}
