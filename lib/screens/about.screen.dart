import 'package:flutter/material.dart';
import 'package:little_light/services/translate/translate.service.dart';
import 'package:little_light/utils/platform_data.dart';
import 'package:little_light/widgets/common/header.wiget.dart';

import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String packageVersion = "";
  String appName = "";
  @override
  void initState() {
    super.initState();
    getInfo();
  }

  void getInfo() async {
    var info = await PackageInfo.fromPlatform();
    packageVersion = info.version;
    appName = info.appName;

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
          title: TranslatedTextWidget("About"),
        ),
        body: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  buildAppInfo(context),
                  Container(
                    height: 8,
                  ),
                  RaisedButton(

                    child:Row(children:[Icon(FontAwesomeIcons.twitter), Container(width:4), TranslatedTextWidget("Follow @LittleLightD2")]), 
                  onPressed: (){
                    launch("http://www.twitter.com/littlelightD2");
                  },),
                  Container(height:8),
                  HeaderWidget(
                    alignment: Alignment.centerLeft,
                    child: TranslatedTextWidget("Development",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        uppercase: true),
                  ),
                  Container(
                    height: 8,
                  ),
                  buildTagAndPlatform("jaoryuken", 2),
                  Container(
                    height: 8,
                  ),
                  HeaderWidget(
                    alignment: Alignment.centerLeft,
                    child: TranslatedTextWidget("Translations",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        uppercase: true),
                  ),
                  Container(height: 8),
                  buildTranslationHeader(context, ['es', 'es-mx']),
                  Container(
                      color: Colors.blueGrey.shade800,
                      padding: EdgeInsets.all(4),
                      child: Column(children: [
                        buildTagAndPlatform("RaSSieL", 2),
                        Container(
                          height: 4,
                        ),
                        buildTagAndPlatform("alexfa55", 2),
                      ])),
                  Container(height: 8),
                  buildTranslationHeader(context, ['it']),
                  Container(
                      color: Colors.blueGrey.shade800,
                      padding: EdgeInsets.all(4),
                      child: Column(children: [
                        buildTagAndPlatform("QUB3X#2230", 4),
                      ])),
                  Container(height: 8),
                  buildTranslationHeader(context, ['pl']),
                  Container(
                      color: Colors.blueGrey.shade800,
                      padding: EdgeInsets.all(4),
                      child: Column(children: [
                        buildTagAndPlatform("Nicolas2837", 2),
                      ])),
                  Container(height: 8),
                  buildTranslationHeader(context, ['ru']),
                  Container(
                      color: Colors.blueGrey.shade800,
                      padding: EdgeInsets.all(4),
                      child: Column(children: [
                        buildTagAndPlatform("Antonius#21840", 4),
                      ])),
                  Container(height: 8),
                ]))));
  }

  Widget buildAppInfo(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
            width: 96,
            height: 96,
            child: Image.asset('assets/imgs/app_icon.png')),
        Container(
          width: 8,
        ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "$appName v$packageVersion",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )
          ],
        ))
      ],
    );
  }

  buildTranslationHeader(BuildContext context, List<String> languages) {
    List<Widget> flags = languages.map((l) => flagIcon(l)).toList();
    Text languageNames = Text(
        languages.map((l) => TranslateService().languageNames[l]).join("/"));
    return Container(
        color: Colors.blueGrey.shade600,
        padding: EdgeInsets.all(4),
        child: Row(
          children: flags + [Container(width: 4), languageNames],
        ));
  }

  Widget flagIcon(String code) {
    return Container(
        width: 24,
        height: 24,
        child: Image.asset("assets/imgs/flags/$code.png"));
  }

  buildTagAndPlatform(String name, int platformType) {
    var platform = PlatformData.getPlatform(platformType);
    return Container(
        decoration: BoxDecoration(
            color: platform.color, borderRadius: BorderRadius.circular(4)),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: <Widget>[
            Icon(platform.iconData),
            Container(
              width: 4,
            ),
            Text(name)
          ],
        ));
  }
}
