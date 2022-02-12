// @dart=2.9

import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/widgets/common/animated_character_background.widget.dart';
import 'package:little_light/widgets/flutter/passive_tab_bar_view.dart';
import 'package:little_light/widgets/inventory_tabs/character_tab_header.widget.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/inventory_tabs/tabs_character_menu.widget.dart';
import 'package:little_light/widgets/vendors/vendors_list.widget.dart';

class VendorsScreen extends StatefulWidget {
  @override
  VendorsScreenState createState() => VendorsScreenState();
}

class VendorsScreenState extends State<VendorsScreen>
    with TickerProviderStateMixin, UserSettingsConsumer, ProfileConsumer {
  TabController charTabController;

  get totalCharacterTabs => characters?.length != null ? characters.length : 3;

  @override
  void initState() {
    super.initState();
    charTabController = charTabController ??
        TabController(
          initialIndex: 0,
          length: totalCharacterTabs,
          vsync: this,
        );
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
    return Scaffold(
      body: Stack(
        children: <Widget>[
          buildBackground(context),
          Positioned.fill(
            child: buildCharacterTabView(context),
          ),
          Positioned(top: 0, left: 0, right: 0, height: topOffset + 16, child: buildCharacterHeaderTabView(context)),
          Positioned(
            top: paddingTop,
            width: kToolbarHeight,
            height: kToolbarHeight,
            child: IconButton(
              enableFeedback: false,
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
          InventoryNotificationWidget(barHeight: 0, key: Key('inventory_notification_widget')),
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
    return TabBarView(controller: charTabController, children: buildCharacterTabs(context));
  }

  List<Widget> buildCharacterTabs(BuildContext context) {
    List<Widget> characterTabs =
        characters.map((character) => VendorsListWidget(characterId: character.characterId)).toList();
    return characterTabs;
  }

  buildCharacterMenu(BuildContext context) {
    return TabsCharacterMenuWidget(
      characters,
      controller: charTabController,
      includeVault: false,
    );
  }

  List<DestinyCharacterComponent> get characters {
    return profile.getCharacters(userSettings.characterOrdering);
  }
}
