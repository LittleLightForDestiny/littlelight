import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:little_light/screens/initial.screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(new LittleLight());

class LittleLight extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    CacheManager.maxNrOfCacheObjects = 5000;
    CacheManager.inBetweenCleans = new Duration(days: 15);
    
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        backgroundColor: Colors.blueGrey.shade900,
        primarySwatch: Colors.indigo,
        primaryColor: Colors.indigo,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(),
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
