import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_profile_response.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie-api/enums/item-category.enum.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/inventory_tabs/character_tab.widget.dart';
import 'package:little_light/widgets/inventory_tabs/tabs_character_menu.widget.dart';
import 'package:little_light/widgets/inventory_tabs/tabs_item_type_menu.widget.dart';
import 'package:little_light/widgets/inventory_tabs/vault_tab.widget.dart';

class EquipmentScreen extends StatefulWidget {
  final profile = new ProfileService();

  @override
  EquipmentScreenState createState() => new EquipmentScreenState();
}

class EquipmentScreenState extends State<EquipmentScreen> {
  int currentGroup = ItemCategory.weapon;
  int totalTabs = 4;
  DestinyProfileResponse profile;
  @override
  void initState() {
    profile = widget.profile.profile;
    totalTabs = characters?.length != null ? characters.length + 1 : 4;
    super.initState();
    widget.profile.startAutomaticUpdater(Duration(seconds: 30));
    buildVaultDefinitionsCache();
  }

  buildVaultDefinitionsCache() {}

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
                // Color.fromARGB(255, 73, 83, 93),
                // Color.fromARGB(255, 115, 115, 115),
                // Color.fromARGB(255, 73, 83, 93),
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
        ],
      ),
      length: totalTabs,
    );
  }

  List<Widget> getTabs() {
    List<Widget> characterTabs = characters.map((character) {
      return CharacterTabWidget(character.characterId, currentGroup);
    }).toList();
    characterTabs.add(VaultTabWidget(currentGroup));
    return characterTabs;
  }

  List<DestinyCharacterComponent> get characters {
    if (this.profile?.characters?.data == null) {
      return null;
    }
    return this.profile.characters.data.values.toList();
  }
}
