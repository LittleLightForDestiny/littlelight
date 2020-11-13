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
import 'package:little_light/services/user_settings/bucket_display_options.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/item_list/character_info.widget.dart';
import 'package:shimmer/shimmer.dart';

import 'bucket_header.widget.dart';
import 'items/inventory_item_wrapper.widget.dart';

const _fullWidthBuckets = [
  InventoryBucket.consumables,
  InventoryBucket.shaders,
  InventoryBucket.modifications,
  InventoryBucket.lostItems,
  InventoryBucket.engrams
];

const _suppressEmptySpaces = [
  InventoryBucket.consumables,
  InventoryBucket.shaders,
  InventoryBucket.modifications,
  InventoryBucket.lostItems
];

class ItemListWidget extends StatefulWidget {
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
      _suppressEmptySpaces?.contains(bucketHash) ?? false;

  bool isFullWidthBucket(bucketHash) =>
      _fullWidthBuckets?.contains(bucketHash) ?? false;

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
          bucketDef?.scope == BucketScope.Character
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

    var screenPadding = MediaQuery.of(context).padding;

    return StaggeredGridView.countBuilder(
      shrinkWrap: widget.shrinkWrap,
      crossAxisCount: 30,
      itemCount: listIndex.length,
      itemBuilder: (BuildContext context, int index) =>
          getItem(index, listIndex),
      staggeredTileBuilder: (int index) => getTileBuilder(index, listIndex),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      padding: widget.shrinkWrap
          ? null
          : EdgeInsets.only(
              top: max(screenPadding.top, 8),
              bottom: screenPadding.bottom + 100),
      controller: controller,
      physics: widget.shrinkWrap
          ? NeverScrollableScrollPhysics()
          : AlwaysScrollableScrollPhysics(),
    );
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

      var emptyItems = bucketSize - itemCount;
      for (var i = 0; i < emptyItems; i++) {
        list.add(new ListItem(ListItem.unequippedItem, null,
            bucketHash: b.bucketHash));
      }

