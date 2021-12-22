import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:little_light/dev_mode/router/dev_mode_router.dart';
import 'package:little_light/services/setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  await setupServices();
  await initServices();

  runZoned<Future<void>>(() async {
    runApp(LittleLightDevModeApp());
  });
}

class LittleLightDevModeApp extends StatefulWidget {
  const LittleLightDevModeApp({ Key key }) : super(key: key);

  @override
  _LittleLightDevModeAppState createState() => _LittleLightDevModeAppState();
}

const router = DevModeRouter();

class _LittleLightDevModeAppState extends State<LittleLightDevModeApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (route) => router.getPage(route)
    );
  }
}
