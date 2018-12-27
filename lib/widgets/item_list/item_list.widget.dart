import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/widgets/inventory_tabs/bucket_header.widget.dart';
import 'package:little_light/widgets/item_list/inventory_item.widget.dart';

class ItemListWidget extends StatefulWidget {
  final List<DestinyItemComponent> equipment;
  final EdgeInsets padding;
  final List<int> bucketHashes;
  ItemListWidget(this.equipment, {this.padding, this.bucketHashes});
  @override
  ItemListWidgetState createState() => new ItemListWidgetState();
}

class ItemListWidgetState extends State<ItemListWidget>{
  List<ListItem> listIndex;

  @override
  void initState() {
    buildIndex();
    super.initState();
  }

  buildIndex(){
    listIndex = [];
    widget.bucketHashes.forEach((hash){
      listIndex.add(new ListItem(ListItem.bucketHeader, hash));
      
      Iterable<DestinyItemComponent> equipped = widget.equipment.where((item)=>item.bucketHash == hash);
      listIndex.addAll(equipped.map((item)=>new ListItem(ListItem.equippedItem, item.itemHash, item)));
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
    return new StaggeredGridView.countBuilder(
      crossAxisCount: 6,
      itemCount: listIndex.length,
      itemBuilder: (BuildContext context, int index) => getItem(index),
      staggeredTileBuilder: (int index) => getTileBuilder(index),
      mainAxisSpacing: 0,
      crossAxisSpacing: 0,
    );
  }

  StaggeredTile getTileBuilder(int index){
    ListItem item = listIndex[index];
    switch (item.type){
      case ListItem.bucketHeader:
      return StaggeredTile.extent(100, 30);
    }
    return StaggeredTile.extent(100, 96);
  }

  Widget getItem(int index){
    ListItem item = listIndex[index];
    switch (item.type){
      case ListItem.bucketHeader:
        return BucketHeaderWidget(hash: listIndex[index].hash);

      case ListItem.equippedItem:
      return InventoryItemWidget(listIndex[index].itemComponent);
    }
    return Container(color:Colors.indigo, child:Text("Test"));
  }
}

class ListItem{
  static const String bucketHeader = "bucket_header";
  static const String equippedItem = "equipped_item";
  static const String unequippedItem = "unequipped_item";
  String type;
  int hash;
  DestinyItemComponent itemComponent;

  ListItem(this.type, this.hash, [this.itemComponent]);
}
