import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/selected_page_persistence.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/flutter/passive_tab_bar_view.dart';
import 'package:little_light/widgets/inventory_tabs/character_tab_header.widget.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/inventory_tabs/tabs_character_menu.widget.dart';
import 'package:little_light/widgets/progress_tabs/character_progress_list.widget.dart';
import 'package:little_light/widgets/progress_tabs/character_pursuits_list.widget.dart';
import 'package:little_light/widgets/progress_tabs/character_ranks_list.widget.dart';

class ProgressScreen extends StatefulWidget {
  final profile = new ProfileService();
  final manifest = new ManifestService();

  @override
  ProgressScreenState createState() => new ProgressScreenState();
}

class ProgressScreenState extends State<ProgressScreen>
    with TickerProviderStateMixin {
  Map<int, double> scrollPositions = new Map();

  TabController charTabController;
  TabController typeTabController;

  get totalCharacterTabs => characters?.length != null ? characters.length : 3;

  @override
  void initState() {
    SelectedPagePersistence.saveLatestScreen(SelectedPagePersistence.progress);
    charTabController = charTabController ??
        TabController(
          initialIndex: 0,
          length: totalCharacterTabs,
          vsync: this,
        );
    typeTabController = typeTabController ??
        TabController(
          initialIndex: 0,
          length: 3,
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
    var bottomOffset = screenPadding.bottom + kToolbarHeight;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          buildBackground(context),
          Positioned.fill(
            top: topOffset,
            bottom: bottomOffset,
            child: buildTypeTabView(context),
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
          TabsCharacterMenuWidget(
            characters,
            controller: charTabController,
            includeVault: false,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: buildTypeTabBar(context),
          ),
          InventoryNotificationWidget(
              key: Key('inventory_notification_widget')),
        ],
      ),
    );
  }

  Widget buildBackground(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
      colors: [
        Color.fromARGB(255, 80, 90, 100),
        Color.fromARGB(255, 100, 100, 115),
        Color.fromARGB(255, 32, 32, 73),
      ],
      begin: FractionalOffset(0, .5),
      end: FractionalOffset(.5, 0),
    )));
  }

  Widget buildTypeTabView(BuildContext context) {
    return TabBarView(
        controller: typeTabController, children: buildTypeTabs(context));
  }

  List<Widget> buildTypeTabs(BuildContext context) {
    return [0, 1, 2]
        .map((index) => buildCharacterTabView(context, index))
        .toList();
  }

  Widget buildCharacterHeaderTabView(BuildContext context) {
    return TabBarView(
        dragStartBehavior: DragStartBehavior.down,
        controller: charTabController,
        children: characters
            .map((character) => TabHeaderWidget(
                  character,
                  key: Key("${character.emblemHash}"),
                ))
            .toList());
  }

  Widget buildCharacterTabView(BuildContext context, int index) {
    return PassiveTabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: charTabController,
        children: buildCharacterTabs(context, index));
  }

  List<Widget> buildCharacterTabs(BuildContext context, int index) {
    List<Widget> characterTabs = characters.map((character) {
      return buildContentTab(context, character.characterId, index);
    }).toList();
    return characterTabs;
  }

  Widget buildTypeTabBar(BuildContext context) {
    var bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
        color: Colors.black,
        height: kToolbarHeight + bottomPadding,
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: TabBar(
            labelPadding: EdgeInsets.all(8),
            indicator: BoxDecoration(
                border: Border(top: BorderSide(width: 2, color: Colors.white))),
            controller: typeTabController,
            tabs: [
              TranslatedTextWidget("Milestones",
                  uppercase: true,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TranslatedTextWidget("Pursuits",
                  uppercase: true,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TranslatedTextWidget("Ranks",
                  uppercase: true,
                  style: TextStyle(fontWeight: FontWeight.bold))
            ]));
  }

  Widget buildContentTab(
      BuildContext context, String characterId, int tabIndex) {
    if (tabIndex == 0) {
      return CharacterProgressListWidget(characterId: characterId);
    }
    if(tabIndex == 1){
      return CharacterPursuitsListWidget(characterId: characterId);  
    }
    return CharacterRanksListWidget(characterId: characterId);
  }

  List<DestinyCharacterComponent> get characters {
    return widget.profile.getCharacters(CharacterOrder.lastPlayed);
  }
}
