import 'dart:async';
import 'dart:math';

import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/screens/item_detail.screen.dart';
import 'package:little_light/services/inventory/inventory.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/selection/selection.service.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_item_instance.widget.dart';
import 'package:shimmer/shimmer.dart';

enum DuplicatedListItemType {
  bucketTitle,
  itemDefinition,
  itemInstance,
  spacer
}

class DuplicatedItemsListData {
  final List<int> bucketHashes;
  final int category;
  DuplicatedItemsListData(this.category, this.bucketHashes);
}

class DuplicatedListItem {
  final DuplicatedListItemType type;
  final int hash;
  final DestinyItemComponent item;
  final List<ItemWithOwner> items;
  final String ownerId;
  DuplicatedListItem(this.type,
      {this.hash, this.item, this.ownerId, this.items});
}

class DuplicatedItemListWidget extends StatefulWidget {
  final ProfileService profile = ProfileService();
  final DuplicatedItemsListData data;
  DuplicatedItemListWidget({Key key, this.data}) : super(key: key);
  final NotificationService broadcaster = new NotificationService();

  @override
  DuplicatedItemListWidgetState createState() =>
      new DuplicatedItemListWidgetState();
}

class DuplicatedItemListWidgetState extends State<DuplicatedItemListWidget>
    with AutomaticKeepAliveClientMixin {
  List<DuplicatedListItem> items;
  Map<int, DestinyInventoryItemDefinition> itemDefinitions;
  StreamSubscription<NotificationEvent> subscription;

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    loadItems();
    subscription = widget.broadcaster.listen((event) {
      if (event.type == NotificationType.receivedUpdate ||
          event.type == NotificationType.localUpdate) {
        loadItems();
      }
    });
  }

  loadItems() async {
    List<ItemWithOwner> allItems = [];
    ProfileService profile = ProfileService();
    ManifestService manifest = ManifestService();
    Iterable<String> charIds =
        profile.getCharacters().map((char) => char.characterId);
    charIds.forEach((charId) {
      allItems.addAll(profile
          .getCharacterEquipment(charId)
          .map((item) => ItemWithOwner(item, charId)));
      allItems.addAll(profile
          .getCharacterInventory(charId)
          .map((item) => ItemWithOwner(item, charId)));
    });
    allItems.addAll(
        profile.getProfileInventory().map((item) => ItemWithOwner(item, null)));
    Map<int, List<ItemWithOwner>> itemsByHash = {};
    allItems.forEach((i) {
      int hash = i.item.itemHash;
      if (!itemsByHash.containsKey(hash)) {
        itemsByHash[hash] = [];
      }
      itemsByHash[hash].add(i);
    });
    itemsByHash.removeWhere((k, v) => v.length < 2);
    Iterable<int> hashes = itemsByHash.keys;

    itemDefinitions = await manifest
        .getDefinitions<DestinyInventoryItemDefinition>(hashes.toSet());

    itemsByHash.removeWhere((k, v) => !widget.data.bucketHashes
        .contains(itemDefinitions[k].inventory.bucketTypeHash));

    List<int> hashesByName = itemsByHash.keys.toList();
    hashesByName.sort((a, b) {
      var nameA = itemDefinitions[a].displayProperties.name;
      var nameB = itemDefinitions[b].displayProperties.name;
      return nameA.compareTo(nameB);
    });

    items = [];
    for (var bucketHash in widget.data.bucketHashes) {
      var hashesInBucket = hashesByName.where((hash) {
        var def = itemDefinitions[hash];
        return def.inventory.bucketTypeHash == bucketHash;
      }).toList();
      if (hashesInBucket.length < 1) {
        continue;
      }
      items.add(DuplicatedListItem(DuplicatedListItemType.bucketTitle,
          hash: bucketHash));
      hashesInBucket.forEach((hash) {
        items.add(DuplicatedListItem(DuplicatedListItemType.itemDefinition,
            hash: hash, items: itemsByHash[hash]));
        itemsByHash[hash].forEach((item) {
          items.add(DuplicatedListItem(DuplicatedListItemType.itemInstance,
              hash: hash, item: item.item, ownerId: item.ownerId));
        });
        items.add(DuplicatedListItem(DuplicatedListItemType.spacer));
      });
    }

    if (mounted) {
      setState(() {});
    }
  }

  Widget build(BuildContext context) {
    super.build(context);
    if (itemDefinitions == null) {
      return Center(
          child: Container(
              width: 96,
              child: Shimmer.fromColors(
                baseColor: Colors.blueGrey.shade300,
                highlightColor: Colors.white,
                child: Image.asset("assets/anim/loading.webp"),
              )));
    }
    var screenPadding = MediaQuery.of(context).padding;
    return StaggeredGridView.countBuilder(
      padding: EdgeInsets.all(4).copyWith(left: max(screenPadding.left, 4), right: max(screenPadding.right, 4)),
      crossAxisCount: 6,
      itemCount: items?.length ?? 0,
      itemBuilder: (BuildContext context, int index) => getItem(context, index),
      staggeredTileBuilder: (int index) => getTileBuilder(context, index),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }

  StaggeredTile getTileBuilder(BuildContext context, int index) {
    var item = items[index];
    switch (item.type) {
      case DuplicatedListItemType.bucketTitle:
        return StaggeredTile.extent(6, 40);

      case DuplicatedListItemType.itemDefinition:
        return StaggeredTile.extent(6, 96);
      case DuplicatedListItemType.itemInstance:
      if(MediaQueryHelper(context).laptopOrBigger){
          return StaggeredTile.extent(1, 110);  
        }
        if(MediaQueryHelper(context).tabletOrBigger){
          return StaggeredTile.extent(2, 110);  
        }
        return StaggeredTile.extent(3, 110);

      case DuplicatedListItemType.spacer:
        return StaggeredTile.extent(6, 20);
    }
    return StaggeredTile.extent(6, 96);
  }

  Widget getItem(BuildContext context, int index) {
    if (items == null) return null;
    if (index > items.length - 1) return null;
    var item = items[index];
    if (itemDefinitions == null) return Container();
    switch (item.type) {
      case DuplicatedListItemType.bucketTitle:
        return HeaderWidget(
          alignment: Alignment.centerLeft,
          child: ManifestText<DestinyInventoryBucketDefinition>(
            item.hash,
            uppercase: true,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );

      case DuplicatedListItemType.itemDefinition:
        return _DefinitionItemWrapper(
          itemDefinitions[item.hash], item.items);

      case DuplicatedListItemType.itemInstance:
        return _ItemInstanceWrapper(
          key:Key("item_${item.hash}_${item.item.itemInstanceId}_${item.ownerId}"),
          item: item.item,
          definition: itemDefinitions[item.hash],
          characterId: item.ownerId,
        );

      case DuplicatedListItemType.spacer:
        return Container();
    }
    return Container();
  }

  @override
  bool get wantKeepAlive => true;
}

class _DefinitionItemWrapper extends StatefulWidget {
  final DestinyInventoryItemDefinition definition;
  final List<ItemWithOwner> items;
  _DefinitionItemWrapper(this.definition, this.items);
  @override
  State<StatefulWidget> createState() {
    return _DefinitionItemWrapperState();
  }
}

class _DefinitionItemWrapperState extends State<_DefinitionItemWrapper> {
  bool get selected => widget.items.every((i) {
        return SelectionService().isSelected(i.item, i.ownerId);
      });

  @override
  void initState() {
    super.initState();

    StreamSubscription<List<ItemInventoryState>> sub;
    sub = SelectionService().broadcaster.listen((selectedItems) {
      if (!mounted) {
        sub.cancel();
        return;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      BaseInventoryItemWidget(
        null,
        widget.definition,
        null,
        characterId: null,
        uniqueId: null,
      ),
      selected
          ? Positioned.fill(
              child: Container(
                foregroundDecoration: BoxDecoration(
                    border:
                        Border.all(color: Colors.lightBlue.shade400, width: 2)),
              ),
            )
          : Container(),
          buildInkWell(context)
    ]);
  }
  
  Widget buildInkWell(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(context),
      ),
    );
  }

  void onTap(context) {
    if(selected){
      for(var item in widget.items){
        SelectionService().removeItem(item.item, item.ownerId);
      }
    }else{
      for(var item in widget.items){
        if(!SelectionService().isSelected(item.item, item.ownerId)){
          SelectionService().addItem(item.item, item.ownerId);
        }
      }
    }
  }
}

