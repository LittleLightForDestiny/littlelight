import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:little_light/core/littlelight.app.dart';
import 'package:little_light/exceptions/exception_handler.dart';
import 'package:little_light/services/setup.dart';

final exceptionHandler = ExceptionHandler(onRestart: (context) {
  Phoenix.rebirth(context);
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServices();

  runZonedGuarded<Future<void>>(() async {
    runApp(Phoenix(child: LittleLightApp()));
  }, (error, stackTrace) {
    exceptionHandler.handleException(error, stackTrace);
  });
}
