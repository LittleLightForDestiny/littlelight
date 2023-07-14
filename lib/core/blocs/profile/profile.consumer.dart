import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profile.bloc.dart';

extension Service on ProfileConsumer {
  // ProfileBloc get profile => getInjectedProfileService();
  ProfileBloc profileBloc(BuildContext context) => context.read<ProfileBloc>();
}

mixin ProfileConsumer {}
