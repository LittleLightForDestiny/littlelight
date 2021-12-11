import 'dart:convert';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_manifest.dart';
import 'package:bungie_api/responses/destiny_manifest_response.dart';
import 'package:flutter/foundation.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/bungie_api/enums/definition_table_names.enum.dart';
import 'package:little_light/services/storage/export.dart';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

typedef void DownloadProgress(int downloaded, int total);

class ManifestService {
  sqflite.Database _db;
  DestinyManifest _manifestInfo;
  final BungieApiService _api = new BungieApiService();
  final Map<String, dynamic> _cached = Map();
  static final ManifestService _singleton = new ManifestService._internal();

  factory ManifestService() {
    return _singleton;
  }
  ManifestService._internal();

  Future<void> reset() async {
    _cached.clear();
    if (_db?.isOpen ?? false) {
      await _db.close();
      _db = null;
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  bool isLoaded<T>(int hash) {
    var type = DefinitionTableNames.fromClass[T];
    return _cached.keys.contains("${type}_$hash");
  }

  T getDefinitionFromCache<T>(int hash) {
    var type = DefinitionTableNames.fromClass[T];
    return _cached["${type}_$hash"];
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
    String language = StorageService.getLanguage();
    var working = await test();
    return !working ||
        currentVersion != manifestInfo.mobileWorldContentPaths[language];
  }

  Future<bool> download({DownloadProgress onProgress}) async {
    DestinyManifest info = await loadManifestInfo();
    String language = StorageService.getLanguage();
    String path = info.mobileWorldContentPaths[language];
    String url = BungieApiService.url(path);
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

    List<int> unzippedData = await compute(_extractFromZip, zipFile);
    StorageService storage = StorageService.language();
    await storage.saveDatabase(StorageKeys.manifestFile, unzippedData);

    await zipFile.delete();

    await _openDb();

    bool success = await test();
    if (!success) return false;

    await saveManifestVersion(path);
    _cached.clear();
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
    var def = await getDefinition<DestinyInventoryItemDefinition>(3628991658);
    return def?.displayProperties?.name != null;
  }

  Future<sqflite.Database> _openDb() async {
    if (_db?.isOpen == true) {
      return _db;
    }
    var storage = StorageService.language();
    var path = await storage.getPath(StorageKeys.manifestFile, dbPath: true);
    var dbFile = File(path);
    var dbExists = await dbFile.exists();
    if(!dbExists) return null;
    try {
      sqflite.Database database =
          await sqflite.openDatabase("$path", readOnly: true);
      _db = database;
    } catch (e) {
      print(e);
      return null;
    }

    return _db;
  }

  Future<String> getSavedVersion() async {
    StorageService _prefs = StorageService.language();
    String version = _prefs.getString(StorageKeys.manifestVersion);
    if (version == null) {
      return null;
    }
    return version;
  }

  Future<void> saveManifestVersion(String version) async {
    StorageService _prefs = StorageService.language();
    _prefs.setString(StorageKeys.manifestVersion, version);
  }

  Future<Map<int, T>> searchDefinitions<T>(List<String> parameters,
      {int limit = 50, dynamic identity(Map<String, dynamic> json)}) async {
    var type = DefinitionTableNames.fromClass[T];
    if (identity == null) {
      identity = DefinitionTableNames.identities[T];
    }
    Map<int, T> defs = new Map();
    sqflite.Database db = await _openDb();
    String where;
    if ((parameters?.length ?? 0) > 0) {
      where = parameters.map((p) {
        return "UPPER(json) LIKE \"%${p.toUpperCase()}%\"";
      }).join(" AND ");
    }
    List<Map<String, dynamic>> results = await db.query(type,
        columns: ['id', 'json'], where: where, limit: limit);
    try {
      results.forEach((res) {
        int id = res['id'];
        int hash = id < 0 ? id + 4294967296 : id;
        String resultString = res['json'];
        var def = identity(jsonDecode(resultString));
        _cached["${type}_$hash"] = def;
        defs[hash] = def;
      });
    } catch (e) {}
    return defs.cast<int, T>();
  }

  Future<Map<int, T>> getDefinitions<T>(Iterable<int> hashes,
      [dynamic identity(Map<String, dynamic> json)]) async {
    Set<int> hashesSet = hashes?.toSet();
    hashesSet?.retainWhere((h) => h != null);
    if (hashesSet == null) return null;
    var type = DefinitionTableNames.fromClass[T];
    if (identity == null) {
      identity = DefinitionTableNames.identities[T];
    }
    Map<int, T> defs = new Map();
    hashesSet.removeWhere((hash) {
      if (_cached.keys.contains("${type}_$hash")) {
        defs[hash] = _cached["${type}_$hash"];
        return true;
      }
      return false;
    });

    if (hashesSet.length == 0) {
      return defs;
    }
    List<int> searchHashes = hashesSet
        .map((hash) => hash > 2147483648 ? hash - 4294967296 : hash)
        .toList();
    String idList = "(" + List.filled(hashesSet.length, '?').join(',') + ")";

    sqflite.Database db = await _openDb();

    List<Map<String, dynamic>> results = await db.query(type,
        columns: ['id', 'json'],
        where: "id in $idList",
        whereArgs: searchHashes);
    try {
      for (var res in results) {
        int id = res['id'];
        int hash = id < 0 ? id + 4294967296 : id;
        String resultString = res['json'];
        var def = identity(jsonDecode(resultString));
        _cached["${type}_$hash"] = def;
        defs[hash] = def;
      }
    } catch (e) {}
    return defs.cast<int, T>();
  }

  Future<T> getDefinition<T>(int hash,
      [dynamic identity(Map<String, dynamic> json)]) async {
    if (hash == null) return null;
    String type = DefinitionTableNames.fromClass[T];

    try {
      var cached = _cached["${type}_$hash"];
      if (cached != null) {
        return cached;
      }
    } catch (e) {}

    if (identity == null) {
      identity = DefinitionTableNames.identities[T];
    }
    if (identity == null) {
      throw "missing identity for $T";
    }
    int searchHash = hash > 2147483648 ? hash - 4294967296 : hash;
    sqflite.Database db = await _openDb();
    try {
      List<Map<String, dynamic>> results = await db.query(type,
          columns: ['json'], where: "id=?", whereArgs: [searchHash]);
      if (results.length < 1) {
        return null;
      }
      String resultString = results.first['json'];
      var def = identity(jsonDecode(resultString));
      _cached["${type}_$hash"] = def;
      return def;
    } catch (e) {
      if (e is sqflite.DatabaseException && e.isDatabaseClosedError()) {
        _db = null;
        return getDefinition(hash, identity);
      }
    }
    return null;
  }
}