      list.add(new ListItem(ListItem.spacer, null, bucketHash: b.bucketHash));
    });
    if (!widget.shrinkWrap) {
      list.add(new ListItem(ListItem.spacer, null));
      list.add(new ListItem(ListItem.spacer, null));
    }

    return list;
  }

  StaggeredTile getTileBuilder(int index, List<ListItem> listIndex) {
    ListItem item = listIndex[index];
    var options = getBucketOptions(item);
    switch (item?.type) {
      case ListItem.infoHeader:
        return StaggeredTile.extent(30, 112);
      case ListItem.bucketHeader:
        return StaggeredTile.extent(30, 40);
      case ListItem.equippedItem:
        if (options.type == BucketDisplayType.Hidden) {
          return StaggeredTile.extent(30, 0);
        }
        return StaggeredTile.extent(30, 96);
      case ListItem.unequippedItem:
        if (item?.hash == null && suppressEmptySpaces(item?.bucketHash)) {
          return StaggeredTile.extent(1, 0);
        }
        switch (options.type) {
          case BucketDisplayType.Hidden:
          case BucketDisplayType.OnlyEquipped:
            return StaggeredTile.extent(1, 0);
          case BucketDisplayType.Large:
            if (item.hash == null) {
              var previous = listIndex[index - 1];
              if (previous?.hash == null) {
                return StaggeredTile.extent(1, 0);
              }
            }
            if (MediaQueryHelper(context).isDesktop &&
                isFullWidthBucket(item.bucketHash)) {
              return StaggeredTile.extent(10, 96);
            }
            if ((MediaQueryHelper(context).tabletOrBigger ||
                    MediaQueryHelper(context).isLandscape) &&
                isFullWidthBucket(item.bucketHash)) {
              return StaggeredTile.extent(15, 96);
            }
            return StaggeredTile.extent(30, 96);
          case BucketDisplayType.Medium:
            if (MediaQueryHelper(context).isDesktop &&
                isFullWidthBucket(item.bucketHash)) {
              return StaggeredTile.extent(5, 76);
            }
            if ((MediaQueryHelper(context).tabletOrBigger ||
                    MediaQueryHelper(context).isLandscape) &&
                isFullWidthBucket(item.bucketHash)) {
              return StaggeredTile.extent(6, 76);
            }
            return StaggeredTile.extent(10, 76);
          case BucketDisplayType.Small:
            if (MediaQueryHelper(context).isDesktop) {
              if (isFullWidthBucket(item.bucketHash)) {
                return StaggeredTile.count(2, 2);
              }
              return StaggeredTile.count(3, 3);
            }
            if ((MediaQueryHelper(context).tabletOrBigger ||
                    MediaQueryHelper(context).isLandscape) &&
                isFullWidthBucket(item.bucketHash)) {
              return StaggeredTile.count(3, 3);
            }
            return StaggeredTile.count(6, 6);
        }
        break;

      case ListItem.spacer:
        if ([BucketDisplayType.Hidden, BucketDisplayType.OnlyEquipped]
            .contains(options.type)) {
          return StaggeredTile.extent(30, 00);
        }
        if (widget.shrinkWrap) {
          return StaggeredTile.extent(30, 00);
        }
        return StaggeredTile.extent(30, 76);
    }
    return StaggeredTile.extent(30, 112);
  }

  Widget getItem(int index, List<ListItem> listIndex) {
    ListItem item = listIndex[index];
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
          key: Key("bucketheader_${widget.characterId}_${item?.hash}"),
          hash: item?.hash,
          itemCount: item.itemCount,
          isEquippable:
              buckets.firstWhere((b) => b.bucketHash == item?.hash)?.equipped !=
                  null,
          onChanged: () {
            setState(() {});
          },
        );

      case ListItem.equippedItem:
        return buildEquippedItem(index, item, characterId);

      case ListItem.unequippedItem:
        return buildUnequippedItem(index, item, characterId);

      case ListItem.spacer:
        return Container();
    }
    return Container(
        color: Colors.indigo,
        child: Text("You shouldn't be seeing this, please report"));
  }

  Widget buildEquippedItem(int index, ListItem item, String characterId) {
    String itemKey =
        "equipped_${index}_${item.itemComponent?.itemInstanceId ?? item.itemComponent?.itemHash ?? 'empty'}";
    var options = getBucketOptions(item);
    if (options.type == BucketDisplayType.Hidden) {
      return Container();
    }
    return InventoryItemWrapperWidget(
      item?.itemComponent,
      item?.bucketHash,
      key: Key(itemKey),
      characterId: characterId,
    );
  }

  BucketDisplayOptions getBucketOptions(ListItem item) {
    var options =
        UserSettingsService().getDisplayOptionsForBucket("${item?.bucketHash}");
    return options;
  }

  Widget buildUnequippedItem(int index, ListItem item, String characterId) {
    var options = getBucketOptions(item);
    var density = ContentDensity.MEDIUM;
    String itemKey =
        "unequipped_${index}_${item.itemComponent?.itemInstanceId ?? item.itemComponent?.itemHash ?? 'empty'}";

    if (item?.hash == null && suppressEmptySpaces(item?.bucketHash)) {
      return Container();
    }

    switch (options.type) {
      case BucketDisplayType.Hidden:
        return Container();
      case BucketDisplayType.OnlyEquipped:
        return Container();
      case BucketDisplayType.Large:
        density = ContentDensity.FULL;
        break;
      case BucketDisplayType.Medium:
        density = ContentDensity.MEDIUM;
        break;
      case BucketDisplayType.Small:
        density = ContentDensity.MINIMAL;
        break;
    }

    return InventoryItemWrapperWidget(
      item?.itemComponent,
      item?.bucketHash,
      key: Key(itemKey),
      density: density,
      characterId: characterId,
    );
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
