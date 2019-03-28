import 'dart:math';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/widgets/item_list/bucket_header.widget.dart';
import 'package:little_light/widgets/item_list/character_info.widget.dart';
import 'package:little_light/widgets/item_list/item_list.widget.dart';
import 'package:little_light/widgets/item_list/items/inventory_item_wrapper.widget.dart';


class VaultItemListWidget extends ItemListWidget {
  VaultItemListWidget(
      {EdgeInsets padding,
      List<int> bucketHashes,
      Key key})
      : super(key: key, padding:padding, bucketHashes:bucketHashes);
  @override
  VaultItemListWidgetState createState() => new VaultItemListWidgetState();
}

class VaultItemListWidgetState extends ItemListWidgetState {

  buildIndex() async {
    List<DestinyItemComponent> inventory = widget.profile.getProfileInventory();
    inventory = inventory.where((item)=>item.bucketHash == InventoryBucket.general).toList();
    List<int> hashes = inventory.map((item)=>item.itemHash).toList();
    Map<int, DestinyInventoryItemDefinition> defs = (await widget.manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes));
    Map<int, List<DestinyItemComponent>> itemsByBucket = new Map();

    for(int i = 0; i < inventory.length; i++){
      DestinyItemComponent item = inventory[i];
      DestinyInventoryItemDefinition definition = defs[item.itemHash];
      int bucketHash = definition.inventory.bucketTypeHash;
      if(!itemsByBucket.containsKey(bucketHash)){
        itemsByBucket[bucketHash] = new List();
      }
      itemsByBucket[bucketHash].add(item);
    }

    listIndex = [];
    
    for(var hash in widget.bucketHashes){
      List<DestinyItemComponent> unequipped = itemsByBucket[hash];
      
      
      
      if(unequipped == null){
        unequipped = [];
        // return;
      }

      unequipped.sort((itemA, itemB) {
        return InventoryUtils.sortDestinyItems(itemA, itemB, widget.profile);
      });
    
      int itemCount = unequipped.length;
      int bucketSize = max((itemCount/5).ceil()*5, 5);
      
      listIndex
          .add(new ListItem(ListItem.bucketHeader, hash, itemCount: itemCount));
      listIndex.addAll(unequipped.map((item) => new ListItem(
          ListItem.unequippedItem, item.itemHash,
          itemComponent: item, bucketHash: hash)));

      int fillEmpty = bucketSize - itemCount;
      for (int i = 0; i < fillEmpty; i++) {
        listIndex
            .add(ListItem(ListItem.unequippedItem, null, bucketHash: hash));
      }
      listIndex.add(new ListItem(ListItem.spacer, hash));
      if(mounted){
        setState(() {});
      }
    }
    listIndex.add(new ListItem(ListItem.spacer, 0));
    listIndex.add(new ListItem(ListItem.spacer, 0));
    if(!mounted){
      return;
    }
    setState(() {
      this.listIndex = listIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: getList(),
    );
  }

  Widget getList() {
    if(listIndex.length < 2){
      return Container();
    }
    return StaggeredGridView.countBuilder(
      crossAxisCount: 30,
      itemCount: listIndex.length,
      itemBuilder: (BuildContext context, int index) => getItem(index),
      staggeredTileBuilder: (int index) => getTileBuilder(index),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
    );
  }

  StaggeredTile getTileBuilder(int index) {
    ListItem item = listIndex[index];
    switch (item.type) {
      case ListItem.bucketHeader:
        return StaggeredTile.extent(30, 40);
      case ListItem.unequippedItem:
      return StaggeredTile.count(6, 6);
        
      case ListItem.spacer:
        return StaggeredTile.count(30, 6);
      
    }
    return StaggeredTile.extent(30, 96);
  }

  Widget getItem(int index) {
    ListItem item = listIndex[index];
    String itemKey = "${index}_${item.itemComponent?.itemInstanceId ?? item.itemComponent?.itemHash ?? 'empty'}";
    switch (item.type) {
      case ListItem.infoHeader:
        return CharacterInfoWidget(
          characterId: widget.characterId,
        );

      case ListItem.bucketHeader:
        return BucketHeaderWidget(
          hash: item?.hash,
          itemCount: item.itemCount,
        );

      case ListItem.unequippedItem:
      return InventoryItemWrapperWidget(item?.itemComponent, item?.bucketHash,
            key:Key(itemKey),
            density: ContentDensity.MINIMAL, characterId: widget.characterId,);

      case ListItem.spacer:
        return Container();
    }
    return Container(
        color: Colors.indigo,
        child: Text("You shouldn't be seeing this, please report"));
  }
}
