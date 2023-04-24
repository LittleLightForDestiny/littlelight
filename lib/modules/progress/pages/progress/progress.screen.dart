// @dart=2.9

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/services/analytics/analytics.consumer.dart';
import 'package:little_light/services/user_settings/little_light_persistent_page.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/shared/widgets/selection/selected_items.widget.dart';
import 'package:little_light/utils/item_filters/pseudo_item_type_filter.dart';
import 'package:little_light/widgets/common/animated_character_background.widget.dart';
import 'package:little_light/widgets/common/refresh_button.widget.dart';
import 'package:little_light/widgets/flutter/passive_tab_bar_view.dart';
import 'package:little_light/widgets/inventory_tabs/character_tab_header.widget.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/inventory_tabs/tabs_character_menu.widget.dart';
import 'package:little_light/widgets/progress_tabs/character_pursuits_list.widget.dart';
import 'package:little_light/widgets/progress_tabs/character_ranks_list.widget.dart';

class ProgressScreen extends StatefulWidget {
  @override
  ProgressScreenState createState() => ProgressScreenState();
}

const _page = LittleLightPersistentPage.Progress;

class ProgressScreenState extends State<ProgressScreen>
    with TickerProviderStateMixin, UserSettingsConsumer, AnalyticsConsumer, ProfileConsumer {
  TabController charTabController;
  TabController typeTabController;

  get totalCharacterTabs => characters?.length != null ? characters.length : 3;

  @override
  void initState() {
    super.initState();

    userSettings.startingPage = _page;
    analytics.registerPageOpen(_page);

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
          Positioned(top: 0, left: 0, right: 0, height: topOffset + 16, child: buildCharacterHeaderTabView(context)),
          Positioned(
            top: paddingTop,
            width: kToolbarHeight,
            height: kToolbarHeight,
            child: IconButton(
              enableFeedback: false,
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight - 52,
              right: 8,
              child: buildCharacterMenu(context)),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: buildTypeTabBar(context),
          ),
          const InventoryNotificationWidget(key: Key('inventory_notification_widget')),
          Positioned(bottom: screenPadding.bottom, left: 0, right: 0, child: SelectedItemsWidget()),
        ],
      ),
    );
  }

  Widget buildBackground(BuildContext context) {
    return AnimatedCharacterBackgroundWidget(tabController: charTabController);
  }

  Widget buildTypeTabView(BuildContext context) {
    return TabBarView(controller: typeTabController, children: buildTypeTabs(context));
  }

  List<Widget> buildTypeTabs(BuildContext context) {
    return [0, 1, 2].map((index) => buildCharacterTabView(context, index)).toList();
  }

  Widget buildCharacterHeaderTabView(BuildContext context) {
    return TabBarView(
        dragStartBehavior: DragStartBehavior.down,
        controller: charTabController,
        children: characters
            .map((character) => TabHeaderWidget(
                  character,
                  key: Key("${character.character.emblemHash}_${character.characterId}"),
                ))
            .toList());
  }

  Widget buildCharacterTabView(BuildContext context, int index) {
    return PassiveTabBarView(
        physics: const NeverScrollableScrollPhysics(),
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
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
              child: TabBar(
                  labelPadding: const EdgeInsets.all(4),
                  indicator: BoxDecoration(
                      border: Border(top: BorderSide(width: 2, color: Theme.of(context).colorScheme.onSurface))),
                  controller: typeTabController,
                  tabs: [
                Text("Milestones".translate(context).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text("Pursuits".translate(context).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text("Ranks".translate(context).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))
              ])),
          const SizedBox(width: 40, child: RefreshButtonWidget())
        ]));
  }

  Widget buildContentTab(BuildContext context, String characterId, int tabIndex) {
    if (tabIndex == 1) {
      return CharacterPursuitsListWidget(characterId: characterId);
    }
    return CharacterRanksListWidget(characterId: characterId);
  }

  buildCharacterMenu(BuildContext context) {
    return Row(children: [
      IconButton(
          enableFeedback: false,
          icon: Icon(FontAwesomeIcons.search, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            // var char = characters[charTabController.index];
            var types = [PseudoItemType.Pursuits];
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => SearchScreen(
            //         controller: SearchController.withDefaultFilters(context,
            //             firstRunFilters: [PseudoItemTypeFilter(types, types)],
            //             preFilters: [
            //               ItemOwnerFilter({char.characterId}),
            //               PseudoItemTypeFilter(types, types),
            //             ],
            //             defaultSorting: userSettings.pursuitOrdering,
            //             availableSorters: ItemSortParameter.availablePursuitSorters),
            //       ),
            //     ));
          }),
      TabsCharacterMenuWidget(
        characters,
        controller: charTabController,
        includeVault: false,
      )
    ]);
  }

  List<DestinyCharacterInfo> get characters {
    return profile.characters;
  }
}