class _ItemInstanceWrapper extends StatefulWidget {
  final DestinyItemComponent item;
  final DestinyInventoryItemDefinition definition;
  final String characterId;

  _ItemInstanceWrapper({Key key, this.item, this.definition, this.characterId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ItemInstanceWrapperState();
  }
}

class _ItemInstanceWrapperState extends State<_ItemInstanceWrapper> {
  DestinyItemInstanceComponent instance;
  bool get selected =>
      SelectionService().isSelected(widget.item, widget.characterId);

  @override
  void initState() {
    instance = ProfileService().getInstanceInfo(widget.item.itemInstanceId);
    super.initState();

    StreamSubscription<List<ItemInventoryState>> sub;
    sub = SelectionService().broadcaster.listen((selectedItems) {
      if (!mounted) {
        sub.cancel();
        return;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
          child: BaseItemInstanceWidget(
              widget.item, widget.definition, instance,
              characterId: widget.characterId, uniqueId: null)),
      selected
          ? Positioned.fill(
              child: Container(
                foregroundDecoration: BoxDecoration(
                    border:
                        Border.all(color: Colors.lightBlue.shade400, width: 2)),
              ),
            )
          : Container(),
      buildInkWell(context)
    ]);
  }

  Widget buildInkWell(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        enableFeedback: false,
        onTap: () => onTap(context),
        onLongPress: () => onLongPress(context),
      ),
    );
  }

  void onTap(context) {
    if (SelectionService().multiselectActivated) {
      onLongPress(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(
              item:widget.item,
              definition:widget.definition,
              instanceInfo:instance,
              characterId: widget.characterId,
              uniqueId: null,
            ),
      ),
    );
  }

  void onLongPress(context) {
    if (widget.definition.nonTransferrable) return;

    SelectionService().addItem(widget.item, widget.characterId);
    setState(() {});
  }
}
