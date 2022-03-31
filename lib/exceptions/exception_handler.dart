//@dart=2.12

import 'dart:async';

import 'package:bungie_api/enums/bungie_membership_type.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/navigator_key.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/models/bungie_api.exception.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/dialogs/bungie_api_exception.dialog.dart';
import 'package:little_light/widgets/dialogs/report_error.dialog.dart';

class ExceptionHandler with AuthConsumer {
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

      FirebaseCrashlytics.instance.recordFlutterError(details);
    };
  }

  initCustomErrorMessage() {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Container(
          padding: EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TranslatedTextWidget("Render Error"),
            ElevatedButton(
                onPressed: () {
                  final context = LittleLightNavigatorKeyContainer.navigatorKey?.currentContext;
                  if (context == null) return;
                  Navigator.of(context).push(ReportErrorDialogRoute(context, error: details));
                },
                child: TranslatedTextWidget("Report"))
          ]));
    };
  }

  Future<void> handleException(dynamic error, StackTrace? stackTrace) async {
    final relevantStackTrace = stackTrace?.toString().split('\n').where((s) => s.contains('package:little_light'));
    print(error);
    if (relevantStackTrace != null) {
      print(relevantStackTrace.join('\n'));
    }

    if (error is BungieApiException) {
      final context = LittleLightNavigatorKeyContainer.navigatorKey?.currentContext;
      if (context != null) {
        Navigator.of(context).push(BungieApiExceptionDialogRoute(context, error: error));
      }
    }
    if (error is FlutterErrorDetails) {
      FirebaseCrashlytics.instance.recordFlutterError(error);
      return;
    }

    FirebaseCrashlytics.instance.recordError(error, stackTrace, printDetails: false);
  }

  static setReportingUserInfo(String membershipId, String displayName, BungieMembershipType platformId) {
    FirebaseCrashlytics.instance.setUserIdentifier(membershipId);
    FirebaseCrashlytics.instance.setCustomKey('User Name', displayName);
    FirebaseCrashlytics.instance.setCustomKey("platform", platformId.value ?? "not informed");
  }
}
