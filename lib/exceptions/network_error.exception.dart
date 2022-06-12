import 'package:little_light/exceptions/littlelight.exception.base.dart';

class NetworkErrorException extends LittleLightBaseException {
  String? url;
  NetworkErrorException(dynamic sourceException, {this.url}) : super(sourceException);
}
