//@dart=2.12

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:little_light/core/navigator_key.dart';
import 'package:little_light/core/router/littlelight_router.dart';
import 'package:little_light/core/theme/littlelight.scroll_behavior.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/analytics/analytics.consumer.dart';
import 'package:little_light/services/setup.dart';

const _router = LittleLightRouter();

class LittleLightApp extends StatefulWidget {
  const LittleLightApp({Key? key}) : super(key: key);

  @override
  _LittleLightAppState createState() => _LittleLightAppState();
}

class _LittleLightAppState extends State<LittleLightApp> with AnalyticsConsumer {
  bool canInit = false;

  @override
  void initState() {
    super.initState();
    asyncInit();
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarBrightness: Brightness.dark));
    LittleLightNavigatorKeyContainer.navigatorKey = GlobalKey<NavigatorState>();
  }

  void asyncInit() async {
    await setupServices();
    // TODO: return here to test migrations;
    setState(() {
      canInit = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!canInit) return Container();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Little Light',
      navigatorKey: LittleLightNavigatorKeyContainer.navigatorKey,
      navigatorObservers: analytics.observers,
      builder: (context, child) => ScrollConfiguration(
        behavior: LittleLightScrollBehaviour(),
        child: LittleLightTheme(child ?? Container()),
      ),
      onGenerateRoute: (route) => _router.getPage(route),
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
