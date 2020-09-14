import 'dart:async';
import 'dart:math';

import 'package:bungie_api/enums/bucket_scope.dart';
import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/item_list/character_info.widget.dart';
import 'package:shimmer/shimmer.dart';

import 'bucket_header.widget.dart';
import 'items/inventory_item_wrapper.widget.dart';

class ItemListWidget extends StatefulWidget {
  final List<int> minimalDensityBucketHashes = [
    InventoryBucket.lostItems,
    InventoryBucket.engrams,
    InventoryBucket.consumables,
    InventoryBucket.shaders,
    InventoryBucket.modifications
  ];
  final suppressEmptySpaces = [
    InventoryBucket.consumables,
    InventoryBucket.shaders,
    InventoryBucket.modifications,
    InventoryBucket.lostItems
  ];
  final String characterId;
  final ManifestService manifest = new ManifestService();
  final ProfileService profile = new ProfileService();
  final NotificationService broadcaster = new NotificationService();
  final EdgeInsets padding;
  final List<int> bucketHashes;
  final Map<int, double> scrollPositions;

  final int currentGroup;

  final bool shrinkWrap;

  final bool includeInfoHeader;

  final bool fixedSizedEquipmentBuckets;

  ItemListWidget(
      {this.padding,
      this.bucketHashes,
      this.characterId,
      this.includeInfoHeader = true,
      this.shrinkWrap = false,
      Key key,
      this.scrollPositions,
      this.currentGroup,
      this.fixedSizedEquipmentBuckets = false})
      : super(key: key);
  @override
  ItemListWidgetState createState() => new ItemListWidgetState();
}

