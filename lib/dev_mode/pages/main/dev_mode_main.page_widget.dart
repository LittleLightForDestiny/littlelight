import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/services/auth/auth.consumer.dart';

class DevModeMainPageWidget extends StatefulWidget {
  const DevModeMainPageWidget({Key key}) : super(key: key);

  @override
  _DevModeMainPageWidgetState createState() => _DevModeMainPageWidgetState();
}

class _DevModeMainPageWidgetState extends State<DevModeMainPageWidget> with AuthConsumer{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Main"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [buildAuthCard(context)],
        ),
      ),
    );
  }

  Widget buildAuthCard(BuildContext context) => Card(
        child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(FontAwesomeIcons.user),
                  title: Text("Auth"),
                ),
                ButtonBar(
                  children: [
                    TextButton(child: Text("Login"), onPressed: (){
                      auth.openBungieLogin(true);
                    },)
                  ],
                )
              ],
            )),
      );
}
