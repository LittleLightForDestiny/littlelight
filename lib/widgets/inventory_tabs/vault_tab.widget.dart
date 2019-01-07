import 'package:flutter/material.dart';
import 'package:little_light/services/bungie-api/enums/inventory-bucket-hash.enum.dart';
import 'package:little_light/services/bungie-api/enums/item-category.enum.dart';
import 'package:little_light/widgets/inventory_tabs/character_tab.widget.dart';
import 'package:little_light/widgets/inventory_tabs/vault_tab_header.widget.dart';
import 'package:little_light/widgets/item_list/vault_item_list.widget.dart';

class VaultTabWidget extends CharacterTabWidget {
  final int currentGroup;
  VaultTabWidget(this.currentGroup):super(null, currentGroup);
  
  @override
  VaultTabWidgetState createState() => new VaultTabWidgetState();
}

class VaultTabWidgetState extends CharacterTabWidgetState{
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      VaultItemListWidget(
        key: Key("${widget.currentGroup}_vault"),
        padding:
            EdgeInsets.only(top: getListTopOffset(context), left: 2, right: 2),
        bucketHashes: bucketHashes,
      ),
      VaultTabHeaderWidget(),
    ]);
  }

  List<int> get bucketHashes {
    switch (widget.currentGroup) {
      case ItemCategory.armor:
        return [
          InventoryBucket.helmet,
          InventoryBucket.gauntlets,
          InventoryBucket.chestArmor,
          InventoryBucket.legArmor,
          InventoryBucket.classArmor,
        ];
      case ItemCategory.inventory:
        return [
          InventoryBucket.ghost,
          InventoryBucket.vehicle,
          InventoryBucket.ships,
          InventoryBucket.modifications,
          InventoryBucket.shaders,
          ];
    }
    return [
      InventoryBucket.kineticWeapons,
      InventoryBucket.energyWeapons,
      InventoryBucket.powerWeapons
    ];
  }

  double getListTopOffset(BuildContext context) {
    return kToolbarHeight + 2;
  }

  @override
  bool get wantKeepAlive => true;
}
