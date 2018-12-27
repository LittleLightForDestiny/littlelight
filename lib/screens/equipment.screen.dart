import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_profile_response.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/inventory_tabs/character_tab.widget.dart';
import 'package:little_light/widgets/inventory_tabs/tabs_menu.widget.dart';

class EquipmentScreen extends StatefulWidget {
  final profile = new ProfileService();
  // final BungieApiService api = new BungieApiService();

  @override
  EquipmentScreenState createState() => new EquipmentScreenState();
}

class EquipmentScreenState extends State<EquipmentScreen> {
  int totalTabs = 2;
  DestinyProfileResponse profile;
  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  loadProfile() async {
    DestinyProfileResponse profile = await widget.profile.fetchBasicProfile();
    setState(() {
      this.profile = profile;
      totalTabs = characters?.length ?? 2;
      print(totalTabs);
    });
  }

  @override
  Widget build(BuildContext context) {
    if(characters == null){
      return Container();
    }
    return DefaultTabController(
      initialIndex: 0,
      child: Stack(
        children: [
          Container(
            child: TabBarView(children: getTabs()),
          ),
          TabsMenuWidget(characters, 0)
        ],
      ),
      length: totalTabs,
    );
  }

  List<Widget> getTabs() {
    if (characters == null) {
      return [Container(), Container()];
    } else {
      List<Widget> characterTabs = characters.map((character) {
        return CharacterTabWidget(
            character,
            this.profile?.characterProgressions?.data[character.characterId] ?? null,
            this.profile?.characterEquipment?.data[character.characterId] ?? null);
      }).toList();
      return characterTabs;
    }
  }

  List<DestinyCharacterComponent> get characters {
    if (this.profile?.characters?.data == null) {
      return null;
    }
    return this.profile.characters.data.values.toList();
  }
}
