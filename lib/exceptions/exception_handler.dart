import 'dart:async';
import 'dart:io';

import 'package:bungie_api/enums/bungie_membership_type.dart';
import 'package:bungie_api/enums/platform_error_codes.dart';
import 'package:bungie_api/helpers/oauth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/storage/storage.service.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class ExceptionHandler {
  static BuildContext context;
  Function onRestart;
  ExceptionHandler({this.onRestart}) {
    initCustomErrorMessage();
    FlutterError.onError = (FlutterErrorDetails details) {
      if (isInDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      } else {
        Zone.current.handleUncaughtError(details.exception, details.stack);
      }

      FirebaseCrashlytics.instance.recordFlutterError(details);
    };
  }

  initCustomErrorMessage() {
    if (!isInDebugMode) {
      ErrorWidget.builder = (FlutterErrorDetails details) {
        return Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TranslatedTextWidget(
                  "Couldn&#39;t render this widget properly. Please report this to @LittleLightD2 on Twitter or via GitHub issues"),
              Text(details?.exceptionAsString() ?? ""),
            ]));
      };
    }
  }

  static bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  Future<void> handleException(dynamic error, dynamic stackTrace) async {
    if (error is OAuthException) {
      print("Oauth Exception caught");
    }

    print(error);
    if (error is Error) {
      var stack = error.stackTrace.toString().split('\n');
      stack.removeWhere((s) => !s.contains("package:little_light"));
      print(stack.join("\n"));
    }

    if (error is BungieApiException) {
      bool shouldShowLoginButton = [
            PlatformErrorCodes.DestinyAccountNotFound,
            PlatformErrorCodes.WebAuthRequired,
            PlatformErrorCodes.AuthorizationRecordExpired
          ].contains(error.errorCode) ||
          ["invalid_grant"].contains(error.errorStatus);
      BungieApiException e = error;
      print(e.errorStatus);
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => SimpleDialog(
          title: TranslatedTextWidget(e.errorStatus),
          children: [
            Container(
                padding: EdgeInsets.all(16),
                child: TranslatedTextWidget(
                  e.message,
                )),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ErrorDialogButton(
                        text: "Try Again",
                        onPressed: () {
                          onRestart();
                        }),
                    shouldShowLoginButton
                        ? ErrorDialogButton(
                            text: "Login with another account",
                            onPressed: () async {
                              await StorageService.account()
                                  .remove(StorageKeys.latestToken, true);
                              onRestart();
                            })
                        : Container(height: 0),
                    ErrorDialogButton(
                        text: "Exit",
                        onPressed: () {
                          exit(0);
                        })
                  ],
                ))
          ],
        ),
      );
    }
    if (error is FlutterErrorDetails) {
      FirebaseCrashlytics.instance.recordFlutterError(error);
      return;
    }

    if (error is Error) {
      FirebaseCrashlytics.instance
          .recordError(error, error.stackTrace, printDetails: false);
      return;
    }
  }

  static setReportingUserInfo(String membershipId, String displayName,
      BungieMembershipType platformId) {
    FirebaseCrashlytics.instance.setUserIdentifier(membershipId);
    FirebaseCrashlytics.instance.setCustomKey('User Name', displayName);
    FirebaseCrashlytics.instance.setCustomKey("platform", platformId.value);
  }
}

class ErrorDialogButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  const ErrorDialogButton({Key key, this.onPressed, this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Container(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: TranslatedTextWidget(
            text,
            textAlign: TextAlign.center,
          )),
      onPressed: onPressed,
    );
  }
}
