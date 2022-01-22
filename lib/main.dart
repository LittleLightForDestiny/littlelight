import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:little_light/core/littlelight.app.dart';
import 'package:little_light/exceptions/exception_handler.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final exceptionHandler = ExceptionHandler();
  runZonedGuarded<Future<void>>(() async {
    runApp(Phoenix(child: LittleLightApp()));
  }, (error, stackTrace) {
    exceptionHandler.handleException(error, stackTrace);
  });
}
