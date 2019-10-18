import 'dart:io';

import 'package:bungie_api/enums/bungie_membership_type_enum.dart';
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
                      buildContact(context),
                      Container(height: 16),
                      buildSupport(context),
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
                      buildTagAndPlatform(4611686018441021725, BungieMembershipType.TigerPsn),
                      Container(
                        height: 8,
                      ),
                      HeaderWidget(
                        alignment: Alignment.centerLeft,
                        child: TranslatedTextWidget("Art",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            uppercase: true),
                      ),
                      Container(
                        height: 8,
                      ),
                      buildTagAndPlatform(4611686018429190727, BungieMembershipType.TigerPsn),
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
                      buildTranslationHeader(context, ['de']),
                      Container(
                          color: Colors.blueGrey.shade800,
                          padding: EdgeInsets.all(4),
                          child: Column(children: [
                            buildTagAndPlatform(4611686018463551188, BungieMembershipType.TigerPsn),
                          ])),
                      Container(height: 8),
                      buildTranslationHeader(context, ['es', 'es-mx']),
                      Container(
                          color: Colors.blueGrey.shade800,
                          padding: EdgeInsets.all(4),
                          child: Column(children: [
                            buildTagAndPlatform(4611686018429051657, BungieMembershipType.TigerPsn),
                            Container(
                              height: 4,
                            ),
                            buildTagAndPlatform(4611686018450956952, BungieMembershipType.TigerPsn),
                          ])),
                      Container(height: 8),
                      buildTranslationHeader(context, ['fr']),
                      Container(
                          color: Colors.blueGrey.shade800,
                          padding: EdgeInsets.all(4),
                          child: Column(children: [
                            buildTagAndPlatform(
                                4611686018436875822,
                                2,
                                "https://play.google.com/store/apps/details?id=com.eldwyn.wotabyss",
                                Container(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Row(children: [
                                      Container(
                                          width: 14,
                                          height: 14,
                                          child: Image.asset(
                                              'assets/imgs/arcadia_icon.png')),
                                      Container(width: 4),
                                      Text("Arcadia Dev",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold))
                                    ]))),
                          ])),
                      Container(height: 8),
                      buildTranslationHeader(context, ['it']),
                      Container(
                          color: Colors.blueGrey.shade800,
                          padding: EdgeInsets.all(4),
                          child: Column(children: [
                            buildTagAndPlatform(4611686018468567020, BungieMembershipType.TigerSteam),
                            Container(
                              height: 4,
                            ),
                            buildTagAndPlatform(4611686018467289582, BungieMembershipType.TigerSteam),
                          ])),
                      Container(height: 8),
                      buildTranslationHeader(context, ['ja']),
                      Container(
                          color: Colors.blueGrey.shade800,
                          padding: EdgeInsets.all(4),
                          child: Column(children: [
                            buildTagAndPlatform(4611686018467519241, BungieMembershipType.TigerSteam),
                          ])),
                      Container(height: 8),
                      buildTranslationHeader(context, ['ko']),
                      Container(
                          color: Colors.blueGrey.shade800,
                          padding: EdgeInsets.all(4),
                          child: Column(children: [
                            buildTagAndPlatform(4611686018488602145, BungieMembershipType.TigerSteam),
                          ])),
                      Container(height: 8),
                      buildTranslationHeader(context, ['pt-br']),
                      Container(
                          color: Colors.blueGrey.shade800,
                          padding: EdgeInsets.all(4),
                          child: Column(children: [
                            buildTagAndPlatform(4611686018441021725, BungieMembershipType.TigerPsn),
                          ])),
                      Container(height: 8),
                      buildTranslationHeader(context, ['pl']),
                      Container(
                          color: Colors.blueGrey.shade800,
                          padding: EdgeInsets.all(4),
                          child: Column(children: [
                            buildTagAndPlatform(4611686018451719977, BungieMembershipType.TigerPsn),
                          ])),
                      Container(height: 8),
                      buildTranslationHeader(context, ['ru']),
                      Container(
                          color: Colors.blueGrey.shade800,
                          padding: EdgeInsets.all(4),
                          child: Column(children: [
                            buildTagAndPlatform(4611686018486012725, BungieMembershipType.TigerSteam),
                          ])),
                      Container(height: 8),
                      HeaderWidget(
                        alignment: Alignment.centerLeft,
                        child: TranslatedTextWidget("Supporters",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            uppercase: true),
                      ),
                      Container(
                        height: 8,
                      ),
                      buildTagAndPlatform(4611686018429238118, BungieMembershipType.TigerPsn),
                      Container(
                        height: 8,
                      ),
                      buildTagAndPlatform(4611686018452346120, BungieMembershipType.TigerPsn),
                      Container(
                        height: 8,
                      ),
                      buildTagAndPlatform(4611686018430226498, BungieMembershipType.TigerXbox),
                      Container(
                        height: 8,
                      ),
                      buildTagAndPlatform(4611686018434959588, BungieMembershipType.TigerXbox),
                      Container(
                        height: 8,
                      ),
                      buildTagAndPlatform(4611686018482820655, BungieMembershipType.TigerSteam),
                      Container(
                        height: 8,
                      ),
                      buildTagAndPlatform(4611686018436933892, BungieMembershipType.TigerXbox),
                      Container(
                        height: 8,
                      ),
                      buildTagAndPlatform(4611686018433235027, BungieMembershipType.TigerXbox),
                      Container(
                        height: 8,
                      ),
                      Container(
                        height: screenPadding.bottom,
                      )
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

  buildTagAndPlatform(int membershipId, int membershipType,
      [String link, Widget badge]) {
    return SupporterCharacterWidget(membershipId, membershipType, link, badge);
  }

  buildContact(BuildContext context) {
    return Column(
      children: <Widget>[
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
        IntrinsicHeight(
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(
                child: RaisedButton(
              padding: EdgeInsets.all(4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              child: Column(children: [
                Expanded(child: Icon(FontAwesomeIcons.twitter, size: 32)),
                Container(height: 4),
                Text(
                  "@LittleLightD2",
                  textAlign: TextAlign.center,
                )
              ]),
              onPressed: () {
                launch("http://www.twitter.com/littlelightD2");
              },
            )),
            Container(
              width: 4,
            ),
            Flexible(
                child: RaisedButton(
              padding: EdgeInsets.all(4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              color: Colors.blueGrey.shade400,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Icon(FontAwesomeIcons.discord, size: 32)),
                    Container(height: 4),
                    TranslatedTextWidget("Discord")
                  ]),
              onPressed: () {
                launch("https://discord.gg/ztdFGGz");
              },
            )),
            Container(
              width: 4,
            ),
            Flexible(
                child: RaisedButton(
              padding: EdgeInsets.all(4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              color: Colors.red.shade600,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Icon(FontAwesomeIcons.github, size: 32)),
                    Container(height: 4),
                    TranslatedTextWidget("Issues")
                  ]),
              onPressed: () {
                launch(
                    "https://github.com/LittleLightForDestiny/LittleLight/issues");
              },
            )),
          ],
        )),
      ],
    );
  }

  buildSupport(BuildContext context) {
    bool isIOS = Platform.isIOS;
    return Column(
      children: <Widget>[
        HeaderWidget(
            alignment: Alignment.centerLeft,
            child: TranslatedTextWidget(
              "Support Little Light",
              uppercase: true,
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
        Container(
          height: 4,
        ),
        IntrinsicHeight(
          child: isIOS ? buildRateButton(context) : Row(
            children: <Widget>[
              Expanded(
                child: buildRateButton(context)
              ),
              Container(
                width: 4,
              ),
              Expanded(
                child: RaisedButton(
                    padding: EdgeInsets.all(4),
                    color: Color.fromRGBO(249, 104, 84, 1),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                                width: 36,
                                height: 36,
                                child: Image.asset(
                                    "assets/imgs/patreon-icon.png")),
                          ),
                          Container(
                            height: 4,
                          ),
                          TranslatedTextWidget(
                            "Become a Patron",
                            uppercase: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          )
                        ]),
                    onPressed: () {
                      launch('https://www.patreon.com/littlelightD2');
                    }),
              ),
              Container(
                width: 4,
              ),
              Expanded(
                  child: RaisedButton(
                      padding: EdgeInsets.all(4),
                      color: Color.fromRGBO(26, 169, 222, 1),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Container(
                                    width: 36,
                                    height: 36,
                                    child: Image.asset(
                                        "assets/imgs/ko-fi-icon.png"))),
                            Container(
                              height: 4,
                            ),
                            TranslatedTextWidget(
                              "Buy me a Coffee",
                              uppercase: true,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            )
                          ]),
                      onPressed: () {
                        launch('https://ko-fi.com/littlelight');
                      })),
            ],
          ),
        ),
      ],
    );
  }

  buildRateButton(BuildContext context) {
    bool isIOS = Platform.isIOS;
    return RaisedButton(
        color: isIOS
            ? Color.fromARGB(255, 22, 147, 245)
            : Color.fromARGB(255, 49, 159, 185),
        padding: EdgeInsets.all(4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
              child: Icon(
                  isIOS
                      ? FontAwesomeIcons.appStoreIos
                      : FontAwesomeIcons.googlePlay,
                  size: 36)),
          Container(
            height: 4,
          ),
          TranslatedTextWidget(
            "Rate it",
            uppercase: true,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          )
        ]),
        onPressed: () {
          LaunchReview.launch(
              androidAppId: 'me.markezine.luzinha', iOSAppId: '1373037254');
        });
  }
}
