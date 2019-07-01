typedef Type DownloadProgress(int downloaded, int total);
abstract class ManifestSource {
  Future<bool> test();
  Future<void> reset();
  Future<bool> download(String sourcePath, {DownloadProgress onProgress});
  Future<Map<int, dynamic>> getDefinitions(Set<int> hashes, String type);
  Future<dynamic> getDefinition(int hash, String type);
}
