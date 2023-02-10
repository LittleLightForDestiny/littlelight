// @dart=2.9

import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/destiny_item_category.enum.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/widgets/inventory_tabs/character_tab.widget.dart';
import 'package:little_light/widgets/item_list/vault_item_list.widget.dart';

class VaultTabWidget extends CharacterTabWidget {
  @override
  final int currentGroup;
  const VaultTabWidget(this.currentGroup, {EdgeInsets padding})
      : super(
          null,
          currentGroup,
          padding: padding,
        );

  @override
  VaultTabWidgetState createState() => VaultTabWidgetState();
}

class VaultTabWidgetState extends CharacterTabWidgetState {

  @override
  Widget build(BuildContext context) {
    return VaultItemListWidget(
      key: Key("${widget.currentGroup}_vault"),
      padding: widget.padding,
      bucketHashes: bucketHashes,
    );
  }

  @override
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
        return [InventoryBucket.kineticWeapons, InventoryBucket.energyWeapons, InventoryBucket.powerWeapons];
    }
    return [
      InventoryBucket.ghost,
      InventoryBucket.vehicle,
      InventoryBucket.ships,
      InventoryBucket.consumables,
      InventoryBucket.modifications,
    ];
  }
}
