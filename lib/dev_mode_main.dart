import 'dart:async';

import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/dev_mode/router/dev_mode_router.dart';
import 'package:little_light/services/setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupServices();

  runZoned<Future<void>>(() async {
    runApp(LittleLightDevModeApp());
  });
}

class LittleLightDevModeApp extends StatefulWidget {
  const LittleLightDevModeApp({Key? key}) : super(key: key);

  @override
  _LittleLightDevModeAppState createState() => _LittleLightDevModeAppState();
}

const router = DevModeRouter();

class _LittleLightDevModeAppState extends State<LittleLightDevModeApp> {
  bool ready = false;

  @override
  void initState() {
    super.initState();
    initDevMode();
  }

  void initDevMode() async {
    await Future.delayed(Duration(milliseconds: 1));
    await initServices(context);
    setState(() {
      ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) return Container();
    return MaterialApp(theme: LittleLightThemeData().materialTheme, onGenerateRoute: (route) => router.getPage(route));
  }
}
