//@dart=2.12
import 'package:get_it/get_it.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/auth/auth.service.dart';

AuthService getInjectedAuthService() => GetIt.I<AuthService>();

mixin AuthConsumer {
  AuthService get auth => getInjectedAuthService();
}
