//@dart=2.12

import 'dart:io';

import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:get_it/get_it.dart';
import 'package:little_light/services/storage/storage.keys.dart';
import 'package:sqflite/sqflite.dart';

import 'language_storage.keys.dart';
import 'storage.base.dart';

setupLanguageStorageService() async {
  GetIt.I.registerFactoryParam<LanguageStorage, String, void>(
      (accountID, _) => LanguageStorage._internal(accountID));
}

class LanguageStorage extends StorageBase<LanguageStorageKeys> {
  LanguageStorage._internal(languageCode):super("languages/$languageCode");

  @override
  String getKeyPath(LanguageStorageKeys? key) {
    return key?.path ?? "";
  }

  Future<String> _getManifestDBPath() async {
    String dbRoot = await getDatabasesPath();
    return "$dbRoot/$basePath/manifest.db";
  }

  set manifestVersion(String? manifestVersion)=> setString(LanguageStorageKeys.manifestVersion, manifestVersion);
  String? get manifestVersion => getString(LanguageStorageKeys.manifestVersion);

  Future<void> saveManifestDatabase(List<int> data) async {
    final manifestFile = File(await _getManifestDBPath());
    final dir = manifestFile.parent;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    await manifestFile.writeAsBytes(data);
  }

  Future<File?> getManifestDatabaseFile() async {
    final manifestFile = File(await _getManifestDBPath());
    if(await manifestFile.exists()){
      return manifestFile;
    }
    return null;
  }
}
