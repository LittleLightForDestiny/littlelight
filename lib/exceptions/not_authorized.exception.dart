import 'package:little_light/exceptions/littlelight.exception.base.dart';

class NotAuthorizedException extends LittleLightBaseException {
  NotAuthorizedException(sourceError) : super(sourceError);
}
