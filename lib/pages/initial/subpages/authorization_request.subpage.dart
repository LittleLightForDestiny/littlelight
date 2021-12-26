//@dart=2.12

import 'package:flutter/material.dart';
import 'package:little_light/pages/initial/notifiers/initial_page_state.notifier.dart';
import 'package:little_light/pages/initial/notifiers/manifest_downloader.notifier.dart';
import 'package:little_light/pages/initial/subpages/subpage_base.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/language/language.consumer.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:provider/provider.dart';

class AuthorizationRequestSubPage extends StatefulWidget {
  AuthorizationRequestSubPage();

  @override
  AuthorizationRequestSubPageState createState() => new AuthorizationRequestSubPageState();
}

class AuthorizationRequestSubPageState extends SubpageBaseState<AuthorizationRequestSubPage> with AuthConsumer {
  @override
  void initState() {
    super.initState();
  }

  bool get forceReauth => Provider.of<InitialPageStateNotifier>(context, listen: false).forceReauth;

  @override
  Widget buildTitle(BuildContext context) => TranslatedTextWidget(
        "Login",
      );

  @override
  Widget buildContent(BuildContext context) => Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
            padding: EdgeInsets.all(8),
            child: forceReauth
                ? TranslatedTextWidget("Authorize with Bungie.net to use inventory management features")
                : TranslatedTextWidget("Please re-authorize Little Light to keep using inventory management features")),
        ElevatedButton(
          onPressed: () {
            auth.openBungieLogin(forceReauth);
          },
          child: TranslatedTextWidget("Authorize with Bungie.net"),
        ),
      ]));
}
