import 'package:get_it/get_it.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'profile.service.dart';

ProfileService getInjectedProfileService() => GetIt.I<ProfileService>();

extension Service on ProfileConsumer {
  ProfileService get profile => getInjectedProfileService();
}

mixin ProfileConsumer {}
