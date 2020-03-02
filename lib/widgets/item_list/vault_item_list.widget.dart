import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/item_list/bucket_header.widget.dart';
import 'package:little_light/widgets/item_list/item_list.widget.dart';
import 'package:little_light/widgets/item_list/vault_info.widget.dart';

import 'items/inventory_item_wrapper.widget.dart';

class VaultItemListWidget extends ItemListWidget {
  VaultItemListWidget(
      {EdgeInsets padding,
      List<int> bucketHashes,
      Key key,
      Map<int, double> scrollPositions})
      : super(
            key: key,
            padding: padding,
            bucketHashes: bucketHashes,
            scrollPositions: scrollPositions);
  @override
  VaultItemListWidgetState createState() => new VaultItemListWidgetState();
}

class VaultItemListWidgetState extends ItemListWidgetState {
  @override
  bool suppressEmptySpaces(bucketHash) => true;
  
  @override
  buildIndex() async {
    if (!mounted) return;
    List<DestinyItemComponent> itemsOnVault = widget.profile
        .getProfileInventory()
        .where((i) => i.bucketHash == InventoryBucket.general)
        .toList();
    this.bucketDefs = await widget.manifest
        .getDefinitions<DestinyInventoryBucketDefinition>(widget.bucketHashes);
    Map<int, DestinyInventoryItemDefinition> itemDefs = await widget.manifest
        .getDefinitions<DestinyInventoryItemDefinition>(
            itemsOnVault.map((i) => i.itemHash));
    this.buckets = [];
    for (int bucketHash in widget.bucketHashes) {
      List<DestinyItemComponent> unequipped = itemsOnVault.where((item) {
        var def = itemDefs[item.itemHash];
        return def?.inventory?.bucketTypeHash == bucketHash;
      }).toList();
      unequipped = (await InventoryUtils.sortDestinyItems(unequipped.map((i)=>ItemWithOwner(i, null)))).map((i)=>i.item).toList();

      this
          .buckets
          .add(ListBucket(bucketHash: bucketHash, unequipped: unequipped));
    }

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  // @override
  // Widget build(BuildContext context) {
  //   super.build(context);
  //   return Padding(
  //     padding: widget.padding,
  //     child: buildList(),
  //   );
  // }

  // Widget getList() {
  //   if (listIndex.length < 2) {
  //     return Container();
  //   }
  //   return StaggeredGridView.countBuilder(
  //     crossAxisCount: 30,
  //     itemCount: listIndex.length,
  //     itemBuilder: (BuildContext context, int index) => getItem(index),
  //     staggeredTileBuilder: (int index) => getTileBuilder(index),
  //     mainAxisSpacing: 2,
  //     crossAxisSpacing: 2,
  //   );
  // }

  @override
  Widget getItem(int index, List<ListItem> listIndex) {
    ListItem item = listIndex[index];
    String itemKey =
        "${index}_${item.itemComponent?.itemInstanceId ?? item.itemComponent?.itemHash ?? 'empty'}";
    switch (item?.type) {
      case ListItem.infoHeader:
        return VaultInfoWidget();

      case ListItem.bucketHeader:
        return BucketHeaderWidget(
          hash: item?.hash,
          itemCount: item.itemCount,
          isVault: true,
        );

      case ListItem.unequippedItem:
        return InventoryItemWrapperWidget(
          item?.itemComponent,
          item?.bucketHash,
          key: Key(itemKey),
          density: ContentDensity.MINIMAL,
          characterId: widget.characterId,
        );
    }
    return super.getItem(index, listIndex);
  }

  StaggeredTile getTileBuilder(int index, List<ListItem> listIndex) {
    ListItem item = listIndex[index];
    switch (item?.type) {
      case ListItem.unequippedItem:
        if (MediaQueryHelper(context).isDesktop) {
          return StaggeredTile.count(2, 2);
        }
        if (MediaQueryHelper(context).tabletOrBigger || MediaQueryHelper(context).isLandscape) {
          return StaggeredTile.count(3, 3);
        }
        return StaggeredTile.count(6, 6);
    }
    return super.getTileBuilder(index, listIndex);
  }
}
