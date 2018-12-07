import 'package:bungie_api/models/destiny_manifest.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie-api/bungie-api.service.dart';
import 'package:little_light/services/manifest/manifest-downloader.dart';
import 'package:little_light/services/translate/pages/download-manifest-translation.dart';

typedef void OnFinishCallback();

class DownloadManifestWidget extends StatefulWidget {
  final DownloadManifestTranslation translation =
      new DownloadManifestTranslation();
  final ManifestDownloader downloader = new ManifestDownloader();
  final DestinyManifest manifest;
  final String selectedLanguage;
  final OnFinishCallback onFinish;
  DownloadManifestWidget({this.manifest, this.selectedLanguage, this.onFinish});

  @override
  DownloadManifestWidgetState createState() => new DownloadManifestWidgetState();
}

class DownloadManifestWidgetState
  extends State<DownloadManifestWidget> {
    double downloadProgress = 0;
  

  @override
  void initState() {
    super.initState();
    this.download();
  }

  void download() async{
    String base = BungieApiService.BaseUrl;
    String path = widget.manifest.mobileWorldContentPaths[widget.selectedLanguage];
    await downloadManifest("$base$path");
    await unzipManifest();
    bool result = await testManifest();
    print(result);
    if(result && widget.onFinish != null){
      widget.onFinish();
    }
  }

  Future downloadManifest(String url) async{
    await this.widget.downloader.download(url,onProgress: (loaded, total){
      setState(() {
         this.downloadProgress = loaded/total;       
      });
    });
  }

  Future unzipManifest() {
    return this.widget.downloader.unzip();
  }

  Future<bool> testManifest() {
    return this.widget.downloader.test();
  }

  @override
  Widget build(BuildContext context) {
      return Column(
      children: <Widget>[
        LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          value: this.downloadProgress,
        ),
      ],
    );
  }
}
