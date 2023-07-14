import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:little_light/core/navigator_key.dart';
import 'package:little_light/core/blocs/core_blocs_container.dart';
import 'package:little_light/core/router/littlelight_router.dart';
import 'package:little_light/core/theme/littlelight.scroll_behavior.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/analytics/analytics.consumer.dart';
import 'package:little_light/services/unilinks_handler/unilinks.consumer.dart';
import 'package:provider/provider.dart';

const _router = LittleLightRouter();

class LittleLightApp extends StatefulWidget {
  const LittleLightApp({Key? key}) : super(key: key);

  @override
  _LittleLightAppState createState() => _LittleLightAppState();
}

class _LittleLightAppState extends State<LittleLightApp> with AnalyticsConsumer, UnilinksConsumer {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black.withOpacity(0.002),
      ),
    );
    LittleLightNavigatorKeyContainer.navigatorKey = GlobalKey<NavigatorState>();
    unilinks?.addListener(updateUnilinks);
  }

  @override
  void dispose() {
    unilinks?.removeListener(updateUnilinks);
    super.dispose();
  }

  void updateUnilinks() {
    final context = LittleLightNavigatorKeyContainer.navigatorKey?.currentContext;
    if (context == null) return;
    final currentLink = unilinks?.currentLink;
    if (currentLink == null) return;
    final unilinksRoute = RouteSettings(name: currentLink);
    Navigator.of(context).pushAndRemoveUntil(_router.getPage(unilinksRoute), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: MaterialApp(
      restorationScopeId: 'little_light_root',
      debugShowCheckedModeBanner: false,
      title: 'Little Light',
      navigatorKey: LittleLightNavigatorKeyContainer.navigatorKey,
      navigatorObservers: analytics.observers,
      builder: (context, child) => ScrollConfiguration(
        behavior: LittleLightScrollBehaviour(),
        child: LittleLightTheme(
          MultiProvider(
            providers: [
              CoreBlocsContainer(),
            ],
            child: child ?? Container(),
          ),
        ),
      ),
      onGenerateRoute: (route) {
        final currentLink = unilinks?.currentLink;
        if (currentLink != null) {
          final unilinksRoute = RouteSettings(name: currentLink);
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
    ));
  }
}
