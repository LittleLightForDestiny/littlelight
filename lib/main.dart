import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:little_light/exceptions/exception_handler.dart';
import 'package:little_light/screens/initial.screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:flutter/foundation.dart';

int restartCounter = 0;
void main() async {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  WidgetsFlutterBinding.ensureInitialized();
  await DotEnv().load('assets/_env');
  print(DotEnv().env);
  ExceptionHandler handler = ExceptionHandler(onRestart: () {
    restartCounter++;
    main();
  });

  runZoned<Future<void>>(() async {
    runApp(new LittleLight(key: Key("little_light_$restartCounter")));
  }, onError: (error, stackTrace) {
    handler.handleException(error, stackTrace);
  });
}

class LittleLight extends StatelessWidget {
  final Key key;
  LittleLight({this.key});

  @override
  Widget build(BuildContext context) {
    QueuedNetworkImage.maxNrOfCacheObjects = 5000;
    QueuedNetworkImage.inBetweenCleans = new Duration(days: 30);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      key: key,
      title: 'Little Light',
      theme: new ThemeData(
          fontFamily: "NeueHaasDisplay",
          disabledColor: Colors.lightBlue.shade900,
          platform: TargetPlatform.android,
          backgroundColor: Colors.blueGrey.shade900,
          primarySwatch: Colors.lightBlue,
          primaryColor: Colors.blueGrey,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.dark(),
          accentColor: Colors.lightBlueAccent.shade100,
          textSelectionColor: Colors.blueGrey.shade400,
          textSelectionHandleColor: Colors.lightBlueAccent.shade200,
          toggleableActiveColor: Colors.lightBlueAccent.shade200,
          textTheme: TextTheme(
              bodyText2: TextStyle(
                color:Colors.grey.shade300,
                fontWeight: FontWeight.w500
              ),
              button: TextStyle(
              fontWeight: FontWeight.bold,
          )),
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          }),
          sliderTheme: SliderThemeData.fromPrimaryColors(
              primaryColor: Colors.lightBlue,
              primaryColorDark: Colors.lightBlue,
              primaryColorLight: Colors.lightBlue,
              valueIndicatorTextStyle: TextStyle())),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: LittleLightScrollBehaviour(),
          child: child,
        );
      },
      home: new InitialScreen(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'), // English
        const Locale('fr'), // French
        const Locale('es'), // Spanish
        const Locale('de'), // German
        const Locale('it'), // Italian
        const Locale('ja'), // Japan
        const Locale('pt', 'BR'), // Brazillian Portuguese
        const Locale('es', 'MX'), // Mexican Spanish
        const Locale('ru'), // Russian
        const Locale('pl'), // Polish
        const Locale('ko'), // Korean
        const Locale('zh', 'CHT'), // Chinese
        const Locale('zh', 'CHS'), // Chinese
      ],
    );
  }
}

class LittleLightScrollBehaviour extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    if (Platform.isIOS) {
      return child;
    }
    return GlowingOverscrollIndicator(
      child: child,
      axisDirection: axisDirection,
      color: Theme.of(context).accentColor,
    );
  }
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    if (Platform.isIOS) {
      return const BouncingScrollPhysics();
    }
    return super.getScrollPhysics(context);
  }
}
