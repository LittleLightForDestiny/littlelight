import 'dart:convert';

import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_manifest.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:bungie_api/models/destiny_class_definition.dart';
import 'package:bungie_api/models/destiny_race_definition.dart';
import 'package:bungie_api/models/destiny_talent_grid_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/responses/destiny_manifest_response.dart';
import 'package:flutter/foundation.dart';
import 'package:little_light/services/bungie-api/bungie-api.service.dart';
import 'package:little_light/services/bungie-api/enums/definition-table-names.enum.dart';
import 'package:little_light/services/translate/app-translations.service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

typedef Type DownloadProgress(int downloaded, int total);

class ManifestService {
  static const String _manifestVersionKey = "manifestVersion";
  static const String _manifestFilename = "manifest.db";
  sqflite.Database _db;
  DestinyManifest _manifestInfo;
  final BungieApiService _api = new BungieApiService();
  static final ManifestService _singleton = new ManifestService._internal();

  Map<String, dynamic> _cached = Map();

  factory ManifestService() {
    return _singleton;
  }
  ManifestService._internal();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<DestinyManifest> loadManifestInfo() async {
    if (_manifestInfo != null) {
      return _manifestInfo;
    }
    DestinyManifestResponse response = await _api.getManifest();
    _manifestInfo = response.response;
    return _manifestInfo;
  }

  Future<List<String>> getAvailableLanguages() async {
    DestinyManifest manifestInfo = await loadManifestInfo();
    List<String> availableLanguages =
        manifestInfo.mobileWorldContentPaths.keys.toList();
    return availableLanguages;
  }

  Future<bool> needsUpdate() async {
    DestinyManifest manifestInfo = await loadManifestInfo();
    String currentVersion = await getSavedVersion();
    return currentVersion !=
        manifestInfo.mobileWorldContentPaths[AppTranslations.currentLanguage];
  }

  Future<bool> download({DownloadProgress onProgress}) async {
    DestinyManifest info = await loadManifestInfo();
    String path = info.mobileWorldContentPaths[AppTranslations.currentLanguage];
    String url = "${BungieApiService.baseUrl}$path";
    String localPath = await _localPath;
    HttpClient httpClient = new HttpClient();
    HttpClientRequest req = await httpClient.getUrl(Uri.parse(url));
    HttpClientResponse res = await req.close();
    File zipFile = new File("$localPath/manifest_temp.zip");
    IOSink sink = zipFile.openWrite();
    int totalSize = res.contentLength;
    int loaded = 0;
    Stream<List<int>> stream = res.asBroadcastStream();
    await for (var data in stream) {
      loaded += data.length;
      sink.add(data);
      if (onProgress != null) {
        onProgress(loaded, totalSize);
      }
    }
    await sink.flush();
    await sink.close();

    File manifestFile = await File("$localPath/$_manifestFilename").create();
    List<int> unzippedData = await compute(_extractFromZip, zipFile);
    manifestFile = await manifestFile.writeAsBytes(unzippedData);

    await zipFile.delete();

    await _openDb();

    bool success = await test();
    if (!success) return false;

    await saveManifestVersion(path);
    return success;
  }

  static List<int> _extractFromZip(dynamic zipFile) {
    List<int> unzippedData;
    List<int> bytes = zipFile.readAsBytesSync();
    ZipDecoder decoder = new ZipDecoder();
    Archive archive = decoder.decodeBytes(bytes);
    for (ArchiveFile file in archive) {
      if (file.isFile) {
        unzippedData = file.content;
      }
    }
    return unzippedData;
  }

  Future<bool> test() async {
    sqflite.Database db = await _openDb();
    List<Map<String, dynamic>> results =
        await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    return results.length > 0;
  }

  Future<sqflite.Database> _openDb() async {
    if (_db != null) {
      return _db;
    }
    String localPath = await _localPath;
    sqflite.Database database =
        await sqflite.openDatabase("$localPath/$_manifestFilename");
    _db = database;
    return _db;
  }

  Future<String> getSavedVersion() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String version = _prefs.getString(_manifestVersionKey);
    if (version == null) {
      return null;
    }
    return version;
  }

  Future<void> saveManifestVersion(String version) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString(_manifestVersionKey, version);
  }

  Future<DestinyInventoryItemDefinition> getItemDefinition(int hash) async {
    var res = await getDefinition(
        DefinitionTableNames.destinyInventoryItemDefinition,
        hash,
        DestinyInventoryItemDefinition.fromMap);
    return res;
  }

  Future<DestinyStatDefinition> getStatDefinition(int hash) async {
    var res = await getDefinition(DefinitionTableNames.destinyStatDefinition,
        hash, DestinyStatDefinition.fromMap);
    return res;
  }

  Future<DestinyTalentGridDefinition> getTalentGridDefinition(int hash) async {
    var res = await getDefinition(
        DefinitionTableNames.destinyTalentGridDefinition,
        hash,
        DestinyTalentGridDefinition.fromMap);
    return res;
  }

  Future<DestinyInventoryBucketDefinition> getBucketDefinition(int hash) async {
    var res = await getDefinition(
        DefinitionTableNames.destinyInventoryBucketDefinition,
        hash,
        DestinyInventoryBucketDefinition.fromMap);
    return res;
  }

  Future<DestinyClassDefinition> getClassDefinition(int hash) async {
    var res = await getDefinition(DefinitionTableNames.destinyClassDefinition,
        hash, DestinyClassDefinition.fromMap);
    return res;
  }

  Future<DestinyRaceDefinition> getRaceDefinition(int hash) async {
    var res = await getDefinition(DefinitionTableNames.destinyRaceDefinition,
        hash, DestinyRaceDefinition.fromMap);
    return res;
  }

  dynamic getDefinition(String type, int hash,
      dynamic identity(Map<String, dynamic> json)) async {
    try {
      var cached = _cached["${type}_$hash"];
      if (cached != null) {
        return cached;
      }
    } catch (e) {}

    sqflite.Database db = await _openDb();
    List<Map<String, dynamic>> results = await db.rawQuery(
        "SELECT json FROM $type WHERE id='$hash' OR (id + 4294967296)=$hash");
    try {
      String resultString = results.first['json'];
      var def = identity(jsonDecode(resultString));
      _cached["${type}_$hash"] = def;
      return def;
    } catch (e) {}
    return null;
  }
}
