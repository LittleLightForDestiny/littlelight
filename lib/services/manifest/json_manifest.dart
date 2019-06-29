import 'dart:convert';
import 'dart:io';

import 'package:bungie_api/models/destiny_manifest.dart';
import 'package:flutter/foundation.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest_source.dart';
import 'package:little_light/services/storage/storage.service.dart';
import 'package:http/http.dart' as http;
import 'package:little_light/utils/map_lookup.dart';

class JSONManifest extends ManifestSource {
  dynamic _data;

  @override
  Future<bool> download(DestinyManifest manifestInfo, String language,
      {DownloadProgress onProgress}) async {
    String url =
        BungieApiService.url(manifestInfo.jsonWorldContentPaths[language]);

    http.Response req = await http.get(url);
    onProgress(req.contentLength, req.contentLength);
    StorageService storage = StorageService.language();
    var file =
        File(await storage.getPath(StorageKeys.manifestFile, json: true));
        print(file.absolute);
    if(!await file.exists()){
      file.create(recursive: true);
    }
    await file.writeAsString(req.body);
    _data = await compute(jsonDecode, req.body);
    bool success = await test();
    return success;
  }

  @override
  Future getDefinition(int hash, String type) async {
    var data = await _getManifest();
    return lookup(data, [type, "$hash"]);
  }

  @override
  Future<Map<int, dynamic>> getDefinitions(Set<int> hashes, String type) async{
    var data = await _getManifest();
    var map = new Map<int, dynamic>();
    for(var hash in hashes){
      map[hash] = lookup(data, [type, "$hash"]);
    }
    return map;
  }

  @override
  Future<void> reset() async {
    _data = null;
  }

  @override
  Future<bool> test() async {
    try{
      var def = await getDefinition(3628991658, 'DestinyInventoryItemDefinition');
      var name = lookup(def, ['displayProperties', 'name']);
      return name != null;
    }catch(e){
      print(e);
      return false;
    }
  }

  Future<dynamic> _getManifest() async{
    if(_data != null){
      return _data;
    }
    StorageService storage = StorageService.language();
    var file = File(await storage.getPath(StorageKeys.manifestFile, json: true));
    var json = await file.readAsString();
    print(json.length);
    _data = await compute(jsonDecode, json);
    return _data;
  }
}
