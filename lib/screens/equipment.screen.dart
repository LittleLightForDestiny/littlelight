import 'dart:async';

import 'package:bungie_api/enums/destiny_item_type_enum.dart';
import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/destiny_item_category.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/selected_page_persistence.dart';
import 'package:little_light/widgets/inventory_tabs/character_tab.widget.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/inventory_tabs/selected_items.widget.dart';
import 'package:little_light/widgets/inventory_tabs/tabs_character_menu.widget.dart';
import 'package:little_light/widgets/inventory_tabs/tabs_item_type_menu.widget.dart';
import 'package:little_light/widgets/inventory_tabs/vault_tab.widget.dart';

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
    with TickerProviderStateMixin {
  int currentGroup = DestinyItemType.Weapon;
  Map<int, double> scrollPositions = new Map();

  TabController charTabController;
  TabController typeTabController;
  StreamSubscription<NotificationEvent> subscription;

  get totalCharacterTabs =>
      characters?.length != null ? characters.length + 1 : 4;

  @override
  void initState() {
    SelectedPagePersistence.saveLatestScreen(SelectedPagePersistence.equipment);

    widget.itemTypes.forEach((type) {
      scrollPositions[type] = 0;
    });
    super.initState();

    subscription = widget.broadcaster.listen((event) {
      if(!mounted) return;
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
    typeTabController = typeTabController ?? TabController(
      initialIndex: 0,
      length: widget.itemTypes.length,
      vsync: this,
    );
    charTabController = charTabController ?? TabController(
      initialIndex: 0,
      length: totalCharacterTabs,
      vsync: this,
    );
    if (characters == null) {
      return Container();
    }
    EdgeInsets screenPadding = MediaQuery.of(context).padding;
    return Material(
      child: Stack(
        children: <Widget>[
          buildBackground(context),
          TabBarView(
              controller: typeTabController,
              children: buildItemTypeTabs(context, charTabController)),
          Positioned(
            top: screenPadding.top,
            width: kToolbarHeight,
            height: kToolbarHeight,
            child: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          TabsCharacterMenuWidget(characters, controller: charTabController),
          ItemTypeMenuWidget(widget.itemTypes, controller: typeTabController),
          InventoryNotificationWidget(key: Key('inventory_notification_widget')),
          Positioned(
          bottom: screenPadding.bottom,
          left: 0,
          right: 0,
          child:
          SelectedItemsWidget()),
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

  List<Widget> buildItemTypeTabs(
      BuildContext context, TabController controller) {
    return widget.itemTypes
        .map((type) => buildCharacterTabController(context, type, controller))
        .toList();
  }

  Widget buildCharacterTabController(
      BuildContext context, int group, TabController controller) {
    return TabBarView(controller: controller, children: getTabs(group));
  }

  List<Widget> getTabs(int group) {
    List<Widget> characterTabs = characters.map((character) {
      return CharacterTabWidget(character, group,
          key:Key("character_tab_${character.characterId}"),
          scrollPositions: scrollPositions);
    }).toList();
    characterTabs.add(VaultTabWidget(group));
    return characterTabs;
  }

  List<DestinyCharacterComponent> get characters {
    return widget.profile.getCharacters(CharacterOrder.lastPlayed);
  }
}
