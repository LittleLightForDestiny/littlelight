//@dart=2.12

import 'dart:io';

import 'package:bungie_api/enums/bungie_membership_type.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:launch_review/launch_review.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/collaborators.dart';
import 'package:little_light/models/language_info.dart';
import 'package:little_light/services/language/language.consumer.dart';
import 'package:little_light/services/littlelight/littlelight_data.consumer.dart';
import 'package:little_light/services/storage/export.dart';
import 'package:little_light/widgets/about/supporter_character.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/widgets/multisection_scrollview/sliver_section.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

enum AboutScreenActionType { ExternalLink, Rate }

class AboutScreenAction {
  final Widget? iconWidget;
  final IconData? icon;
  final Color? color;
  final Widget label;
  final String? url;
  final AboutScreenActionType type;

  AboutScreenAction({
    this.icon,
    this.iconWidget,
    this.color,
    required this.label,
    this.url,
    this.type = AboutScreenActionType.ExternalLink,
  });
}

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with StorageConsumer, LanguageConsumer, LittleLightDataConsumer {
  String? packageVersion;
  String? appName;
  CollaboratorsResponse? collaborators;
  bool showDonationLinks = true;

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  void getInfo() async {
    final info = await PackageInfo.fromPlatform();
    packageVersion = info.version;
    appName = info.appName;
    if (Platform.isIOS) {
      final lastUpdated = globalStorage.lastUpdated;
      final now = DateTime.now();
      if (lastUpdated == null || now.difference(lastUpdated).inDays < 3) {
        showDonationLinks = false;
      }
    }
    setState(() {});
    collaborators = await littleLightData.getCollaborators();
    collaborators?.supporters?.shuffle();
    this.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            enableFeedback: false,
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          title: TranslatedTextWidget("About"),
        ),
        body: MultiSectionScrollView(
          _sections,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          padding: EdgeInsets.all(8) + MediaQuery.of(context).viewPadding.copyWith(top: 0),
        ));
  }

  List<SliverSection> get _sections {
    List<SliverSection> list = [
      appInfoSliver,
      headerSliver(TranslatedTextWidget("Contact", uppercase: true)),
      contactInfoSliver,
      spacerSliver,
    ];
    final isMobile = Platform.isAndroid || Platform.isIOS;
    if (isMobile || showDonationLinks) {
      list += [
        headerSliver(TranslatedTextWidget("Support Little Light", uppercase: true)),
        supportSliver,
        spacerSliver,
      ];
    }
    final supporters = collaborators?.supporters;
    if (supporters != null) {
      list += [
        headerSliver(TranslatedTextWidget("Supporters", uppercase: true)),
        collaboratorsSliver(supporters),
      ];
    }
    final developers = collaborators?.developers;
    if (developers != null) {
      list += [
        headerSliver(TranslatedTextWidget("Development", uppercase: true)),
        collaboratorsSliver(developers),
      ];
    }
    final curators = collaborators?.curators;
    if (curators != null) {
      list += [
        headerSliver(TranslatedTextWidget("Godroll Curators", uppercase: true)),
        collaboratorsSliver(curators),
      ];
    }
    final translators = collaborators?.translators;
    if (translators != null) {
      list += [
        headerSliver(TranslatedTextWidget("Translations", uppercase: true)),
      ];
      for (var language in translators) {
        list += [
          translationHeaderSliver(language),
          collaboratorsSliver(language.translators),
        ];
      }
    }

    return list;
  }

  SliverSection get appInfoSliver => SliverSection(
      itemHeight: 112,
      itemCount: 1,
      itemBuilder: (context, _) => Row(
            children: <Widget>[
              Container(
                  width: 96,
                  height: 96,
                  padding: EdgeInsets.only(right: 8),
                  child: Image.asset('assets/imgs/app_icon.png')),
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
          ));

  SliverSection headerSliver(Widget title) => SliverSection(
        itemHeight: 40,
        itemCount: 1,
        itemBuilder: (context, _) => HeaderWidget(child: title),
      );

  SliverSection get contactInfoSliver {
    final actions = [
      AboutScreenAction(
        icon: FontAwesomeIcons.twitter,
        label: Text("@LittleLightD2"),
        url: "http://www.twitter.com/littlelightD2",
      ),
      AboutScreenAction(
        icon: FontAwesomeIcons.discord,
        label: TranslatedTextWidget("Discord"),
        url: "https://discord.gg/ztdFGGz",
      ),
      AboutScreenAction(
        icon: FontAwesomeIcons.github,
        color: Theme.of(context).errorColor,
        label: TranslatedTextWidget("Issues"),
        url: "https://discord.gg/ztdFGGz",
      ),
    ];
    return SliverSection(
        itemHeight: 88,
        itemsPerRow: actions.length,
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return buildExternalLinkButton(context, action);
        });
  }

  SliverSection get supportSliver {
    bool isIOS = Platform.isIOS;
    bool isMobile = Platform.isAndroid || Platform.isIOS;
    final actions = [
      if (isMobile)
        AboutScreenAction(
            color: isIOS ? Color.fromARGB(255, 22, 147, 245) : Color.fromARGB(255, 49, 159, 185),
            icon: isIOS ? FontAwesomeIcons.appStoreIos : FontAwesomeIcons.googlePlay,
            label: TranslatedTextWidget("Rate it", uppercase: true),
            type: AboutScreenActionType.Rate),
      if (showDonationLinks)
        AboutScreenAction(
          color: Color.fromRGBO(249, 104, 84, 1),
          iconWidget: Image.asset("assets/imgs/patreon-icon.png"),
          label: TranslatedTextWidget(
            "Become a Patron",
            textAlign: TextAlign.center,
          ),
          url: 'https://www.patreon.com/littlelightD2',
        ),
      if (showDonationLinks)
        AboutScreenAction(
          color: Color.fromRGBO(26, 169, 222, 1),
          iconWidget: Image.asset("assets/imgs/ko-fi-icon.png"),
          label: TranslatedTextWidget(
            "Buy me a Coffee",
            textAlign: TextAlign.center,
          ),
          url: "https://ko-fi.com/littlelight",
        ),
    ];
    return SliverSection(
        itemHeight: 88,
        itemsPerRow: actions.length,
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return buildExternalLinkButton(context, action);
        });
  }

  SliverSection collaboratorsSliver(List<Collaborator> collaborators) {
    return SliverSection(
        itemHeight: 72,
        itemCount: collaborators.length,
        itemBuilder: (context, index) {
          final collaborator = collaborators[index];
          return buildTagAndPlatform(collaborator.membershipId, collaborator.membershipType);
        });
  }

  SliverSection translationHeaderSliver(TranslationLanguage language) {
    return SliverSection(
        itemHeight: 40,
        itemCount: 1,
        itemBuilder: (context, _) {
          return buildTranslationHeader(context, language);
        });
  }

  SliverSection get spacerSliver =>
      SliverSection(itemHeight: 48, itemCount: 1, itemBuilder: (context, index) => Container());

  buildTranslationHeader(BuildContext context, TranslationLanguage language) {
    final languages = language.languages;
    List<Widget> flags = languages.map((l) => flagIcon(l)).toList();
    Text languageNames = Text(languages
        .map((l) => languageService.languages.firstWhereOrNull((element) => element.code == l))
        .whereType<LanguageInfo>()
        .map((l) => l.name)
        .join("/"));
    return Container(
        color: Theme.of(context).colorScheme.secondaryContainer,
        padding: EdgeInsets.all(4),
        child: Row(
          children: flags + [Container(width: 4), languageNames],
        ));
  }

  Widget flagIcon(String code) {
    return Container(width: 24, height: 24, child: Image.asset("assets/imgs/flags/$code.png"));
  }

  Widget buildTagAndPlatform(String membershipId, BungieMembershipType membershipType, [String? link, Widget? badge]) {
    return SupporterCharacterWidget(membershipId, membershipType, link, badge);
  }

  Widget buildExternalLinkButton(BuildContext context, AboutScreenAction action) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(4),
          primary: action.color ?? LittleLightTheme.of(context).primaryLayers,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
            child: action.iconWidget ?? Container(width: 36, height: 36, child: Icon(action.icon, size: 32)),
          ),
          Container(
            height: 4,
          ),
          action.label
        ]),
        onPressed: () => doAction(action));
  }

  void doAction(AboutScreenAction action) {
    switch (action.type) {
      case AboutScreenActionType.ExternalLink:
        if (action.url != null) launch(action.url!);
        break;
      case AboutScreenActionType.Rate:
        LaunchReview.launch(androidAppId: 'me.markezine.luzinha', iOSAppId: '1373037254');
        return;
    }
  }
}
