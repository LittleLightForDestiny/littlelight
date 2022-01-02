//@dart=2.12

import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/manifest/manifest_download_progress.dart';

class ManifestDownloaderNotifier with ChangeNotifier, ManifestConsumer {
  final BuildContext context;

  ManifestDownloaderNotifier(this.context);

  DownloadProgress? _progress;
  
  double get downloadProgress => (downloadedSize/totalDownloadSize.clamp(.1, double.maxFinite));
  int get totalDownloadSize => ((_progress?.totalBytes ?? 0)/1024).floor();
  int get downloadedSize => ((_progress?.downloadedBytes ?? 0)/1024).floor();
  bool get finishedDownloading => _progress?.downloaded ?? false;
  bool get finishedUncompressing => _progress?.unzipped ?? false;
  bool get error => _progress is DownloadError;

  downloadManifest([bool skipCache = false]) async{
    final stream = manifest.download(skipCache);
    await for(final value in stream){
      _progress = value;
      notifyListeners();
    }
  }
}
