import 'dart:async';
import 'dart:io';
import 'package:bungie_api/helpers/oauth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:sentry/sentry.dart';
import 'package:package_info/package_info.dart';

class ExceptionHandler {
  static BuildContext context;
  Function onRestart;
  static SentryClient _sentry;
  ExceptionHandler({this.onRestart}) {
    initSentry();
    initCustomErrorMessage();
    FlutterError.onError = (FlutterErrorDetails details) {
      if (isInDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      } else {
        Zone.current.handleUncaughtError(details.exception, details.stack);
      }
    };
  }

  initSentry() async {
    if (_sentry != null) return;
    if (!DotEnv().env.containsKey('sentry_dsn')) return;

    var info = await PackageInfo.fromPlatform();
    _sentry = SentryClient(
        environmentAttributes: Event(
          environment: isInDebugMode ? 'debug' : 'production',
          release: info.version,
        ),
        dsn: DotEnv().env['sentry_dsn']);
  }

  initCustomErrorMessage() {
    if (!isInDebugMode) {
      ErrorWidget.builder = (FlutterErrorDetails details) {
        return Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.center,
            child: TranslatedTextWidget("Couldn&#39;t render this widget properly. Please report this to @LittleLightD2 on Twitter or via GitHub issues"));
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

    if (error is BungieApiException) {
      bool shouldShowLoginButton = [1601, 99].contains(error.errorCode);
      BungieApiException e = error;
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
                            onPressed: () async {})
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

  static reportToSentry(dynamic exception, [dynamic stacktrace]) {
    if (isInDebugMode) {
      print(exception);
      return;
    }
    _sentry.captureException(
      exception: exception,
      stackTrace: stacktrace,
    );
  }

  static setSentryUserInfo(
      String membershipId, String displayName, int platformId) {
    if (_sentry == null) return;
    _sentry.userContext = User(
        id: membershipId,
        username: displayName,
        extras: {'platform': platformId});
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
