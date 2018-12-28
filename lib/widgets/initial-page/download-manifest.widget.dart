import 'package:bungie_api/models/destiny_manifest.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie-api/bungie-api.service.dart';
import 'package:little_light/services/bungie-api/enums/definition-table-names.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/translate/pages/download-manifest-translation.dart';

typedef void OnFinishCallback();

class DownloadManifestWidget extends StatefulWidget {
  final DownloadManifestTranslation translation =
      new DownloadManifestTranslation();
  final ManifestService manifestService = new ManifestService();
  final DestinyManifest manifest;
  final String selectedLanguage;
  final OnFinishCallback onFinish;
  DownloadManifestWidget({this.manifest, this.selectedLanguage, this.onFinish});

  @override
  DownloadManifestWidgetState createState(){
    
    return new DownloadManifestWidgetState();
  }   
}

class DownloadManifestWidgetState extends State<DownloadManifestWidget> {
  double _downloadProgress = 0;

  @override
  void initState() {
    super.initState();
    if(_downloadProgress == 0 ){
      this.download();
    }    
  }

  void download() async {
    String base = BungieApiService.baseUrl;
    String path = widget.manifest.jsonWorldContentPaths[widget.selectedLanguage];
    await downloadManifest("$base$path");
    Map data = await this.widget.manifestService.load();
    if(data[DefinitionTableNames.destinyInventoryItemDefinition] != null){
      this.widget.onFinish();
    }
  }

  Future downloadManifest(String url) async {
    await this.widget.manifestService.download(url, onProgress: (loaded, total) {
      setState(() {
        if(loaded < total){
          _downloadProgress = loaded / total;
        }else{
          _downloadProgress = null;
        }
        
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        LinearProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          value: _downloadProgress,
        ),
      ],
    );
  }
}
