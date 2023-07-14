import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/pages/initial/notifiers/manifest_downloader.notifier.dart';
import 'package:little_light/pages/initial/subpages/subpage_base.dart';
import 'package:provider/provider.dart';

class DownloadManifestProgressSubPage extends StatefulWidget {
  const DownloadManifestProgressSubPage();

  @override
  DownloadManifestProgressSubPageState createState() => DownloadManifestProgressSubPageState();
}

class DownloadManifestProgressSubPageState extends SubpageBaseState<DownloadManifestProgressSubPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget buildTitle(BuildContext context) => Text(
        "Download Database".translate(context),
      );

  bool get downloading => !context.watch<ManifestDownloaderNotifier>().finishedDownloading;

  double get progress => context.watch<ManifestDownloaderNotifier>().downloadProgress;
  int get totalDownloadSize => context.watch<ManifestDownloaderNotifier>().totalDownloadSize;
  int get downloadedSize => context.watch<ManifestDownloaderNotifier>().downloadedSize;

  @override
  Widget buildContent(BuildContext context) => Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(children: [
        LinearProgressIndicator(
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          value: downloading ? progress : null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            downloading
                ? Text(
                    "Downloading".translate(context),
                    key: const Key("downloading"),
                  )
                : Text("Uncompressing".translate(context), key: const Key("unzipping")),
            Text("$downloadedSize/${totalDownloadSize}KB")
          ],
        )
      ]));
}
