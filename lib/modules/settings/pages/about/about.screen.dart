import 'dart:io';

import 'package:bungie_api/enums/bungie_membership_type.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:little_light/core/blocs/language/language.bloc.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/collaborators.dart';
import 'package:little_light/models/language_info.dart';
import 'package:little_light/services/littlelight/littlelight_data.consumer.dart';
import 'package:little_light/services/storage/export.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sliver_section.dart';
import 'package:little_light/widgets/about/supporter_character.widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

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

class _AboutScreenState extends State<AboutScreen> with StorageConsumer, LittleLightDataConsumer {
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
    if (Platform.isIOS || Platform.isMacOS) {
      final lastUpdated = globalStorage.lastUpdated;
      final now = DateTime.now();
      if (lastUpdated == null || now.difference(lastUpdated).inDays < 3) {
        showDonationLinks = false;
      }
    }
    setState(() {});
    collaborators = await littleLightData.getCollaborators();
    collaborators?.supporters?.shuffle();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          enableFeedback: false,
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text("About".translate(context)),
      ),
      body: MultiSectionScrollView(
        _sections,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        padding: const EdgeInsets.all(8) + MediaQuery.of(context).viewPadding.copyWith(top: 0),
      ),
    );
  }

  List<ScrollableSection> get _sections {
    List<ScrollableSection> list = [
      appInfoSliver,
      headerSliver(Text("Contact".translate(context).toUpperCase())),
      contactInfoSliver,
      spacerSliver,
    ];
    final isMobile = Platform.isAndroid || Platform.isIOS;
    if (isMobile || showDonationLinks) {
      list += [
        headerSliver(Text("Support Little Light".translate(context).toUpperCase())),
        supportSliver,
        spacerSliver,
      ];
    }
    final supporters = collaborators?.supporters;
    if (supporters != null) {
      list += [headerSliver(Text("Supporters".translate(context).toUpperCase())), collaboratorsSliver(supporters)];
    }
    final developers = collaborators?.developers;
    if (developers != null) {
      list += [headerSliver(Text("Development".translate(context).toUpperCase())), collaboratorsSliver(developers)];
    }
    final curators = collaborators?.curators;
    if (curators != null) {
      list += [headerSliver(Text("Godroll Curators".translate(context).toUpperCase())), collaboratorsSliver(curators)];
    }
    final translators = collaborators?.translators;
    if (translators != null) {
      list += [headerSliver(Text("Translations".translate(context).toUpperCase()))];
      for (var language in translators) {
        list += [translationHeaderSliver(language), collaboratorsSliver(language.translators)];
      }
    }

    return list;
  }

  ScrollableSection get appInfoSliver => FixedHeightScrollSection(
    112.0,
    itemCount: 1,
    itemBuilder:
        (context, _) => Row(
          children: <Widget>[
            Container(
              width: 96,
              height: 96,
              padding: const EdgeInsets.only(right: 8),
              child: Image.asset('assets/imgs/app_icon.png'),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("$appName v$packageVersion", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
  );

  ScrollableSection headerSliver(Widget title) =>
      FixedHeightScrollSection(40.0, itemCount: 1, itemBuilder: (context, _) => HeaderWidget(child: title));

  ScrollableSection get contactInfoSliver {
    final actions = [
      AboutScreenAction(
        icon: FontAwesomeIcons.bluesky,
        label: const Text("Bluesky"),
        url: "https://bsky.app/profile/littlelight.club",
      ),
      AboutScreenAction(
        icon: FontAwesomeIcons.discord,
        label: Text("Discord".translate(context)),
        url: "https://discord.gg/ztdFGGz",
      ),
      AboutScreenAction(
        icon: FontAwesomeIcons.github,
        color: context.theme.errorLayers,
        label: Text("Issues".translate(context)),
        url: "https://discord.gg/ztdFGGz",
      ),
    ];
    return FixedHeightScrollSection(
      88.0,
      itemsPerRow: actions.length,
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return buildExternalLinkButton(context, action);
      },
    );
  }

  ScrollableSection get supportSliver {
    bool isIOS = Platform.isIOS;
    bool isMobile = Platform.isAndroid || Platform.isIOS;
    final actions = [
      if (isMobile)
        AboutScreenAction(
          color: isIOS ? const Color.fromARGB(255, 22, 147, 245) : const Color.fromARGB(255, 49, 159, 185),
          icon: isIOS ? FontAwesomeIcons.appStoreIos : FontAwesomeIcons.googlePlay,
          label: Text("Rate it".translate(context).toUpperCase()),
          type: AboutScreenActionType.Rate,
        ),
      if (showDonationLinks)
        AboutScreenAction(
          color: const Color.fromRGBO(249, 104, 84, 1),
          iconWidget: Image.asset("assets/imgs/patreon-icon.png"),
          label: Text("Become a Patron".translate(context), textAlign: TextAlign.center),
          url: 'https://www.patreon.com/littlelightD2',
        ),
      if (showDonationLinks)
        AboutScreenAction(
          color: const Color.fromRGBO(26, 169, 222, 1),
          iconWidget: Image.asset("assets/imgs/ko-fi-icon.png"),
          label: Text("Buy me a Coffee".translate(context), textAlign: TextAlign.center),
          url: "https://ko-fi.com/littlelight",
        ),
    ];
    return FixedHeightScrollSection(
      88.0,
      itemsPerRow: actions.length,
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return buildExternalLinkButton(context, action);
      },
    );
  }

  ScrollableSection collaboratorsSliver(List<Collaborator> collaborators) {
    return FixedHeightScrollSection(
      72.0,
      itemCount: collaborators.length,
      itemBuilder: (context, index) {
        final collaborator = collaborators[index];
        return buildTagAndPlatform(collaborator.membershipId, collaborator.membershipType);
      },
    );
  }

  ScrollableSection translationHeaderSliver(TranslationLanguage language) {
    return FixedHeightScrollSection(
      40.0,
      itemCount: 1,
      itemBuilder: (context, _) {
        return buildTranslationHeader(context, language);
      },
    );
  }

  ScrollableSection get spacerSliver =>
      FixedHeightScrollSection(48, itemCount: 1, itemBuilder: (context, index) => Container());

  Widget buildTranslationHeader(BuildContext context, TranslationLanguage language) {
    final languages = language.languages;
    List<Widget> flags = languages.map((l) => flagIcon(l)).toList();
    Text languageNames = Text(
      languages
          .map((l) => context.watch<LanguageBloc>().languages.firstWhereOrNull((element) => element.code == l))
          .whereType<LanguageInfo>()
          .map((l) => l.name)
          .join("/"),
    );
    return Container(
      color: context.theme.secondarySurfaceLayers.layer0,
      padding: const EdgeInsets.all(4),
      child: Row(children: flags + [Container(width: 4), languageNames]),
    );
  }

  Widget flagIcon(String code) {
    return SizedBox(width: 24, height: 24, child: Image.asset("assets/imgs/flags/$code.png"));
  }

  Widget buildTagAndPlatform(String membershipId, BungieMembershipType membershipType, [String? link, Widget? badge]) {
    return SupporterCharacterWidget(membershipId, membershipType, link, badge);
  }

  Widget buildExternalLinkButton(BuildContext context, AboutScreenAction action) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(4),
        backgroundColor: action.color ?? context.theme.primaryLayers,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: action.iconWidget ?? SizedBox(width: 36, height: 36, child: Icon(action.icon, size: 32))),
          Container(height: 4),
          action.label,
        ],
      ),
      onPressed: () => doAction(action),
    );
  }

  void doAction(AboutScreenAction action) {
    switch (action.type) {
      case AboutScreenActionType.ExternalLink:
        final url = action.url;
        if (url != null) launchUrlString(url);
        break;
      case AboutScreenActionType.Rate:
        InAppReview.instance.openStoreListing(appStoreId: '1373037254', microsoftStoreId: "9PMG9ZQ41K95");
        return;
    }
  }
}
