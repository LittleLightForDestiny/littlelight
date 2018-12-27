import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:bungie_api/models/destiny_talent_grid_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/services/bungie-api/enums/definition-table-names.enum.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

typedef Type DownloadProgress(int downloaded, int total);

class ManifestService{
  Map<dynamic, dynamic> _data;
  final String manifestVersionKey = "manifestVersion";

  static final ManifestService _singleton = new ManifestService._internal();
  factory ManifestService() {
    return _singleton;
  }
  ManifestService._internal();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future download(String url, {DownloadProgress onProgress}) async {
    String localPath = await _localPath;
    HttpClient httpClient = new HttpClient();
    httpClient.autoUncompress = true;
    HttpClientRequest req = await httpClient.getUrl(Uri.parse(url));
    HttpClientResponse res = await req.close();
    File manifestFile = new File("$localPath/manifest.json");
    IOSink sink = manifestFile.openWrite();
    int totalSize = res.contentLength > 0 ? res.contentLength : 66000000;
    int loaded = 0;
    Stream<List<int>> stream = res.asBroadcastStream();
    await for( var data in stream){
      loaded += data.length;
      sink.add(data);
      if(onProgress != null){
        onProgress(loaded, totalSize);
      }
    }
    await sink.flush();
    await sink.close();
    await this.load();
  }

  Future<Map<dynamic, dynamic>> load() async{
    String localPath = await _localPath;
    File manifestFile = new File("$localPath/manifest.json");
    String str = await manifestFile.readAsString();
    _data = jsonDecode(str);
    return _data;
  }

  Future<String> getSavedVersion() async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String version = _prefs.getString(manifestVersionKey);
    if(version == null){
      return null;
    }
    return version;
  }
  Future<void> saveManifestVersion(String version) async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString(manifestVersionKey, version);
  }

  DestinyInventoryItemDefinition getItemDefinition(int hash){
    Map<String, dynamic> json = getDefinition(DefinitionTableNames.destinyInventoryItemDefinition, hash);
    return DestinyInventoryItemDefinition.fromMap(json);
  }

  DestinyStatDefinition getStatDefinition(int hash){
    Map<String, dynamic> json = getDefinition(DefinitionTableNames.destinyStatDefinition, hash);
    return DestinyStatDefinition.fromMap(json);
  }

  DestinyTalentGridDefinition getTalentGridDefinition(int hash){
    Map<String, dynamic> json = getDefinition(DefinitionTableNames.destinyTalentGridDefinition, hash);
    return DestinyTalentGridDefinition.fromMap(json);
  }

  DestinyInventoryBucketDefinition getBucketDefinition(int hash){
    Map<String, dynamic> json = getDefinition(DefinitionTableNames.destinyInventoryBucketDefinition, hash);
    return DestinyInventoryBucketDefinition.fromMap(json);
  }

 Map<String, dynamic> getDefinition(String type, int hash){
    return _data[type][hash.toString()];
  }
}