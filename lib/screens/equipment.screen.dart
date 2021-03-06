import 'dart:async';

import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/screens/search.screen.dart';
import 'package:little_light/services/bungie_api/enums/destiny_item_category.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';
import 'package:little_light/utils/item_filters/pseudo_item_type_filter.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/utils/selected_page_persistence.dart';
import 'package:little_light/widgets/common/animated_character_background.widget.dart';
import 'package:little_light/widgets/common/refresh_button.widget.dart';
import 'package:little_light/widgets/flutter/passive_tab_bar_view.dart';
import 'package:little_light/widgets/inventory_tabs/character_tab.widget.dart';
import 'package:little_light/widgets/inventory_tabs/character_tab_header.widget.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/inventory_tabs/large_screen_equipment_list.widget.dart';
import 'package:little_light/widgets/inventory_tabs/large_screen_vault_list.widget.dart';
import 'package:little_light/widgets/inventory_tabs/selected_items.widget.dart';
import 'package:little_light/widgets/inventory_tabs/tabs_character_menu.widget.dart';
import 'package:little_light/widgets/inventory_tabs/tabs_item_type_menu.widget.dart';
import 'package:little_light/widgets/inventory_tabs/vault_tab.widget.dart';
import 'package:little_light/widgets/inventory_tabs/vault_tab_header.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';

class EquipmentScreen extends StatefulWidget {
  final profile = new ProfileService();
  final manifest = new ManifestService();
  final NotificationService broadcaster = new NotificationService();

  final List<int> itemTypes = [
    DestinyItemCategory.Weapon,
    DestinyItemCategory.Armor,
    DestinyItemCategory.Inventory
  ];

  @override
  EquipmentScreenState createState() => new EquipmentScreenState();
}

