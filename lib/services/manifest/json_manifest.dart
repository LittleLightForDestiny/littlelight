import 'package:little_light/services/manifest/manifest_source.dart';
class JSONManifest extends ManifestSource{
  @override
  Future<bool> download(String sourcePath, {DownloadProgress onProgress}) {
    // TODO: implement download
    return null;
  }

  @override
  Future getDefinition(int hash, String type) {
    // TODO: implement getDefinition
    return null;
  }

  @override
  Future<Map<int, dynamic>> getDefinitions(Set<int> hashes, String type) {
    // TODO: implement getDefinitions
    return null;
  }

  @override
  Future<void> reset() {
    // TODO: implement reset
    return null;
  }

  @override
  Future<bool> test() {
    // TODO: implement test
    return null;
  }
  
}
