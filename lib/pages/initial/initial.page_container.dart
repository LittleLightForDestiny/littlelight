import 'package:flutter/material.dart';
import 'package:little_light/pages/initial/initial.page.dart';
import 'package:provider/provider.dart';

import 'notifiers/initial_page_state.notifier.dart';
import 'notifiers/manifest_downloader.notifier.dart';
import 'notifiers/select_membership.notifier.dart';
import 'notifiers/select_wishlists.notifier.dart';

class InitialPageContianer extends StatelessWidget {
  const InitialPageContianer() : super();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<ManifestDownloaderNotifier>(
              create: (context) => ManifestDownloaderNotifier(context),
            ),
            ChangeNotifierProvider<SelectMembershipNotifier>(
              create: (context) => SelectMembershipNotifier(context),
            ),
            ChangeNotifierProvider<SelectWishlistNotifier>(
              create: (context) => SelectWishlistNotifier(context),
            ),
            ChangeNotifierProvider<InitialPageStateNotifier>(
              create: (context) => InitialPageStateNotifier(context),
            ),
          ],
          child: const InitialPage(),
        ));
  }
}
