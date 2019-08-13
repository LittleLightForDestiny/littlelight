import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/screens/search.screen.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';

import 'package:little_light/services/user_settings/user_settings.service.dart';
import 'package:little_light/widgets/common/animated_character_background.widget.dart';
import 'package:little_light/widgets/flutter/passive_tab_bar_view.dart';
import 'package:little_light/widgets/inventory_tabs/character_tab_header.widget.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/inventory_tabs/tabs_character_menu.widget.dart';
import 'package:little_light/widgets/vendors/vendors_list.widget.dart';

class VendorsScreen extends StatefulWidget {
  final profile = ProfileService();
  final manifest = ManifestService();

  @override
  VendorsScreenState createState() => VendorsScreenState();
}

class VendorsScreenState extends State<VendorsScreen>
    with TickerProviderStateMixin {
  TabController charTabController;

  get totalCharacterTabs => characters?.length != null ? characters.length : 3;

  @override
  void initState() {
    charTabController = charTabController ??
        TabController(
          initialIndex: 0,
          length: totalCharacterTabs,
          vsync: this,
        );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (characters == null) {
      return Container();
    }
    double paddingTop = MediaQuery.of(context).padding.top;
    var screenPadding = MediaQuery.of(context).padding;
    var topOffset = screenPadding.top + kToolbarHeight;
    var bottomOffset = screenPadding.bottom;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          buildBackground(context),
          Positioned.fill(
            top: topOffset + 8,
            bottom: bottomOffset,
            child: buildCharacterTabView(context),
          ),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topOffset + 16,
              child: buildCharacterHeaderTabView(context)),
          Positioned(
            top: paddingTop,
            width: kToolbarHeight,
            height: kToolbarHeight,
            child: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight - 52,
              right: 8,
              child: buildCharacterMenu(context)),
          InventoryNotificationWidget(
              barHeight: 0, key: Key('inventory_notification_widget')),
        ],
      ),
    );
  }

  Widget buildBackground(BuildContext context) {
    return AnimatedCharacterBackgroundWidget(tabController: charTabController);
  }

  Widget buildCharacterHeaderTabView(BuildContext context) {
    return PassiveTabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: charTabController,
        children: characters
            .map((character) => TabHeaderWidget(
                  character,
                  key: Key("${character.emblemHash}"),
                ))
            .toList());
  }

  Widget buildCharacterTabView(BuildContext context) {
    return TabBarView(
        controller: charTabController, children: buildCharacterTabs(context));
  }

  List<Widget> buildCharacterTabs(BuildContext context) {
    List<Widget> characterTabs = characters
        .map((character) =>
            VendorsListWidget(characterId: character.characterId))
        .toList();
    return characterTabs;
  }

  buildCharacterMenu(BuildContext context) {
    return Row(children: [
      IconButton(
          icon: Icon(FontAwesomeIcons.search, color: Colors.white),
          onPressed: () {
            var char = characters[charTabController.index];
            SearchTabData searchData =
                SearchTabData.pursuits(char?.characterId);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(
                  tabData: searchData,
                ),
              ),
            );
          }),
      TabsCharacterMenuWidget(
        characters,
        controller: charTabController,
        includeVault: false,
      )
    ]);
  }

  List<DestinyCharacterComponent> get characters {
    return widget.profile
        .getCharacters(UserSettingsService().characterOrdering);
  }
}
