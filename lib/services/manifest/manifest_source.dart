import 'package:bungie_api/models/destiny_manifest.dart';

typedef Type DownloadProgress(int downloaded, int total);
abstract class ManifestSource {
  Future<bool> test();
  Future<void> reset();
  Future<bool> download(DestinyManifest manifestInfo, String language, {DownloadProgress onProgress});
  Future<Map<int, dynamic>> getDefinitions(Set<int> hashes, String type);
  Future<dynamic> getDefinition(int hash, String type);
  
}
