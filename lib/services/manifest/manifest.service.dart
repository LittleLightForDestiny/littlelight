import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:bungie_api/destiny2.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:little_light/exceptions/parse.exception.dart';
import 'package:little_light/services/analytics/analytics.consumer.dart';
import 'package:little_light/services/bungie_api/bungie_api.consumer.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/bungie_api/enums/definition_table_names.enum.dart';
import 'package:little_light/core/providers/language/language.consumer.dart';
import 'package:little_light/services/manifest/manifest_download_progress.dart';
import 'package:little_light/services/storage/export.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:uuid/uuid.dart';

setupManifest() {
  GetIt.I.registerSingleton<ManifestService>(ManifestService._internal());
}

class ManifestService with StorageConsumer, BungieApiConsumer, AnalyticsConsumer {
  sqflite.Database? _db;
  DestinyManifest? _manifestInfo;
  final Map<String, dynamic> _cached = Map();

  ManifestService._internal();

  Future<void> setup() async {
    _cached.clear();
    if (_db?.isOpen ?? false) {
      await _db?.close();
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

  T? getDefinitionFromCache<T>(int hash) {
    var type = DefinitionTableNames.fromClass[T];
    return _cached["${type}_$hash"];
  }

  Future<DestinyManifest> _getManifestInfo() async {
    if (_manifestInfo != null) {
      return _manifestInfo!;
    }
    DestinyManifestResponse response = await bungieAPI.getManifest();
    _manifestInfo = response.response;
    if (_manifestInfo == null) {
      throw ("Can't load manifest info");
    }
    return _manifestInfo!;
  }

  Future<List<String>> getAvailableLanguages() async {
    DestinyManifest manifestInfo = await _getManifestInfo();
    List<String>? availableLanguages = manifestInfo.mobileWorldContentPaths?.keys.toList();
    if (availableLanguages == null) {
      throw ("Can't load available languages");
    }
    return availableLanguages;
  }

  Future<bool> needsUpdate() async {
    DestinyManifest manifestInfo = await _getManifestInfo();
    String? currentVersion = await getSavedVersion();
    String language = getInjectedLanguageService().currentLanguage;
    var working = await test();
    return !working || currentVersion != manifestInfo.mobileWorldContentPaths?[language];
  }

  Future<void> _downloadManifest(StreamController<DownloadProgress> _controller, {bool skipCache = false}) async {
    try {
      _db?.close();
    } catch (e, stackTrace) {
      analytics.registerNonFatal(e, stackTrace);
    }
    try {
      DestinyManifest info = await _getManifestInfo();
      String language = getInjectedLanguageService().currentLanguage;
      String? manifestFileURL = info.mobileWorldContentPaths?[language];
      String? url = BungieApiService.url(manifestFileURL);
      String localPath = await _localPath;
      HttpClient httpClient = HttpClient();
      if (url == null) {
        throw ("No manifest url found");
      }
      Uri uri = Uri.parse(url);
      if (skipCache) {
        final uuid = Uuid().v4();
        uri = Uri.parse("$uri?cache_killer=$uuid");
      }
      HttpClientRequest req = await httpClient.getUrl(uri);
      HttpClientResponse res = await req.close();
      File zipFile = File("$localPath/manifest_temp.zip");
      IOSink sink = zipFile.openWrite();
      int totalSize = res.contentLength;
      int loaded = 0;
      Stream<List<int>> stream = res.asBroadcastStream();
      await for (var data in stream) {
        loaded += data.length;
        sink.add(data);
        _controller.add(DownloadProgress(
          downloadedBytes: loaded,
          totalBytes: totalSize,
        ));
      }
      await sink.flush();
      await sink.close();
      _controller.add(DownloadProgress(
        downloadedBytes: loaded,
        totalBytes: totalSize,
        downloaded: true,
      ));
      List<int> unzippedData = await compute(_extractFromZip, zipFile);
      await currentLanguageStorage.saveManifestDatabase(unzippedData);
      await zipFile.delete();

      await _openDb();

      bool success = await test();
      if (!success) {
        throw ParseException(url, "Manifest Database file isn't valid");
      }
      currentLanguageStorage.manifestVersion = manifestFileURL;
      _cached.clear();
      _controller
          .add(DownloadProgress(downloadedBytes: loaded, totalBytes: totalSize, downloaded: true, unzipped: true));
    } catch (e, stackTrace) {
      analytics.registerNonFatal(e, stackTrace);
      _controller.add(DownloadError());
      _controller.close();
    }
  }

  Stream<DownloadProgress> download([skipCache = false]) {
    final _controller = StreamController<DownloadProgress>();
    _downloadManifest(_controller, skipCache: skipCache).then((_) {
      _controller.close();
    });

    return _controller.stream;
  }

  static List<int> _extractFromZip(dynamic zipFile) {
    List<int>? unzippedData;
    List<int> bytes = zipFile.readAsBytesSync();
    ZipDecoder decoder = ZipDecoder();
    Archive archive = decoder.decodeBytes(bytes);
    for (ArchiveFile file in archive) {
      if (file.isFile) {
        unzippedData = file.content;
      }
    }
    if (unzippedData == null) {
      throw ("Can't find zipped manifest");
    }
    return unzippedData;
  }

  Future<bool> test() async {
    final def = await getDefinition<DestinyInventoryItemDefinition>(3628991658);
    final success = def?.displayProperties?.name != null;
    if (success) return success;
    try {
      _db?.close();
    } catch (e, stackTrace) {
      analytics.registerNonFatal(e, stackTrace);
    }
    return success;
  }

  Future<sqflite.Database?> _openDb() async {
    if (_db?.isOpen == true) {
      return _db;
    }

    final dbFile = await currentLanguageStorage.getManifestDatabaseFile();
    if (dbFile == null) return null;
    try {
      sqflite.Database database = await sqflite.openDatabase(dbFile.path, readOnly: true);
      _db = database;
    } catch (e) {
      print(e);
      return null;
    }

    return _db;
  }

  Future<String?> getSavedVersion() async {
    String? version = currentLanguageStorage.manifestVersion;
    if (version == null) {
      return null;
    }
    return version;
  }

  Future<Map<int, T>> searchDefinitions<T>(List<String>? parameters,
      {int limit = 50, DefinitionTableIdentityFunction? identity}) async {
    final tableName = DefinitionTableNames.fromClass[T];
    if (identity == null) {
      identity = DefinitionTableNames.identities[T];
    }
    Map<int, T> defs = Map();
    sqflite.Database? db = await _openDb();
    String? where;
    if (parameters != null && parameters.length > 0) {
      where = parameters.map((p) {
        return "UPPER(json) LIKE \"%${p.toUpperCase()}%\"";
      }).join(" AND ");
    }
    if (tableName == null) {
      throw ("no db table found for class $T");
    }
    if (identity == null) {
      throw ("no identity found for class $T");
    }
    try {
      List<Map<String, dynamic>>? results =
          await db?.query(tableName, columns: ['id', 'json'], where: where, limit: limit);
      results?.forEach((res) {
        int id = res['id'];
        int hash = id < 0 ? id + 4294967296 : id;
        String resultString = res['json'];
        final def = identity?.call(jsonDecode(resultString));
        _cached["${tableName}_$hash"] = def;
        defs[hash] = def;
      });
    } catch (e) {}
    return defs.cast<int, T>();
  }

  Future<Map<int, T>> getDefinitions<T>(Iterable<int?> hashes, [DefinitionTableIdentityFunction? identity]) async {
    Set<int> hashesSet = hashes.whereType<int>().toSet();
    if (hashesSet.length == 0) return Map<int, T>();
    var tableName = DefinitionTableNames.fromClass[T];
    if (identity == null) {
      identity = DefinitionTableNames.identities[T];
    }
    Map<int, T> defs = Map();
    hashesSet.removeWhere((hash) {
      if (_cached.keys.contains("${tableName}_$hash")) {
        defs[hash] = _cached["${tableName}_$hash"];
        return true;
      }
      return false;
    });

    if (hashesSet.length == 0) {
      return defs;
    }
    List<int> searchHashes = hashesSet.map((hash) => hash > 2147483648 ? hash - 4294967296 : hash).toList();
    String idList = "(" + List.filled(hashesSet.length, '?').join(',') + ")";

    sqflite.Database? db = await _openDb();
    if (tableName == null) {
      throw ("no db table found for class $T");
    }
    if (identity == null) {
      throw ("no identity found for class $T");
    }
    try {
      List<Map<String, dynamic>>? results =
          await db?.query(tableName, columns: ['id', 'json'], where: "id in $idList", whereArgs: searchHashes);
      if (results == null) return Map<int, T>();
      for (var res in results) {
        int id = res['id'];
        int hash = id < 0 ? id + 4294967296 : id;
        String? resultString = res['json'];
        if (resultString != null) {
          final def = identity(jsonDecode(resultString));
          _cached["${tableName}_$hash"] = def;
          defs[hash] = def;
        }
      }
    } catch (e) {}
    return defs.cast<int, T>();
  }

  void closeDB() {
    try {
      _db?.close();
    } catch (e, stackTrace) {
      analytics.registerNonFatal(e, stackTrace);
    }
  }

  Future<T?> getDefinition<T>(int? hash, [DefinitionTableIdentityFunction? identity]) async {
    if (hash == null) return null;
    String? tableName = DefinitionTableNames.fromClass[T];

    try {
      var cached = _cached["${tableName}_$hash"];
      if (cached != null) {
        return cached;
      }
    } catch (e) {}

    if (identity == null) {
      identity = DefinitionTableNames.identities[T];
    }
    if (tableName == null) {
      throw ("no db table found for class $T");
    }
    if (identity == null) {
      throw ("no identity found for class $T");
    }
    int searchHash = hash > 2147483648 ? hash - 4294967296 : hash;
    sqflite.Database? db = await _openDb();
    try {
      List<Map<String, dynamic>>? results =
          await db?.query(tableName, columns: ['json'], where: "id=?", whereArgs: [searchHash]);
      if (results == null || results.length < 1) {
        return null;
      }
      String resultString = results.first['json'];
      var def = identity(jsonDecode(resultString));
      _cached["${tableName}_$hash"] = def;
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
