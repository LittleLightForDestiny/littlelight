//@dart=2.12
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'initial.page.dart';
import 'notifiers/initial_page_state.notifier.dart';
import 'notifiers/manifest_downloader.notifier.dart';
import 'notifiers/select_membership.notifier.dart';
import 'notifiers/select_wishlists.notifier.dart';

abstract class InitialPageRouteBase extends MaterialPageRoute {
  InitialPageRouteBase({RouteSettings? settings})
      : super(
            settings: settings,
            builder: (context) => WillPopScope(
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
                  child: InitialPage(),
                )));
}