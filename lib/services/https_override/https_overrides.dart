import 'dart:io';
import 'package:lehttp_overrides/lehttp_overrides.dart';

setupHttpsOverrides() {
  if (Platform.isAndroid) {
    HttpOverrides.global = LEHttpOverrides();
  }
}
