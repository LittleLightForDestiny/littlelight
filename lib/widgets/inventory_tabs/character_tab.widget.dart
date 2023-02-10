// @dart=2.9

import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/destiny_item_category.enum.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/widgets/item_list/item_list.widget.dart';

class CharacterTabWidget extends StatefulWidget {
  final DestinyCharacterComponent character;
  final int currentGroup;
  final EdgeInsets padding;
  const CharacterTabWidget(
    this.character,
    this.currentGroup, {
    Key key,
    this.padding,
  }) : super(key: key);
  @override
  CharacterTabWidgetState createState() => CharacterTabWidgetState();
}

class CharacterTabWidgetState extends State<CharacterTabWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ItemListWidget(
        key: Key("${widget.currentGroup}_${widget.character}"),
        characterId: widget.character.characterId,
        padding: widget.padding,
        bucketHashes: bucketHashes,
        currentGroup: widget.currentGroup);
  }

  List<int> get bucketHashes {
    switch (widget.currentGroup) {
      case DestinyItemCategory.Armor:
        return InventoryBucket.armorBucketHashes;
      case DestinyItemCategory.Weapon:
        return [InventoryBucket.subclass] + InventoryBucket.weaponBucketHashes;
    }
    return [InventoryBucket.lostItems, InventoryBucket.engrams] +
        InventoryBucket.flairBucketHashes +
        InventoryBucket.inventoryBucketHashes;
  }
}
