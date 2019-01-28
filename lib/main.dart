
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:little_light/exceptions/exception_handler.dart';
import 'package:little_light/screens/initial.screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async{
  await DotEnv().load('.env');
  ExceptionHandler handler = ExceptionHandler();

  runZoned<Future<void>>(() async {
    runApp(new LittleLight());
  }, onError: (error, stackTrace) {
    handler.handleException(error, stackTrace);
  });
}


class LittleLight extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    CacheManager.maxNrOfCacheObjects = 5000;
    CacheManager.inBetweenCleans = new Duration(days: 15);

    return new MaterialApp(
      title: 'Little Light',
      theme: new ThemeData(
        platform: TargetPlatform.android,
        backgroundColor: Colors.blueGrey.shade900,
        primarySwatch: Colors.lightBlue,
        primaryColor: Colors.blueGrey,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(),
        accentColor: Colors.lightBlueAccent.shade100,
        textSelectionColor: Colors.blueGrey.shade400,
        textSelectionHandleColor: Colors.lightBlueAccent.shade200,
      ),
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
