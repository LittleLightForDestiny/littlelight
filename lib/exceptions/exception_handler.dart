import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sentry/sentry.dart';

class ExceptionHandler {
  static final SentryClient _sentry = SentryClient(
      dsn: "https://1270a211df3a46a49cd4b34f79979e90@sentry.io/1370036");
  ExceptionHandler(){
    FlutterError.onError = (FlutterErrorDetails details) {
    if (isInDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };
  }

  bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  Future<void> handleException(dynamic error, dynamic stackTrace) async {
    print('Caught error: $error');
    if (isInDebugMode) {
      print(stackTrace);
      return;
    } else {
      _sentry.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    }
  }
}
