//@dart=2.12
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'initial.page.dart';
import 'notifiers/initial_page_state.notifier.dart';
import 'notifiers/manifest_downloader.notifier.dart';
import 'notifiers/select_membership.notifier.dart';

class LoginPageRoute extends MaterialPageRoute {
  LoginPageRoute(RouteSettings settings)
      : super(
            settings: settings,
            builder: (context) => WillPopScope(
                onWillPop: () async => false,
                child: MultiProvider(
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
                )));
}
