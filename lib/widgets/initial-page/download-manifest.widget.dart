import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/translate/pages/download-manifest-translation.dart';

typedef void OnFinishCallback();

class DownloadManifestWidget extends StatefulWidget {
  final DownloadManifestTranslation translation =
      new DownloadManifestTranslation();
  final ManifestService manifest = new ManifestService();
  final String selectedLanguage;
  final OnFinishCallback onFinish;
  DownloadManifestWidget({this.selectedLanguage, this.onFinish});

  @override
  DownloadManifestWidgetState createState() {
    return new DownloadManifestWidgetState();
  }
}

class DownloadManifestWidgetState extends State<DownloadManifestWidget> {
  double _downloadProgress = 0;
  int _loaded = 0;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    if (_downloadProgress == 0) {
      this.download();
    }
  }

  void download() async {
    
    bool result = await this.widget.manifest.download(onProgress: (loaded, total) {
      setState(() {
        _downloadProgress = loaded / total;
        _loaded = (loaded/1024).floor();
        _total = (total/1024).floor();
      });
    });
    
    if(result){
      this.widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        LinearProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          value: (_downloadProgress != null && _downloadProgress < 1) ? _downloadProgress : null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(_downloadProgress < 1
                ? widget.translation.downloading.get()
                : widget.translation.uncompressing.get()),
            Text("$_loaded/${_total}KB")
          ],
        )
      ],
    );
  }
}
