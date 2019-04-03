import 'dart:io';

import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:little_light/services/translate/translate.service.dart';
import 'package:little_light/widgets/about/supporter_character.widget.dart';
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
    bool isIOS = Platform.isIOS;
    EdgeInsets screenPadding = MediaQuery.of(context).padding;
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
                      HeaderWidget(
                          alignment: Alignment.centerLeft,
                          child: TranslatedTextWidget(
                            "Contact",
                            uppercase: true,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                        Container(
                        height: 4,
                      ),
                      RaisedButton(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.twitter, size: 16),
                              Container(width: 4),
                              TranslatedTextWidget("Follow @LittleLightD2")
                            ]),
                        onPressed: () {
                          launch("http://www.twitter.com/littlelightD2");
                        },
                      ),
                        Container(
                        height: 4,
                      ),
                      RaisedButton(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        color: Colors.blueGrey.shade400,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.discord, size: 16),
                              Container(width: 4),
                              TranslatedTextWidget("Join the Discord server")
                            ]),
                        onPressed: () {
                          launch("https://discord.gg/ztdFGGz");
                        },
                      ),
                        Container(
                        height: 4,
                      ),
                      RaisedButton(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        color: Colors.red.shade600,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.github, size: 16),
                              Container(width: 4),
                              TranslatedTextWidget("Report issues")
                            ]),
                        onPressed: () {
                          launch(
                              "https://github.com/LittleLightForDestiny/LittleLight/issues");
                        },
                      ),
                      Container(height: 16),
                      HeaderWidget(
                          alignment: Alignment.centerLeft,
                          child: TranslatedTextWidget(
                            "Want to support Little Light ?",
                            uppercase: true,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      Container(
                        height: 4,
                      ),
                      RaisedButton(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                    isIOS
                                        ? FontAwesomeIcons.appStoreIos
                                        : FontAwesomeIcons.googlePlay,
                                    size: 20),
                                Container(
                                  width: 4,
                                ),
                                TranslatedTextWidget(
                                  "Rate it",
                                  uppercase: true,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                )
                              ]),
                          onPressed: () {
                            LaunchReview.launch(
                                androidAppId: 'me.markezine.luzinha',
                                iOSAppId: '1373037254');
                          }),
                      Container(
                        height: 4,
                      ),
                      RaisedButton(
                          color: Color.fromRGBO(249, 104, 84, 1),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    width: 20,
                                    height: 20,
                                    child: Image.asset(
                                        "assets/imgs/patreon-icon.png")),
                                Container(
                                  width: 4,
                                ),
                                TranslatedTextWidget(
                                  "Become a Patron",
                                  uppercase: true,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                )
                              ]),
                          onPressed: () {
                            launch('https://www.patreon.com/littlelightD2');
                          }),
                      Container(
                        height: 4,
                      ),
                      RaisedButton(
                          color: Color.fromRGBO(26, 169, 222, 1),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    width: 20,
                                    height: 20,
                                    child: Image.asset(
                                        "assets/imgs/ko-fi-icon.png")),
                                Container(
                                  width: 4,
                                ),
                                TranslatedTextWidget(
                                  "Buy me a Coffee",
                                  uppercase: true,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                )
                              ]),
                          onPressed: () {
                            launch('https://ko-fi.com/littlelight');
                          }),
                      Container(
                        height: 16,
                      ),
                      HeaderWidget(
                        alignment: Alignment.centerLeft,
                        child: TranslatedTextWidget("Development",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            uppercase: true),
                      ),
                      Container(
                        height: 8,
                      ),
                      buildTagAndPlatform(4611686018441021725, 2),
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
                            buildTagAndPlatform(4611686018429051657, 2),
                            Container(
                              height: 4,
                            ),
                            buildTagAndPlatform(4611686018450956952, 2),
                          ])),
                      Container(height: 8),
                      buildTranslationHeader(context, ['it']),
                      Container(
                          color: Colors.blueGrey.shade800,
                          padding: EdgeInsets.all(4),
                          child: Column(children: [
                            buildTagAndPlatform(4611686018467289582, 4),
                          ])),
                      Container(height: 8),
                      buildTranslationHeader(context, ['pl']),
                      Container(
                          color: Colors.blueGrey.shade800,
                          padding: EdgeInsets.all(4),
                          child: Column(children: [
                            buildTagAndPlatform(4611686018451719977, 2),
                          ])),
                      Container(height: 8),
                      buildTranslationHeader(context, ['ru']),
                      Container(
                          color: Colors.blueGrey.shade800,
                          padding: EdgeInsets.all(4),
                          child: Column(children: [
                            buildTagAndPlatform(4611686018486012725, 4),
                          ])),
                      Container(height: 8),
                      Container(height: screenPadding.bottom,)
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
            ),
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

  buildTagAndPlatform(int membershipId, int membershipType) {
    return SupporterCharacterWidget(membershipId, membershipType);
  }
}
