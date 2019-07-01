import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest_source.dart';
import 'package:little_light/services/storage/storage.service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';


class SQLiteManifest extends ManifestSource {
  Database _db;

  @override
  Future<bool> download(String sourcePath,
      {DownloadProgress onProgress}) async {
    String url = BungieApiService.url(sourcePath);
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
    return success;
  }

  @override
  Future<dynamic> getDefinition(int hash, String type) async {
    int searchHash = hash > 2147483648 ? hash - 4294967296 : hash;
    try {
      Database db = await _openDb();
      List<Map<String, dynamic>> results = await db?.query(type,
          columns: ['json'], where: "id=?", whereArgs: [searchHash]);
      if ((results?.length ?? 0) < 1) {
        return null;
      }
      String resultString = results.first['json'];
      return jsonDecode(resultString);
    } on Exception catch (e) {
      if (e is DatabaseException && e.isDatabaseClosedError()) {
        _db = null;
        return getDefinition(hash, type);
      }
    }
    return null;
  }

  @override
  Future<Map<int, dynamic>> getDefinitions(
      Set<int> hashesSet, String type) async {
    List<int> searchHashes = hashesSet
        .map((hash) => hash > 2147483648 ? hash - 4294967296 : hash)
        .toList();
    String idList = "(" + List.filled(hashesSet.length, '?').join(',') + ")";
    Database db = await _openDb();
    Map<int, dynamic> defs = new Map();
    List<Map<String, dynamic>> results = await db.query(type,
        columns: ['id', 'json'],
        where: "id in $idList",
        whereArgs: searchHashes);
    try {
      results.forEach((res) {
        int id = res['id'];
        int hash = id < 0 ? id + 4294967296 : id;
        String resultString = res['json'];
        var def = jsonDecode(resultString);
        defs[hash] = def;
      });
    } on DatabaseException catch (e) {
      if (e.isDatabaseClosedError()) {
        _db = null;
        return getDefinitions(hashesSet, type);
      }
    }
    return defs.cast<int, dynamic>();
  }

  @override
  Future<void> reset() async {
    if (_db?.isOpen ?? false) {
      await _db.close();
      _db = null;
    }
  }

  @override
  Future<bool> test() async {
    var def = await getDefinition(3628991658, 'DestinyInventoryItemDefinition');
    try{
      return def['displayProperties']['name'] != null;
    }on Exception catch(e){
      print(e);
    }
    return false;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  List<int> _extractFromZip(dynamic zipFile) {
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

  Future<Database> _openDb() async {
    if (_db?.isOpen == true) {
      return _db;
    }
    var storage = StorageService.language();
    var path = await storage.getPath(StorageKeys.manifestFile, dbPath: true);
    try {
      Database database = await openDatabase("$path", readOnly: true);
      _db = database;
    } on DatabaseException catch (e) {
      print(e);
    }
    return _db;
  }
}
