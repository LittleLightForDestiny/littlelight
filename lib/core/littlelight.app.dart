import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:little_light/core/blocs/core_blocs_container.dart';
import 'package:little_light/core/navigator_key.dart';
import 'package:little_light/core/router/littlelight_router.dart';
import 'package:little_light/core/theme/littlelight.scroll_behavior.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/analytics/analytics.consumer.dart';
import 'package:little_light/services/analytics/analytics.service.dart';
import 'package:little_light/services/https_override/https_overrides.dart';
import 'package:little_light/services/deeplinks_handler/deeplinks_handler.dart';
import 'package:little_light/services/setup.dart';
import 'package:provider/provider.dart';

const _router = LittleLightRouter();

class LittleLightApp extends StatefulWidget {
  const LittleLightApp({Key? key}) : super(key: key);

  @override
  _LittleLightAppState createState() => _LittleLightAppState();
}

class _LittleLightAppState extends State<LittleLightApp> with AnalyticsConsumer {
  final deeplinks = DeeplinksHandler();
  bool servicesStarted = false;
  @override
  void initState() {
    super.initState();
    setupHttpsOverrides();
    LittleLightNavigatorKeyContainer.navigatorKey = GlobalKey<NavigatorState>();
    deeplinks.addListener(updateDeepLinks);
    updateSystemOverlay();
    startServices();
  }

  void startServices() async {
    await setupServices();
    servicesStarted = true;
    setState(() {});
  }

  void updateSystemOverlay() async {
    await Future.delayed(Duration(milliseconds: 10));
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    deeplinks.removeListener(updateDeepLinks);
    deeplinks.dispose();
    super.dispose();
  }

  void updateDeepLinks() {
    final context = LittleLightNavigatorKeyContainer.navigatorKey?.currentContext;
    if (context == null) return;
    final currentLink = deeplinks.currentLink?.toString();
    if (currentLink == null) return;
    final route = RouteSettings(name: currentLink);
    Navigator.of(context).pushAndRemoveUntil(_router.getPage(route), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (!servicesStarted) return Container();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Little Light',
      navigatorKey: LittleLightNavigatorKeyContainer.navigatorKey,
      navigatorObservers: analytics.observers,
      builder: (context, child) => ScrollConfiguration(
        behavior: LittleLightScrollBehaviour(),
        child: LittleLightTheme(
          MultiProvider(
            providers: [
              Provider<AnalyticsService>(create: (context) => analytics),
              CoreBlocsContainer(),
            ],
            child: child ?? Container(),
          ),
        ),
      ),
      onGenerateRoute: (route) {
        final currentLink = deeplinks.currentLink;
        if (currentLink != null) {
          final unilinksRoute = RouteSettings(name: currentLink.toString());
          return _router.getPage(unilinksRoute);
        }
        return _router.getPage(route);
      },
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('en'), // English
        Locale('fr'), // French
        Locale('es'), // Spanish
        Locale('de'), // German
        Locale('it'), // Italian
        Locale('ja'), // Japan
        Locale('pt', 'BR'), // Brazillian Portuguese
        Locale('es', 'MX'), // Mexican Spanish
        Locale('ru'), // Russian
        Locale('pl'), // Polish
        Locale('ko'), // Korean
        Locale('zh', 'CHT'), // Chinese
        Locale('zh', 'CHS'), // Chinese
      ],
    );
  }
}
