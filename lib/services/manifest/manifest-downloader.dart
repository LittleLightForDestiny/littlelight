import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:sqflite/sqflite.dart';

typedef Type DownloadProgress(int downloaded, int total);

class ManifestDownloader {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future download(String url, {DownloadProgress onProgress}) async {
    String localPath = await _localPath;
    HttpClient httpClient = new HttpClient();
    HttpClientRequest req = await httpClient.getUrl(Uri.parse(url));
    HttpClientResponse res = await req.close();
    File zippedManifest = new File("$localPath/zipped_manifest.zip");
    IOSink sink = zippedManifest.openWrite();
    int totalSize = res.contentLength;
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
  }

  Future unzip() async{
    String localPath = await _localPath;
    File zippedManifest = new File("$localPath/zipped_manifest.zip");
    List<int> readAsBytes = await zippedManifest.readAsBytes();
    Archive archive = new ZipDecoder().decodeBytes(readAsBytes);
    for (ArchiveFile file in archive) {
      String filename = "manifest.db";
        List<int> data = file.content;
        new File('$localPath/$filename')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
    }
    zippedManifest.delete();
  }

  Future<bool> test() async{
    String localPath = await _localPath;
    String filename = "manifest.db";
    Database db = await openDatabase("$localPath/$filename", readOnly: true);
    List<Map<String, dynamic>> results =  await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    return results.length > 0;
  }
}
