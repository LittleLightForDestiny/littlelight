import 'dart:convert';

import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/routes/little_light_route.dart';
import 'package:little_light/dev_mode/pages/login/dev_mode_login.page.dart';
import 'package:little_light/services/auth/auth.consumer.dart';

class DevModeLoginPageWidget extends StatefulWidget {
  const DevModeLoginPageWidget({Key key}) : super(key: key);

  @override
  _DevModeLoginPageWidgetState createState() => _DevModeLoginPageWidgetState();
}

class _DevModeLoginPageWidgetState extends State<DevModeLoginPageWidget>
    with AuthConsumer {
  DevModeLoginPageArguments get arguments =>
      ModalRoute.of(context).settings.arguments;

  BungieNetToken token;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(FontAwesomeIcons.home), onPressed: (){
          Navigator.pushAndRemoveUntil(context, LittleLightRoute(), (route) => false);
        },),
        title: Text("Login"),
      ),
      body: SingleChildScrollView(
          child: Column(children: [
        buildAuthCode(context),
        if (token != null) buildTokenInfo(context)
      ])),
    );
  }

  Widget buildAuthCode(BuildContext context) {
    return Card(
        child: Column(children: [
      ListTile(
        title: Text("Authorization Code"),
        subtitle: Text("${arguments.code}"),
      ),
      ButtonBar(
        children: [
          TextButton(
              onPressed: () async {
                final token = await auth.addAccount(arguments.code);
                setState(() {
                  this.token = token;
                });
              },
              child: Text("Add Account"))
        ],
      )
    ]));
  }

  Widget buildTokenInfo(BuildContext context) {
    final _tokenStr = jsonEncode(token.toJson());
    return Card(
        child: ListTile(
      title: Text("Token"),
      subtitle: Text("$_tokenStr"),
    ));
  }
}
