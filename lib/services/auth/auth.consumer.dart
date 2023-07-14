import 'package:get_it/get_it.dart';
import 'package:little_light/services/auth/auth.service.dart';

AuthService getInjectedAuthService() => GetIt.I<AuthService>();

mixin AuthConsumer {
  AuthService get auth => getInjectedAuthService();
}
