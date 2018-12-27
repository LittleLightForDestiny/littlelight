import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_character_progression_component.dart';
import 'package:bungie_api/models/destiny_inventory_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie-api/enums/inventory-bucket-hash.enum.dart';
import 'package:little_light/widgets/inventory_tabs/character_tab_header.widget.dart';
import 'package:little_light/widgets/item_list/item_list.widget.dart';

class CharacterTabWidget extends StatefulWidget {
  final DestinyCharacterComponent character;
  final DestinyCharacterProgressionComponent progression;
  final DestinyInventoryComponent equipment;
  CharacterTabWidget(this.character, this.progression, this.equipment);
  @override
  CharacterTabWidgetState createState() => new CharacterTabWidgetState();
}

class CharacterTabWidgetState extends State<CharacterTabWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ItemListWidget(
        widget.equipment.items,
        padding: EdgeInsets.only(top: getListTopOffset(context)),
        bucketHashes: [
          InventoryBucket.subclass,
          InventoryBucket.kineticWeapons,
          InventoryBucket.energyWeapons,
          InventoryBucket.powerWeapons
        ],
      ),
      TabHeaderWidget(widget.character, widget.progression),
    ]);
  }

  double getListTopOffset(BuildContext context) {
    return kToolbarHeight + 2;
  }
}
