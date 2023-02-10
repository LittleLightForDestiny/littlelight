import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/pages/initial/notifiers/initial_page_state.notifier.dart';
import 'package:little_light/pages/initial/subpages/subpage_base.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:provider/provider.dart';

class AuthorizationRequestSubPage extends StatefulWidget {
  const AuthorizationRequestSubPage();

  @override
  AuthorizationRequestSubPageState createState() => AuthorizationRequestSubPageState();
}

class AuthorizationRequestSubPageState extends SubpageBaseState<AuthorizationRequestSubPage> with AuthConsumer {
  @override
  void initState() {
    super.initState();
  }

  bool get forceReauth => Provider.of<InitialPageStateNotifier>(context, listen: false).forceReauth;

  @override
  Widget buildTitle(BuildContext context) => Text(
        "Login".translate(context),
      );

  @override
  Widget buildContent(BuildContext context) => Container(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
            padding: const EdgeInsets.all(8).copyWith(bottom: 24),
            child: forceReauth
                ? Text("Authorize with Bungie.net to use inventory management features".translate(context))
                : Text(
                    "Please re-authorize Little Light to keep using inventory management features".translate(context))),
        ElevatedButton(
          onPressed: () {
            auth.openBungieLogin(forceReauth);
          },
          child: Text("Authorize with Bungie.net".translate(context)),
        ),
      ]));
}
