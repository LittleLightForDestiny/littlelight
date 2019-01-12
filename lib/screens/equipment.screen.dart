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

  @override
  EquipmentScreenState createState() => new EquipmentScreenState();
}

class EquipmentScreenState extends State<EquipmentScreen> {
  int currentGroup = ItemCategory.weapon;
  int totalTabs = 4;
  Map<int,double> scrollPositions = new Map();

  @override
  void initState() {
    totalTabs = characters?.length != null ? characters.length + 1 : 4;
    scrollPositions[ItemCategory.weapon] = 0;
    scrollPositions[ItemCategory.armor] = 0;
    scrollPositions[ItemCategory.inventory] = 0;
        
    super.initState();
    widget.profile.startAutomaticUpdater(Duration(seconds: 30));
    cacheVaultDefinitions();
  }

  cacheVaultDefinitions() async{
    List<DestinyItemComponent> items = widget.profile.getProfileInventory();
    items = items.where((item)=>item.bucketHash == InventoryBucket.general).toList();
    for(int i=0; i < items.length; i++){
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
    return DefaultTabController(
      initialIndex: 0,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 32, 53, 53),
                Color.fromARGB(255, 100, 100, 115),
                Color.fromARGB(255, 32, 32, 73),
              ],
              begin: FractionalOffset(0, .5),
              end: FractionalOffset(.5, 0),
            )),
            child: TabBarView(children: getTabs()),
          ),
          TabsCharacterMenuWidget(characters, 0),
          ItemTypeMenuWidget(
            currentGroup,
            onSelect: (hash) {
              setState(() {
                this.currentGroup = hash;
              });
            },
          ),
          InventoryNotificationWidget(key:Key('inventory_notification_widget'))
        ],
      ),
      length: totalTabs,
    );
  }

  List<Widget> getTabs() {
    List<Widget> characterTabs = characters.map((character) {
      return CharacterTabWidget(character.characterId, currentGroup, scrollPositions:scrollPositions);
    }).toList();
    characterTabs.add(VaultTabWidget(currentGroup));
    return characterTabs;
  }

  List<DestinyCharacterComponent> get characters {
    return widget.profile.getCharacters(CharacterOrder.lastPlayed);
  }
}
