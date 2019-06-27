import 'dart:convert';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_manifest.dart';
import 'package:bungie_api/responses/destiny_manifest_response.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/bungie_api/enums/definition_table_names.enum.dart';
import 'package:little_light/services/manifest/sqlite_manifest.dart';
import 'package:little_light/services/storage/storage.service.dart';

import 'manifest_source.dart';


typedef Type DownloadProgress(int downloaded, int total);

class ManifestService {
  DestinyManifest _manifestInfo;
  final BungieApiService _api = new BungieApiService();
  final Map<String, dynamic> _cached = Map();
  static final ManifestService _singleton = new ManifestService._internal();
  
  ManifestSource _source;
  ManifestSource get source{
    if(_source != null){
      return _source;
    }
    _source = SQLiteManifest();
    return _source;
  }


  factory ManifestService() {
    return _singleton;
  }

  

  Future<void> reset() async {
    _cached.clear();
    source.reset();
  }

  ManifestService._internal();

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
    
    
    await saveManifestVersion(path);
    _cached.clear();
    bool success = await source.download(url, onProgress: onProgress);
    return success;
  }

  

  Future<bool> test() async {
    return source.test();
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
    
    var json = await source.getDefinition(hash, type);
    var def = identity(json);
    _cached["${type}_$hash"] = def;
    return def;
  }

  Future<Map<int, T>> getDefinitions<T>(Iterable<int> hashes,
      [dynamic identity(Map<String, dynamic> json)]) async {
    var type = DefinitionTableNames.fromClass[T];
    if (identity == null) {
      identity = DefinitionTableNames.identities[T];
    }
    Map<int, dynamic> json = await source.getDefinitions(hashes, type);
    return json.map<int, T>((i,j)=>MapEntry<int,T>(i, identity(j)));
  }
}
