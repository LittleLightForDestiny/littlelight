//@dart=2.9

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'package:little_light/exceptions/exception_handler.dart';
import 'package:little_light/services/setup.dart';

import 'core/littlelight.app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final exceptionHandler = ExceptionHandler();
  await setupCoreServices();
  runZonedGuarded<Future<void>>(() async {
    runApp(Phoenix(child: LittleLightApp()));
  }, (error, stackTrace) {
    exceptionHandler.handleException(error, stackTrace);
  });
}
