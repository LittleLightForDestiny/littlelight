//@dart=2.12

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';

setupAppConfig() {
  GetIt.I.registerSingleton<AppConfig>(AppConfig._internal());
}

class AppConfig {
  final _dotEnv = DotEnv();

  Future<void> setup() async {
    await _dotEnv.load(fileName: 'assets/_env');
  }

  AppConfig._internal();
  String get clientSecret {
    final value = _dotEnv.maybeGet('client_secret');
    if (value == null) {
      throw Exception("Coudn't find client_secret on env");
    }
    return value;
  }

  String get apiKey {
    final value = _dotEnv.maybeGet('api_key');
    if (value == null) {
      throw Exception("Coudn't find api_key on env");
    }
    return value;
  }

  String get clientId {
    final value = _dotEnv.maybeGet('client_id');
    if (value == null) {
      throw Exception("Coudn't find client_id on env");
    }
    return value;
  }

  String get littleLightApiRoot {
    final value = _dotEnv.maybeGet("littlelight_api_root");
    if (value == null) {
      throw Exception("Coudn't find littlelight_api_root on env");
    }
    return value;
  }
}
