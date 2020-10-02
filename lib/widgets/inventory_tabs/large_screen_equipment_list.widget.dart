import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/widgets/item_list/character_info.widget.dart';
import 'package:little_light/widgets/item_list/item_list.widget.dart';

class LargeScreenEquipmentListWidget extends StatefulWidget {
  final DestinyCharacterComponent character;
  LargeScreenEquipmentListWidget({Key key, this.character}) : super(key: key);
  @override
  LargeScreenEquipmentListWidgetState createState() =>
      new LargeScreenEquipmentListWidgetState();
}

class LargeScreenEquipmentListWidgetState
    extends State<LargeScreenEquipmentListWidget> {
  List<int> bucketHashes = [
    InventoryBucket.lostItems,
    InventoryBucket.engrams,
    null,
    InventoryBucket.subclass,
    InventoryBucket.helmet,
    null,
    InventoryBucket.kineticWeapons,
    InventoryBucket.gauntlets,
    null,
    InventoryBucket.energyWeapons,
    InventoryBucket.chestArmor,
    null,
    InventoryBucket.powerWeapons,
    InventoryBucket.legArmor,
    null,
    InventoryBucket.ghost,
    InventoryBucket.classArmor,
    null,
    InventoryBucket.vehicle,
    InventoryBucket.ships,
    InventoryBucket.emblems,
    null,
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
    var screenPadding = MediaQuery.of(context).padding;
    return StaggeredGridView.countBuilder(
      padding: EdgeInsets.only(
          top: getListTopOffset(context) + screenPadding.top,
          bottom: 250 + screenPadding.bottom,
          left: 2 + screenPadding.left,
          right: 2 + screenPadding.right),
      crossAxisCount: 6,
      itemCount: bucketHashes.length + 1,
      itemBuilder: (BuildContext context, int index) => itemBuilder(index),
      staggeredTileBuilder: (int index) => tileBuilder(index),
      addAutomaticKeepAlives: true,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
    );
  }

  double getListTopOffset(BuildContext context) {
    return kToolbarHeight + 2;
  }

  Widget itemBuilder(int index) {
    if (index == 0) {
      return CharacterInfoWidget(characterId: widget.character.characterId);
    }
    var bucket = bucketHashes[index - 1];
    return ItemListWidget(
        key: Key("bucket${bucket}_${widget.character}"),
        characterId: widget.character.characterId,
        includeInfoHeader: false,
        shrinkWrap: true,
        padding: EdgeInsets.all(4),
        bucketHashes: [bucket]);
  }

  StaggeredTile tileBuilder(int index) {
    if (index == 0) {
      return StaggeredTile.extent(6, 112);
    }
    var bucketHash = bucketHashes[index - 1];
    switch (bucketHash) {
      case InventoryBucket.subclass:
      case InventoryBucket.helmet:
      case InventoryBucket.kineticWeapons:
      case InventoryBucket.gauntlets:
      case InventoryBucket.energyWeapons:
      case InventoryBucket.chestArmor:
      case InventoryBucket.powerWeapons:
      case InventoryBucket.legArmor:
      case InventoryBucket.ghost:
      case InventoryBucket.classArmor:
        return StaggeredTile.fit(3);
      case InventoryBucket.vehicle:
      case InventoryBucket.ships:
      case InventoryBucket.emblems:
        return StaggeredTile.fit(2);
      case InventoryBucket.consumables:
      case InventoryBucket.modifications:
      case InventoryBucket.shaders:
      case InventoryBucket.lostItems:
      case InventoryBucket.engrams:
        return StaggeredTile.fit(6);
    }
    return StaggeredTile.extent(6, 0);
  }
}
