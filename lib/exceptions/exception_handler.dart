import 'dart:async';
import 'dart:io';
import 'package:bungie_api/helpers/oauth.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:sentry/sentry.dart';

class ExceptionHandler {
  static BuildContext context;
  Function onRestart;
  static final SentryClient _sentry = SentryClient(
      dsn: "https://1270a211df3a46a49cd4b34f79979e90@sentry.io/1370036");
  ExceptionHandler({this.onRestart}) {
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
    if (error is OAuthException) {
      print("Oauth Exception caught");
    }

    if (error is BungieApiException) {
      bool shouldShowLoginButton = [1601, 99].contains(error.errorCode);
      BungieApiException e = error;
      showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              title: TranslatedTextWidget(e.errorStatus),
              children: [
                Container(
                    padding: EdgeInsets.all(16),
                    child:TranslatedTextWidget(e.message, textAlign: TextAlign.center,)
                ),
                Container(
                    padding: EdgeInsets.symmetric(horizontal:16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        ErrorDialogButton(
                            text: "Try again",
                            onPressed: () {
                              onRestart();
                            }),
                        shouldShowLoginButton
                            ? ErrorDialogButton(
                                text: "Login with another account",
                                onPressed: () async {
                                  AuthService auth = AuthService();
                                  await auth.clearData();
                                  onRestart();
                                })
                            : Container(height:0),
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

  static reportToSentry(dynamic exception, [dynamic stacktrace]){
    _sentry.captureException(
        exception: exception,
        stackTrace: stacktrace,
      );
  }
}

class ErrorDialogButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  const ErrorDialogButton({Key key, this.onPressed, this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
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