class ItemListWidgetState extends State<ItemListWidget>
    with AutomaticKeepAliveClientMixin {
  Map<int, DestinyInventoryBucketDefinition> bucketDefs;
  List<ListBucket> buckets;
  StreamSubscription<NotificationEvent> subscription;

  bool suppressEmptySpaces(bucketHash) =>
      widget.suppressEmptySpaces?.contains(bucketHash) ?? false;

  @override
  void initState() {
    super.initState();
    buildIndex();
    subscription = widget.broadcaster.listen((event) {
      if (event.type == NotificationType.receivedUpdate ||
          event.type == NotificationType.localUpdate) {
        buildIndex();
      }
    });
  }

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }

  buildIndex() async {
    if (!mounted) return;
    List<DestinyItemComponent> equipment =
        widget.profile.getCharacterEquipment(widget.characterId);
    List<DestinyItemComponent> characterInventory =
        widget.profile.getCharacterInventory(widget.characterId);
    List<DestinyItemComponent> profileInventory =
        widget.profile.getProfileInventory();
    this.bucketDefs = await widget.manifest
        .getDefinitions<DestinyInventoryBucketDefinition>(widget.bucketHashes);
    this.buckets = [];
    for (int bucketHash in widget.bucketHashes) {
      DestinyInventoryBucketDefinition bucketDef = bucketDefs[bucketHash];
      List<DestinyItemComponent> inventory =
          bucketDef.scope == BucketScope.Character
              ? characterInventory
              : profileInventory;
      DestinyItemComponent equipped = equipment.firstWhere(
          (item) => item.bucketHash == bucketHash,
          orElse: () => null);
      List<DestinyItemComponent> unequipped =
          inventory.where((item) => item.bucketHash == bucketHash).toList();
      unequipped = (await InventoryUtils.sortDestinyItems(
              unequipped.map((i) => ItemWithOwner(i, null))))
          .map((i) => i.item)
          .toList();

      this.buckets.add(ListBucket(
          bucketHash: bucketHash, equipped: equipped, unequipped: unequipped));
    }

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: widget.padding,
      child: (buckets?.length ?? 0) == 0
          ? buildLoading(context)
          : buildList(context),
    );
  }

  Widget buildLoading(BuildContext context) {
    return Center(
        child: Container(
            width: 96,
            child: Shimmer.fromColors(
              baseColor: Colors.blueGrey.shade300,
              highlightColor: Colors.white,
              child: Image.asset("assets/anim/loading.webp"),
            )));
  }

  Widget buildList(BuildContext context) {
    double initialOffset = 0;
    ScrollController controller;
    if (widget?.scrollPositions?.containsKey(widget?.currentGroup) ?? false) {
      initialOffset = widget.scrollPositions[widget.currentGroup];
      controller = ScrollController(
        initialScrollOffset: initialOffset,
      );
      controller.addListener(() {
        widget.scrollPositions[widget.currentGroup] = controller.offset;
      });
    }

    var listIndex = getListIndex(context);

    return StaggeredGridView.countBuilder(
      shrinkWrap: widget.shrinkWrap,
      crossAxisCount: 30,
      itemCount: listIndex.length,
      itemBuilder: (BuildContext context, int index) =>
          getItem(index, listIndex),
      staggeredTileBuilder: (int index) => getTileBuilder(index, listIndex),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      controller: controller,
      physics: widget.shrinkWrap
          ? NeverScrollableScrollPhysics()
          : AlwaysScrollableScrollPhysics(),
    );
  }

  int getMinimalItemsPerRow(BuildContext context) {
    var helper = MediaQueryHelper(context);
    if (helper.isDesktop) {
      return 15;
    }
    if (helper.tabletOrBigger) {
      return 10;
    }
    return 5;
  }

  List<ListItem> getListIndex(BuildContext context) {
    List<ListItem> list = [];
    if (widget.includeInfoHeader) {
      list.add(new ListItem(ListItem.infoHeader, null));
    }

    buckets.forEach((b) {
      var bucketDef = bucketDefs[b.bucketHash];
      int bucketSize = bucketDef?.itemCount ?? 0;
      int itemCount =
          (b.equipped != null ? 1 : 0) + (b.unequipped?.length ?? 0);
      if (b.bucketHash == InventoryBucket.subclass) {
        bucketSize = 3;
      }
      if (itemCount > 0) {
        list.add(new ListItem(ListItem.bucketHeader, b.bucketHash,
            bucketHash: b.bucketHash, itemCount: itemCount));
      } else {
        return;
      }

      if (b.equipped != null) {
        list.add(new ListItem(ListItem.equippedItem, b.equipped.itemHash,
            bucketHash: b.bucketHash, itemComponent: b.equipped));
      }

      b.unequipped?.forEach((i) {
        list.add(new ListItem(ListItem.unequippedItem, i.itemHash,
            bucketHash: b.bucketHash, itemComponent: i));
      });

      if (suppressEmptySpaces(b.bucketHash)) {
        var itemsPerRow = getMinimalItemsPerRow(context);
        bucketSize =
            max((itemCount / itemsPerRow).ceil() * itemsPerRow, itemsPerRow);
      }

      var emptyItems = bucketSize - itemCount;
      for (var i = 0; i < emptyItems; i++) {
        list.add(new ListItem(ListItem.unequippedItem, null,
            bucketHash: b.bucketHash));
      }

      list.add(new ListItem(ListItem.spacer, null));
    });
    if (!widget.shrinkWrap) {
      list.add(new ListItem(ListItem.spacer, null));
      list.add(new ListItem(ListItem.spacer, null));
    }

    return list;
  }

  StaggeredTile getTileBuilder(int index, List<ListItem> listIndex) {
    ListItem item = listIndex[index];
    switch (item?.type) {
      case ListItem.infoHeader:
        return StaggeredTile.extent(30, 112);
      case ListItem.bucketHeader:
        return StaggeredTile.extent(30, 40);
      case ListItem.equippedItem:
        return StaggeredTile.extent(30, 96);
      case ListItem.unequippedItem:
        if (item.bucketHash == InventoryBucket.subclass) {
          return StaggeredTile.extent(10, 76);
        }

        if (widget.minimalDensityBucketHashes.contains(item.bucketHash)) {
          if (MediaQueryHelper(context).isDesktop) {
            return StaggeredTile.count(2, 2);
          }
          if (MediaQueryHelper(context).tabletOrBigger ||
              MediaQueryHelper(context).isLandscape) {
            return StaggeredTile.count(3, 3);
          }
          return StaggeredTile.count(6, 6);
        }
        return StaggeredTile.extent(10, 76);
      case ListItem.spacer:
        if (widget.shrinkWrap) {
          return StaggeredTile.extent(30, 40);
        }
        return StaggeredTile.extent(30, 76);
    }
    return StaggeredTile.extent(30, 112);
  }

  Widget getItem(int index, List<ListItem> listIndex) {
    ListItem item = listIndex[index];
    String itemKey =
        "${index}_${item.itemComponent?.itemInstanceId ?? item.itemComponent?.itemHash ?? 'empty'}";
    var bucketDef = bucketDefs[item?.bucketHash];
    var characterId =
        bucketDef?.scope == BucketScope.Character ? widget.characterId : null;

    switch (item?.type) {
      case ListItem.infoHeader:
        return CharacterInfoWidget(
          key: Key("characterinfo_${widget.characterId}"),
          characterId: widget.characterId,
        );

      case ListItem.bucketHeader:
        return BucketHeaderWidget(
          hash: item?.hash,
          itemCount: item.itemCount,
        );

      case ListItem.equippedItem:
        return InventoryItemWrapperWidget(
          item?.itemComponent,
          item?.bucketHash,
          key: Key(itemKey),
          characterId: characterId,
        );

      case ListItem.unequippedItem:
        if (widget.minimalDensityBucketHashes.contains(item.bucketHash)) {
          return InventoryItemWrapperWidget(
            item?.itemComponent,
            item?.bucketHash,
            key: Key(itemKey),
            density: ContentDensity.MINIMAL,
            characterId: characterId,
          );
        }
        return InventoryItemWrapperWidget(
          item?.itemComponent,
          item?.bucketHash,
          key: Key(itemKey),
          density: ContentDensity.MEDIUM,
          characterId: characterId,
        );

      case ListItem.spacer:
        return Container();
    }
    return Container(
        color: Colors.indigo,
        child: Text("You shouldn't be seeing this, please report"));
  }

  @override
  bool get wantKeepAlive => true;
}

class ListBucket {
  final int bucketHash;
  final DestinyItemComponent equipped;
  final List<DestinyItemComponent> unequipped;

  ListBucket({this.bucketHash, this.equipped, this.unequipped});
}

class ListItem {
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

  ListItem(this.type, this.hash,
      {this.itemComponent, this.itemCount, this.bucketHash});
}
