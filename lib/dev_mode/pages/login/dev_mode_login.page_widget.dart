//@dart=2.12

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/routes/login_route.dart';
import 'package:little_light/dev_mode/pages/main/dev_mode_main.page.dart';
import 'package:little_light/services/auth/auth.consumer.dart';

class DevModeLoginPageWidget extends StatefulWidget {
  const DevModeLoginPageWidget({Key? key}) : super(key: key);

  @override
  _DevModeLoginPageWidgetState createState() => _DevModeLoginPageWidgetState();
}

class _DevModeLoginPageWidgetState extends State<DevModeLoginPageWidget> with AuthConsumer {
  LittleLightLoginArguments? get arguments => ModalRoute.of(context)?.settings.arguments as LittleLightLoginArguments?;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.home),
          onPressed: () async {
            Navigator.of(context).pushAndRemoveUntil(DevModeMainPageRoute(), (route) => false);
          },
        ),
        title: Text("Login"),
      ),
      body: SingleChildScrollView(
          child: Column(children: [
        buildAuthCode(context),
      ])),
    );
  }

  Widget buildAuthCode(BuildContext context) {
    return Card(
        child: Column(children: [
      ListTile(
        title: Text("Authorization Code"),
        subtitle: Text("${arguments?.code}"),
      ),
      ButtonBar(
        children: [
          TextButton(
              onPressed: () async {
                final args = arguments;
                if (args == null || args.code == null) return;
                await auth.addAccount(args.code!);
                Navigator.of(context).pushAndRemoveUntil(DevModeMainPageRoute(), (route) => false);
              },
              child: Text("Add Account"))
        ],
      )
    ]));
  }
}