class EquipmentScreenState extends State<EquipmentScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  int currentGroup = DestinyItemCategory.Weapon;
  Map<int, double> scrollPositions = new Map();

  TabController charTabController;
  TabController typeTabController;
  StreamSubscription<NotificationEvent> subscription;

  get totalCharacterTabs => (characters?.length ?? 0) + 1;

  @override
  void initState() {
    super.initState();
    ProfileService().updateComponents = ProfileComponentGroups.basicProfile;
    SelectedPagePersistence.saveLatestScreen(SelectedPagePersistence.equipment);

    typeTabController = typeTabController ??
        TabController(
          initialIndex: 0,
          length: widget.itemTypes.length,
          vsync: this,
        );
    charTabController = charTabController ??
        TabController(
          initialIndex: 0,
          length: totalCharacterTabs,
          vsync: this,
        );

    widget.itemTypes.forEach((type) {
      scrollPositions[type] = 0;
    });

    subscription = widget.broadcaster.listen((event) {
      if (!mounted) return;
      if (event.type == NotificationType.receivedUpdate) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    var query = MediaQueryHelper(context);
    if (query.isLandscape) {
      return buildTablet(context);
    }

    return buildPhone(context);
  }

  Widget buildTablet(BuildContext context) {
    EdgeInsets screenPadding = MediaQuery.of(context).padding;
    return Material(
      child: Stack(
        children: <Widget>[
          buildBackground(context),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: buildTabletCharacterTabView(context)),
          Positioned(
            top: screenPadding.top,
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
          InventoryNotificationWidget(
              notificationMargin: EdgeInsets.only(right: 44),
              barHeight: 0,
              key: Key('inventory_notification_widget')),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.blueGrey.shade900,
                  borderRadius: BorderRadius.circular(18)),
              width: 36,
              height: 36,
              child: RefreshButtonWidget(),
            ),
          ),
          Positioned(
              bottom: screenPadding.bottom,
              left: 0,
              right: 0,
              child: SelectedItemsWidget()),
        ],
      ),
    );
  }

  Widget buildPhone(BuildContext context) {
    EdgeInsets screenPadding = MediaQuery.of(context).padding;
    var topOffset = screenPadding.top + kToolbarHeight;
    return Material(
      child: Stack(
        children: <Widget>[
          buildBackground(context),
          buildItemTypeTabBarView(context),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topOffset + 16,
              child: buildCharacterHeaderTabView(context)),
          Positioned(
            top: screenPadding.top,
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
          ItemTypeMenuWidget(widget.itemTypes, controller: typeTabController),
          InventoryNotificationWidget(
              key: Key('inventory_notification_widget')),
          Positioned(
              bottom: screenPadding.bottom,
              left: 0,
              right: 0,
              child: SelectedItemsWidget()),
        ],
      ),
    );
  }

  Widget buildCharacterHeaderTabView(BuildContext context) {
    var headers = characters
        ?.map((character) => TabHeaderWidget(
              character,
              key: Key("${character?.emblemHash}_${character?.characterId}"),
            ))
        ?.toList();
    headers?.add(VaultTabHeaderWidget());

    if (charTabController?.length != headers?.length) {
      charTabController?.dispose();
      charTabController = TabController(length: headers?.length, vsync: this);
    }

    return TabBarView(controller: charTabController, children: headers ?? []);
  }

  Widget buildTabletCharacterTabView(BuildContext context) {
    EdgeInsets screenPadding = MediaQuery.of(context).padding;
    var topOffset = screenPadding.top + kToolbarHeight;
    var pages = characters
        ?.map((character) => Stack(children: [
              Positioned.fill(
                  child: LargeScreenEquipmentListWidget(
                key: Key("character_tab${character.characterId}"),
                character: character,
              )),
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: topOffset + 16,
                  child: TabHeaderWidget(
                    character,
                    key: Key("${character.emblemHash}"),
                  ))
            ]))
        ?.toList();
    pages?.add(Stack(children: [
      Positioned.fill(
          child: LargeScreenVaultListWidget(
        key: Key("vault_tab"),
      )),
      Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: topOffset + 16,
          child: VaultTabHeaderWidget())
    ]));
    return TabBarView(controller: charTabController, children: pages ?? []);
  }

  Widget buildBackground(BuildContext context) {
    if (characters == null) return Container();
    return AnimatedCharacterBackgroundWidget(
      tabController: charTabController,
    );
  }

  Widget buildItemTypeTabBarView(BuildContext context) {
    if (characters == null) return Container();
    return TabBarView(
        controller: typeTabController, children: buildItemTypeTabs(context));
  }

  List<Widget> buildItemTypeTabs(BuildContext context) {
    return widget.itemTypes
        .map((type) => buildCharacterTabBarView(context, type))
        .toList();
  }

  Widget buildCharacterTabBarView(BuildContext context, int group) {
    if (characters == null) return Container();
    return PassiveTabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: charTabController,
        children: buildCharacterTabs(group));
  }

  List<Widget> buildCharacterTabs(int group) {
    List<Widget> characterTabs = characters?.map((character) {
      return CharacterTabWidget(character, group,
          key: Key("character_tab_${character.characterId}"),
          scrollPositions: scrollPositions);
    })?.toList();
    characterTabs?.add(VaultTabWidget(group));
    return characterTabs ?? [];
  }

  List<DestinyCharacterComponent> get characters {
    return widget.profile
        .getCharacters(UserSettingsService().characterOrdering);
  }

  buildCharacterMenu(BuildContext context) {
    if (characters == null) return Container();
    return Row(children: [
      IconButton(
          enableFeedback: false,
          icon: Icon(FontAwesomeIcons.search, color: Colors.white),
          onPressed: () {
            Iterable<PseudoItemType> available = [
              PseudoItemType.Weapons,
              PseudoItemType.Armor,
              PseudoItemType.Cosmetics,
              PseudoItemType.Consumables
            ];
            Iterable<PseudoItemType> selected = [
              PseudoItemType.Weapons,
              PseudoItemType.Armor,
              PseudoItemType.Cosmetics,
              PseudoItemType.Consumables
            ];
            if (typeTabController?.index == 0) {
              selected = [PseudoItemType.Weapons];
            }
            if (typeTabController?.index == 1) {
              selected = [PseudoItemType.Armor];
            }
            if (typeTabController?.index == 2) {
              selected = [PseudoItemType.Cosmetics, PseudoItemType.Consumables];
            }
            var query = MediaQueryHelper(context);
            if (query.isLandscape) {
              selected = [
                PseudoItemType.Weapons,
                PseudoItemType.Armor,
                PseudoItemType.Cosmetics
              ];
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(
                  controller: SearchController.withDefaultFilters(
                    firstRunFilters: [
                      PseudoItemTypeFilter(available, available)
                    ],
                    preFilters: [
                      PseudoItemTypeFilter(available, selected),
                    ],
                  ),
                ),
              ),
            );
          }),
      TabsCharacterMenuWidget(characters, controller: charTabController)
    ]);
  }

  @override
  bool get wantKeepAlive => true;
}
