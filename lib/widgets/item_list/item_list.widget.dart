import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/services/bungie-api/enums/inventory-bucket-hash.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/item_list/bucket_header.widget.dart';
import 'package:little_light/widgets/item_list/character_info.widget.dart';
import 'package:little_light/widgets/item_list/items/inventory_item.widget.dart';


class ItemListWidget extends StatefulWidget {
  final String characterId;
  final bool isVault;
  final ManifestService manifest = new ManifestService();
  final ProfileService profile = new ProfileService();
  final EdgeInsets padding;
  final List<int> bucketHashes;
  ItemListWidget({this.padding, this.bucketHashes, this.characterId, this.isVault});
  @override
  ItemListWidgetState createState() => new ItemListWidgetState();
}

class ItemListWidgetState extends State<ItemListWidget>{
  List<DestinyItemComponent> equipment;
  List<DestinyItemComponent> inventory;
  List<ListItem> listIndex;

  @override
  void initState() {
    equipment = widget.profile.getCharacterEquipment(widget.characterId);
    inventory = widget.profile.getCharacterInventory(widget.characterId);
    buildIndex();
    super.initState();
  }

  buildIndex(){
    listIndex = [];
    listIndex.add(new ListItem(ListItem.infoHeader, null));

    widget.bucketHashes.forEach((hash){
      DestinyInventoryBucketDefinition bucketDef = widget.manifest.getBucketDefinition(hash);
      Iterable<DestinyItemComponent> equipped = equipment.where((item)=>item.bucketHash == hash);
      Iterable<DestinyItemComponent> unequipped = inventory.where((item)=>item.bucketHash == hash);
      int bucketSize = bucketDef.itemCount;
      if(hash == InventoryBucket.subclass){
        bucketSize = 3;
      }
      int itemCount = equipped.length + unequipped.length;
      listIndex.add(new ListItem(ListItem.bucketHeader, hash, itemCount: itemCount));
      listIndex.addAll(equipped.map((item)=>new ListItem(ListItem.equippedItem, item.itemHash, itemComponent:item, bucketHash: hash)));
      listIndex.addAll(unequipped.map((item)=>new ListItem(ListItem.unequippedItem, item.itemHash, itemComponent:item, bucketHash: hash)));
      for(int i = 0; i < bucketSize - itemCount; i++){
        listIndex.add(ListItem(ListItem.unequippedItem, null, bucketHash:hash));
      }
      listIndex.add(new ListItem(ListItem.spacer, hash));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: getList(),
    );
  }

  Widget getList(){
    return StaggeredGridView.countBuilder(
      crossAxisCount: 6,
      itemCount: listIndex.length,
      physics: AlwaysScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) => getItem(index),
      staggeredTileBuilder: (int index) => getTileBuilder(index),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
    );
  }

  StaggeredTile getTileBuilder(int index){
    ListItem item = listIndex[index];
    switch (item.type){
      case ListItem.bucketHeader:
      return StaggeredTile.fit(6);
      case ListItem.equippedItem:
      return StaggeredTile.extent(6, 96);
      case ListItem.unequippedItem:
      if(item.bucketHash == InventoryBucket.subclass){
        return StaggeredTile.extent(3, 76);
      }
      return StaggeredTile.extent(2, 76);
    }
    return StaggeredTile.extent(100, 96);
  }

  Widget getItem(int index){
    ListItem item = listIndex[index];
    switch (item.type){
      case ListItem.infoHeader:
        return CharacterInfoWidget(characterId: widget.characterId,);

      case ListItem.bucketHeader:
        return BucketHeaderWidget(hash: item?.hash, itemCount: item.itemCount,);

      case ListItem.equippedItem:
      return InventoryItemWidget.builder(item?.itemComponent);

      case ListItem.unequippedItem:
      return InventoryItemWidget.builder(item?.itemComponent, ContentDensity.MEDIUM);

      case ListItem.spacer:
      return Container();
    }
    return Container(color:Colors.indigo, child:Text("You shouldn't be seeing this, please report"));
  }
}

class ListItem{
  static const String infoHeader = "info_header";
  static const String bucketHeader = "bucket_header";
  static const String equippedItem = "equipped_item";
  static const String unequippedItem = "unequipped_item";
  static const String spacer = "spacer";
  final String type;
  final int hash;
  final int itemCount;
  final int bucketHash;
  final DestinyItemComponent itemComponent;

  ListItem(this.type, this.hash, {this.itemComponent, this.itemCount, this.bucketHash});
}
