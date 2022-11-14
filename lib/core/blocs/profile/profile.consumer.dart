import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'profile.bloc.dart';

ProfileBloc getInjectedProfileService() => GetIt.I<ProfileBloc>();

extension Service on ProfileConsumer {
  ProfileBloc get profile => getInjectedProfileService();
  ProfileBloc profileBloc(BuildContext context) => context.read<ProfileBloc>();
}

mixin ProfileConsumer {}
