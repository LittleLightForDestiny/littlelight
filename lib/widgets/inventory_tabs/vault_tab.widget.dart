import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/destiny_item_category.enum.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/widgets/inventory_tabs/character_tab.widget.dart';
import 'package:little_light/widgets/item_list/vault_item_list.widget.dart';

class VaultTabWidget extends CharacterTabWidget {
  final int currentGroup;
  VaultTabWidget(this.currentGroup) : super(null, currentGroup);

  @override
  VaultTabWidgetState createState() => new VaultTabWidgetState();
}

class VaultTabWidgetState extends CharacterTabWidgetState {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return VaultItemListWidget(
      key: Key("${widget.currentGroup}_vault"),
      padding:
          EdgeInsets.only(top: getListTopOffset(context), left: 2, right: 2),
      bucketHashes: bucketHashes,
    );
  }

  List<int> get bucketHashes {
    switch (widget.currentGroup) {
      case DestinyItemCategory.Armor:
        return [
          InventoryBucket.helmet,
          InventoryBucket.gauntlets,
          InventoryBucket.chestArmor,
          InventoryBucket.legArmor,
          InventoryBucket.classArmor,
        ];
      case DestinyItemCategory.Weapon:
        return [
          InventoryBucket.kineticWeapons,
          InventoryBucket.energyWeapons,
          InventoryBucket.powerWeapons
        ];
    }
    return [
      InventoryBucket.ghost,
      InventoryBucket.vehicle,
      InventoryBucket.ships,
      InventoryBucket.consumables,
      InventoryBucket.modifications,
      InventoryBucket.shaders,
    ];
  }
}
