import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/bungie_api/enums/item_category.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/inventory_tabs/character_tab.widget.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/inventory_tabs/tabs_character_menu.widget.dart';
import 'package:little_light/widgets/inventory_tabs/tabs_item_type_menu.widget.dart';
import 'package:little_light/widgets/inventory_tabs/vault_tab.widget.dart';

class EquipmentScreen extends StatefulWidget {
  final profile = new ProfileService();
  final manifest = new ManifestService();
  final List<int> itemTypes = [
    ItemCategory.weapon,
    ItemCategory.armor,
    ItemCategory.inventory
  ];

  @override
  EquipmentScreenState createState() => new EquipmentScreenState();
}

class EquipmentScreenState extends State<EquipmentScreen>
    with TickerProviderStateMixin {
  int currentGroup = ItemCategory.weapon;
  Map<int, double> scrollPositions = new Map();
  get totalCharacterTabs =>
      characters?.length != null ? characters.length + 1 : 4;

  @override
  void initState() {
    widget.itemTypes.forEach((type) {
      scrollPositions[type] = 0;
    });

    super.initState();
    widget.profile.startAutomaticUpdater(Duration(seconds: 30));
    cacheVaultDefinitions();
  }

  cacheVaultDefinitions() async {
    List<DestinyItemComponent> items = widget.profile.getProfileInventory();
    items = items
        .where((item) => item.bucketHash == InventoryBucket.general)
        .toList();
    for (int i = 0; i < items.length; i++) {
      DestinyItemComponent item = items[i];
      await widget.manifest.getItemDefinition(item.itemHash);
    }
  }

  @override
  void dispose() {
    widget.profile.stopAutomaticUpdater();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (characters == null) {
      return Container();
    }
    TabController typeTabController = TabController(
      initialIndex: 0,
      length: widget.itemTypes.length,
      vsync: this,
    );
    TabController charTabController = TabController(
      initialIndex: 0,
      length: totalCharacterTabs,
      vsync: this,
    );
    return Material(
      child: Stack(
        children: <Widget>[
          buildBackground(context),
          TabBarView(
              controller: typeTabController,
              children: buildItemTypeTabs(context, charTabController)),
          TabsCharacterMenuWidget(characters, controller: charTabController),
          ItemTypeMenuWidget(widget.itemTypes, controller: typeTabController),
          InventoryNotificationWidget(key: Key('inventory_notification_widget'))
        ],
      ),
    );
  }

  Widget buildBackground(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
      colors: [
        Color.fromARGB(255, 32, 53, 53),
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
      return CharacterTabWidget(character.characterId, group,
          scrollPositions: scrollPositions);
    }).toList();
    characterTabs.add(VaultTabWidget(group));
    return characterTabs;
  }

  List<DestinyCharacterComponent> get characters {
    return widget.profile.getCharacters(CharacterOrder.lastPlayed);
  }
}
