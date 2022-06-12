import 'package:little_light/exceptions/littlelight.exception.base.dart';

class ParseException extends LittleLightBaseException {
  final dynamic sourceData;
  ParseException(this.sourceData, dynamic sourceException) : super(sourceException);
}
