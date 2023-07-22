import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:little_light/exceptions/exception_handler.dart';
import 'package:little_light/services/setup.dart';
import 'package:uni_links_desktop/uni_links_desktop.dart';

import 'core/littlelight.app.dart';

void main() async {
  if (Platform.isWindows) {
    registerProtocol('luzinha');
  }
  WidgetsFlutterBinding.ensureInitialized();
  await setupCoreServices();
  ExceptionHandler();
  runApp(Phoenix(child: const LittleLightApp()));
}
