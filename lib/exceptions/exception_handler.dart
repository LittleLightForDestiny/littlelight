import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/navigator_key.dart';
import 'package:little_light/core/utils/logger/logger.wrapper.dart';
import 'package:little_light/models/bungie_api.exception.dart';
import 'package:little_light/services/analytics/analytics.consumer.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/widgets/dialogs/bungie_api_exception.dialog.dart';
import 'package:little_light/widgets/dialogs/report_error.dialog.dart';

class ExceptionHandler with AuthConsumer, AnalyticsConsumer {
  bool isDialogOpen = false;
  ExceptionHandler() {
    initCustomErrorMessage();
    FlutterError.onError = (FlutterErrorDetails details) {
      final stack = details.stack;
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(details.copyWith(
            stackFilter: (input) => input.where((s) => s.contains('package:little_light') || !s.contains('package:'))));
      } else if (stack != null) {
        Zone.current.handleUncaughtError(details.exception, stack);
      }
      analytics.registerFlutterError(details);
    };
  }

  initCustomErrorMessage() {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Builder(
              builder: (context) => Column(mainAxisSize: MainAxisSize.min, children: [
                    Text("Render Error".translate(context)),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(ReportErrorDialogRoute(context, error: details));
                        },
                        child: Text("Report".translate(context)))
                  ])));
    };
  }

  Future<void> handleException(dynamic error, StackTrace? stackTrace) async {
    logger.error(error, error: error, stack: stackTrace);

    if (error is BungieApiException) {
      final context = LittleLightNavigatorKeyContainer.navigatorKey?.currentContext;
      if (context != null) {
        Navigator.of(context).push(BungieApiExceptionDialogRoute(context, error: error));
      }
    }
    if (error is FlutterErrorDetails) {
      analytics.registerFlutterError(error);
      return;
    }

    analytics.registerNonFatal(error, stackTrace);
  }
}
