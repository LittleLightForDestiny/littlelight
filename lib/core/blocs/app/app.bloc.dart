import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class AppBloc {
  final BuildContext context;
  AppBloc(this.context);

  restart() {
    Phoenix.rebirth(context);
  }
}
