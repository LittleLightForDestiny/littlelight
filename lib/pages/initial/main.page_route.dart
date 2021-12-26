//@dart=2.12
import 'package:flutter/material.dart';
import 'package:little_light/pages/initial/notifiers/select_membership.notifier.dart';
import 'package:provider/provider.dart';

import 'notifiers/initial_page_state.notifier.dart';
import 'initial.page.dart';
import 'notifiers/manifest_downloader.notifier.dart';

class MainPageRoute extends MaterialPageRoute {
  MainPageRoute()
      : super(
            builder: (context) => MultiProvider(
                  providers: [
                    ChangeNotifierProvider<InitialPageStateNotifier>(
                      create: (context) => InitialPageStateNotifier(context),
                    ),
                    ChangeNotifierProvider<ManifestDownloaderNotifier>(
                      create: (context) => ManifestDownloaderNotifier(context),
                    ),
                    ChangeNotifierProvider<SelectMembershipNotifier>(
                      create: (context) => SelectMembershipNotifier(context),
                    )
                  ],
                  child: InitialPage(),
                ));
}
