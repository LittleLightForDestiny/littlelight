//@dart=2.12

import 'package:flutter/material.dart';
import 'package:little_light/pages/initial/notifiers/manifest_downloader.notifier.dart';
import 'package:little_light/pages/initial/subpages/subpage_base.dart';
import 'package:little_light/services/language/language.consumer.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:provider/provider.dart';

class DownloadManifestProgressSubPage extends StatefulWidget {
  DownloadManifestProgressSubPage();

  @override
  DownloadManifestProgressSubPageState createState() => new DownloadManifestProgressSubPageState();
}

class DownloadManifestProgressSubPageState extends SubpageBaseState<DownloadManifestProgressSubPage>
    with LanguageConsumer {
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
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
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
                : TranslatedTextWidget("Uncompressing", key: Key("unzipping")),
            Text("$downloadedSize/${totalDownloadSize}KB")
          ],
        )
      ]));
}
