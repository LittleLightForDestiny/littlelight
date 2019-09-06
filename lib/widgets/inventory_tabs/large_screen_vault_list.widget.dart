import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/widgets/item_list/vault_item_list.widget.dart';

class LargeScreenVaultListWidget extends StatefulWidget {
  final DestinyCharacterComponent character;
  LargeScreenVaultListWidget({Key key, this.character}) : super(key: key);
  @override
  LargeScreenVaultListWidgetState createState() =>
      new LargeScreenVaultListWidgetState();
}

class LargeScreenVaultListWidgetState
    extends State<LargeScreenVaultListWidget> {
  List<int> bucketHashes = [
    InventoryBucket.kineticWeapons,
    InventoryBucket.energyWeapons,
    InventoryBucket.powerWeapons,
    InventoryBucket.helmet,
    InventoryBucket.gauntlets,
    InventoryBucket.chestArmor,
    InventoryBucket.legArmor,
    InventoryBucket.classArmor,
    InventoryBucket.ghost,
    InventoryBucket.vehicle,
    InventoryBucket.ships,
    InventoryBucket.consumables,
    InventoryBucket.modifications,
    InventoryBucket.shaders,
  ];

  @override
  void initState() {
    super.initState();
    loadBucketDefinitions();
  }

  void loadBucketDefinitions() {}

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VaultItemListWidget(
      key: Key("vault_inventory"),
      padding:
          EdgeInsets.only(top: getListTopOffset(context), left: 2, right: 2),
      bucketHashes: bucketHashes,
    );
  }

  double getListTopOffset(BuildContext context) {
    return kToolbarHeight + 2;
  }
}
