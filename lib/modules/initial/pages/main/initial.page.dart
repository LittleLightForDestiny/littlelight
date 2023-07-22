import 'package:flutter/material.dart';
import 'package:little_light/modules/initial/pages/main/initial.view.dart';
import 'package:provider/provider.dart';

import '../../../../pages/initial/notifiers/manifest_downloader.notifier.dart';
import '../../../../pages/initial/notifiers/select_membership.notifier.dart';
import '../../../../pages/initial/notifiers/select_wishlists.notifier.dart';
import 'initial.bloc.dart';

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
          child: const InitialView(),
        ));
  }
}
