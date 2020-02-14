import 'dart:io';

import 'package:bungie_api/enums/bungie_membership_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:launch_review/launch_review.dart';
import 'package:little_light/models/collaborators.dart';
import 'package:little_light/services/littlelight/littlelight_data.service.dart';
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
  CollaboratorsResponse collaborators;

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
    collaborators = await LittleLightDataService().getCollaborators();
    collaborators.supporters.shuffle();
    this.setState(() {});
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
        body: StaggeredGridView.countBuilder(
          padding: EdgeInsets.all(8).add(EdgeInsets.only(left:screenPadding.left, right:screenPadding.right)),
          addAutomaticKeepAlives: true,
          itemBuilder: itemBuilder,
          staggeredTileBuilder: tileBuilder,
          mainAxisSpacing: 8,
          crossAxisCount: 1,
        ));
  }

  Widget itemBuilder(BuildContext context, int index) {
    switch (index) {
      case 0:
        return buildAppInfo(context);
      case 1:
        return buildContact(context);
      case 2:
        return buildSupport(context);
    }
    if (collaborators == null) return null;
    int currentIndex = 3;
    if (currentIndex == index)
      return HeaderWidget(
      child: TranslatedTextWidget("Supporters", uppercase: true,
              style: TextStyle(fontWeight: FontWeight.bold),
              ),alignment: Alignment.centerLeft,);
    currentIndex++;
    if (index - currentIndex < collaborators.supporters.length) {
      var player = collaborators.supporters[index - currentIndex];
      return buildTagAndPlatform(player.membershipId, player.membershipType);
    }
    currentIndex += collaborators.supporters.length;
    if (currentIndex == index)
      return HeaderWidget(child: TranslatedTextWidget("Development", uppercase: true,
              style: TextStyle(fontWeight: FontWeight.bold),
              ),alignment: Alignment.centerLeft,);
    currentIndex++;
    if (index - currentIndex < collaborators.developers.length) {
      var player = collaborators.developers[index - currentIndex];
      return buildTagAndPlatform(player.membershipId, player.membershipType);
    }
    currentIndex += collaborators.developers.length;
    if (currentIndex == index)
      return HeaderWidget(child: TranslatedTextWidget("Translations", uppercase: true,
              style: TextStyle(fontWeight: FontWeight.bold),
              ),alignment: Alignment.centerLeft,);
    currentIndex++;
    for (var language in collaborators.translators) {
      if (currentIndex == index) {
        return buildTranslationHeader(context, language.languages);
      }
      currentIndex++;
      if (index - currentIndex < language.translators.length) {
        var player = language.translators[index - currentIndex];
        return buildTagAndPlatform(player.membershipId, player.membershipType);
      }
      currentIndex += language.translators.length;
    }
    return null;
  }

  StaggeredTile tileBuilder(int index) {
    switch (index) {
      case 0:
        return StaggeredTile.extent(1, 96);
      case 1:
      case 2:
        return StaggeredTile.extent(1, 120);
    }
    if (collaborators == null) return null;
    var titleTile = StaggeredTile.extent(1, 40);
    var usertag = StaggeredTile.extent(1, 72);
    var languageTile = StaggeredTile.extent(1, 40);

    int currentIndex = 3;
    if (currentIndex == index)
      return titleTile;
    currentIndex++;
    if (index - currentIndex < collaborators.supporters.length) {
      return usertag;
    }
    currentIndex += collaborators.supporters.length;
    if (currentIndex == index)
      return titleTile;
    currentIndex++;
    if (index - currentIndex < collaborators.developers.length) {
      return usertag;
    }
    currentIndex += collaborators.developers.length;
    if (currentIndex == index)
      return titleTile;
    currentIndex++;
    for (var language in collaborators.translators) {
      if (currentIndex == index) {
        return languageTile;
      }
      currentIndex++;
      if (index - currentIndex < language.translators.length) {
        return usertag;
      }
      currentIndex += language.translators.length;
    }
    return null;
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
          mainAxisAlignment: MainAxisAlignment.center,
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

  Widget buildTagAndPlatform(String membershipId, BungieMembershipType membershipType,
      [String link, Widget badge]) {
    return SupporterCharacterWidget(membershipId, membershipType, link, badge);
  }

  Widget buildContact(BuildContext context) {
    return Column(
      children: <Widget>[
        HeaderWidget(
            alignment: Alignment.centerLeft,
            child: TranslatedTextWidget(
              "Contact",
              uppercase: true,
              style: TextStyle(fontWeight: FontWeight.bold,),
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

  Widget buildSupport(BuildContext context) {
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
          child: isIOS
              ? buildRateButton(context)
              : Row(
                  children: <Widget>[
                    Expanded(child: buildRateButton(context)),
                    Container(
                      width: 4,
                    ),
                    Expanded(
                      child: RaisedButton(
                          padding: EdgeInsets.all(4),
                          color: Color.fromRGBO(249, 104, 84, 1),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
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
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
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
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
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
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
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

  Widget buildRateButton(BuildContext context) {
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
