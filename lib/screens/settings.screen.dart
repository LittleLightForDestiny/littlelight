import 'package:flutter/material.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';
import 'package:little_light/widgets/common/header.wiget.dart';

import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:screen/screen.dart';

class SettingsScreen extends StatefulWidget {
  final UserSettingsService settings = new UserSettingsService();
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool keepAwake = false;
  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  void loadSettings() async {
    keepAwake = await widget.settings.keepAwake;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          title: TranslatedTextWidget("Settings"),
        ),
        body: ListView(padding: EdgeInsets.all(8), children: <Widget>[
          ListTile(
              title: TranslatedTextWidget(
                "Keep Awake",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: TranslatedTextWidget(
                  "Keep device awake while the app is open"),
              trailing: Switch(
                value: keepAwake,
                onChanged: (val) {
                  keepAwake = val;
                  widget.settings.setKeepAwake(val);
                  setState(() {});
                  Screen.keepOn(val);
                },
              )),
          Container(height: 16),
          HeaderWidget(
              alignment: Alignment.centerLeft,
              child: TranslatedTextWidget(
                "Order items by",
                uppercase: true,
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          Container(
            height: 400,
            child: ReorderableListView(
                onReorder: (i, j) {}, children: buildItemOrderList(context)),
          )
        ]));
  }

  List<Widget> buildItemOrderList(BuildContext context) {
    return ["Power Level", "Name", "Sub type"].map((l) {
      return Container(
        key: Key(l),
        child: TranslatedTextWidget(l),
      );
    }).toList();
  }
}
