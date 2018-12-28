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
    profile = widget.profile.profile;
    totalTabs = characters?.length ?? 2;
    super.initState();
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
              )
            ),
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
        return CharacterTabWidget(character.characterId);
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
