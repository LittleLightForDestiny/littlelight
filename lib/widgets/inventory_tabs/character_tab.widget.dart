import 'package:flutter/material.dart';
import 'package:little_light/services/bungie-api/enums/inventory-bucket-hash.enum.dart';
import 'package:little_light/widgets/inventory_tabs/character_tab_header.widget.dart';
import 'package:little_light/widgets/item_list/item_list.widget.dart';

class CharacterTabWidget extends StatefulWidget {
  final String characterId;
  CharacterTabWidget(this.characterId);
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
        padding: EdgeInsets.only(top: getListTopOffset(context), left:2, right:2),
        characterId: widget.characterId,
        bucketHashes: [
          InventoryBucket.subclass,
          InventoryBucket.kineticWeapons,
          InventoryBucket.energyWeapons,
          InventoryBucket.powerWeapons
        ],
      ),
      TabHeaderWidget(widget.characterId),
    ]);
  }

  double getListTopOffset(BuildContext context) {
    return kToolbarHeight + 2;
  }
}
