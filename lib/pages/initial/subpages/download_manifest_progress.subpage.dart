import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/pages/initial/notifiers/manifest_downloader.notifier.dart';
import 'package:little_light/pages/initial/subpages/subpage_base.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:provider/provider.dart';

class DownloadManifestProgressSubPage extends StatefulWidget {
  DownloadManifestProgressSubPage();

  @override
  DownloadManifestProgressSubPageState createState() => DownloadManifestProgressSubPageState();
}

class DownloadManifestProgressSubPageState extends SubpageBaseState<DownloadManifestProgressSubPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget buildTitle(BuildContext context) => TranslatedTextWidget(
        "Download Database",
      );

  bool get downloading => !context.watch<ManifestDownloaderNotifier>().finishedDownloading;

  double get progress => context.watch<ManifestDownloaderNotifier>().downloadProgress;
  int get totalDownloadSize => context.watch<ManifestDownloaderNotifier>().totalDownloadSize;
  int get downloadedSize => context.watch<ManifestDownloaderNotifier>().downloadedSize;

  @override
  Widget buildContent(BuildContext context) => Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: Column(children: [
        LinearProgressIndicator(
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          value: downloading ? progress : null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            downloading
                ? TranslatedTextWidget(
                    "Downloading",
                    key: Key("downloading"),
                  )
                : Text("Uncompressing".translate(context), key: Key("unzipping")),
            Text("$downloadedSize/${totalDownloadSize}KB")
          ],
        )
      ]));
}
