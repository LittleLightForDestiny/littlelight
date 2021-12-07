import 'package:get_it/get_it.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/storage/storage.service.dart';

import 'littlelight/littlelight_api.service.dart';
import 'littlelight/loadouts.service.dart';
import 'littlelight/objectives.service.dart';
import 'manifest/manifest.service.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart' as dotEnv;

setupServices() async {
  await GetIt.I.reset();
  await setupAuthService();
}

initServices() async {
  final auth = GetIt.instance.get<AuthService>();
  await StorageService.init();
  auth.reset();
  await dotEnv.load(fileName: 'assets/_env');
  await LittleLightApiService().reset();
  await LoadoutsService().reset();
  await ObjectivesService().reset();
  await ManifestService().reset();
}
