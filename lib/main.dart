import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:little_light/exceptions/exception_handler.dart';
import 'package:little_light/services/setup.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/littlelight.app.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (runWebViewTitleBarWidget(args)) {
    return;
  }
  if (Platform.isWindows) {
    sqfliteFfiInit();
  }
  await setupCoreServices();
  ExceptionHandler();
  runApp(Phoenix(child: const LittleLightApp()));
}
