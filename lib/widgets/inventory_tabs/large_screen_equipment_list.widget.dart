import 'dart:math';

import 'package:bungie_api/destiny2.dart';
import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/item_list/bucket_header.widget.dart';
import 'package:little_light/widgets/item_list/character_info.widget.dart';
import 'package:little_light/widgets/item_list/item_list.widget.dart';
import 'package:little_light/widgets/item_list/items/inventory_item_wrapper.widget.dart';
import 'package:little_light/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/widgets/multisection_scrollview/sliver_section.dart';

const _suppressEmptySpaces = [
  InventoryBucket.consumables,
  InventoryBucket.shaders,
  InventoryBucket.modifications,
  InventoryBucket.lostItems
];

class LargeScreenEquipmentListWidget extends StatefulWidget {
  final DestinyCharacterComponent character;
  LargeScreenEquipmentListWidget({Key key, this.character}) : super(key: key);
  @override
  LargeScreenEquipmentListWidgetState createState() => new LargeScreenEquipmentListWidgetState();
}

class LargeScreenEquipmentListWidgetState extends State<LargeScreenEquipmentListWidget>
    with ManifestConsumer, UserSettingsConsumer, ProfileConsumer {
  Map<int, DestinyInventoryBucketDefinition> bucketDefinitions;
  final List<List<int>> bucketHashes = [
    [InventoryBucket.lostItems],
    [InventoryBucket.engrams],
    [InventoryBucket.subclass, InventoryBucket.helmet],
    [InventoryBucket.kineticWeapons, InventoryBucket.gauntlets],
    [InventoryBucket.energyWeapons, InventoryBucket.chestArmor],
    [InventoryBucket.powerWeapons, InventoryBucket.legArmor],
    [InventoryBucket.ghost, InventoryBucket.classArmor],
    [InventoryBucket.vehicle, InventoryBucket.ships, InventoryBucket.emblems],
    [InventoryBucket.consumables],
  ];
  Map<int, ListBucket> singleColumnBuckets;

  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  void asyncInit() async {
    await loadBucketDefinitions();
    await buildIndex();
  }

  Future<void> loadBucketDefinitions() async {
    await Future.delayed(Duration(milliseconds: 300));
    final hashes = bucketHashes.expand((element) => element).toList();
    final defs = await manifest.getDefinitions<DestinyInventoryBucketDefinition>(hashes);

    bucketDefinitions = defs;
  }

  buildIndex() async {
    if (!mounted) return;
    final characterID = widget.character.characterId;
    List<DestinyItemComponent> equipment = profile.getCharacterEquipment(characterID);
    List<DestinyItemComponent> characterInventory = profile.getCharacterInventory(characterID);
    List<DestinyItemComponent> profileInventory = profile.getProfileInventory();
    final bucketHashes = this.bucketHashes.where((l) => l.length == 1).expand((l) => l).toList();
    final buckets = Map<int, ListBucket>();
    for (int bucketHash in bucketHashes) {
      DestinyInventoryBucketDefinition bucketDef = bucketDefinitions[bucketHash];
      List<DestinyItemComponent> inventory =
          bucketDef?.scope == BucketScope.Character ? characterInventory : profileInventory;
      DestinyItemComponent equipped = equipment.firstWhere((item) => item.bucketHash == bucketHash, orElse: () => null);
      List<DestinyItemComponent> unequipped = inventory.where((item) => item.bucketHash == bucketHash).toList();
      unequipped = (await InventoryUtils.sortDestinyItems(unequipped.map((i) => ItemWithOwner(i, null))))
          .map((i) => i.item)
          .toList();

      buckets[bucketHash] = ListBucket(bucketHash: bucketHash, equipped: equipped, unequipped: unequipped);
    }

    if (!mounted) {
      return;
    }
    setState(() {
      this.singleColumnBuckets = buckets;
    });
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (bucketDefinitions == null) return LoadingAnimWidget();
    final sections = [buildCharacterHeader(context)];
    for (final bucketGroup in bucketHashes) {
      sections.addAll(buildColumns(context, bucketGroup));
    }
    return MultiSectionScrollView(
      sections,
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
      padding: EdgeInsets.all(4) + EdgeInsets.symmetric(vertical: kToolbarHeight) + MediaQuery.of(context).viewPadding,
    );
  }

  SliverSection buildCharacterHeader(BuildContext context) {
    return SliverSection(
      itemHeight: 112,
      itemCount: 1,
      itemBuilder: (context, _) => CharacterInfoWidget(
        key: Key("characterinfo_${widget.character.characterId}"),
        characterId: widget.character.characterId,
      ),
    );
  }

  List<SliverSection> buildColumns(BuildContext context, List<int> columnHashes) {
    switch (columnHashes.length) {
      case 1:
        return buildSingleColumnItemList(context, columnHashes.first);
      case 2:
      case 3:
        return [buildMultiColumnItemList(context, columnHashes)];
    }
    return [SliverSection(itemCount: 1, itemHeight: 0, itemBuilder: (context, index) => Container())];
  }

  double getMultiColumnHeight(BuildContext context, List<int> columnHashes) {
    final heights = columnHashes.map((h) => getColumnHeight(context, h, columnHashes.length));
    double maxHeight = 0;
    for (final height in heights) {
      maxHeight = max(height, maxHeight);
    }
    return maxHeight;
  }

  double getColumnHeight(BuildContext context, int columnHash, int columnCount) {
    BucketDisplayOptions bucketOptions = userSettings.getDisplayOptionsForBucket("$columnHash");
    final definition = bucketDefinitions[columnHash];
    final mq = MediaQuery.of(context);
    final headerHeight = 40;
    final equippedHeight = bucketOptions.equippedItemHeight;
    final itemsPerRow = bucketOptions.unequippedItemsPerRow;
    final columnWidth =
        (mq.size.width - (columnCount - 1) * 10 - 8 - mq.viewPadding.left - mq.viewPadding.right) / columnCount;
    final itemWidth = itemsPerRow >= 0 ? (columnWidth - (itemsPerRow - 1) * 2) / itemsPerRow : 0;
    final unequippedHeight = bucketOptions.unequippedItemHeight ?? itemWidth;
    final rowCount = itemsPerRow > 0 ? ((definition.itemCount - 1) / itemsPerRow).ceil() : 0;
    return headerHeight + 2 + equippedHeight + 2 + (unequippedHeight + 2) * (rowCount + 1);
  }

  SliverSection buildMultiColumnItemList(BuildContext context, List<int> columnHashes) {
    final lastIndex = columnHashes.length - 1;
    final height = getMultiColumnHeight(context, columnHashes);
    return SliverSection(
      itemHeight: height,
      itemCount: columnHashes.length,
      itemsPerRow: columnHashes.length,
      itemBuilder: (context, index) {
        final padding = EdgeInsets.only(right: index == 0 ? 4 : 0, left: index == lastIndex ? 4 : 0);
        final bucket = columnHashes[index];
        return Container(
            padding: padding,
            child: ItemListWidget(
                onBucketOptionsChanged: () {
                  if (mounted) {
                    setState(() {});
                  }
                },
                key: Key("bucket${bucket}_${widget.character}"),
                characterId: widget.character.characterId,
                includeInfoHeader: false,
                shrinkWrap: true,
                bucketHashes: [bucket]));
      },
    );
  }

  List<SliverSection> buildSingleColumnItemList(BuildContext context, int hash) {
    if (singleColumnBuckets == null || singleColumnBuckets[hash] == null) {
      return [
        SliverSection(
            itemCount: 1, itemsPerRow: 1, itemHeight: 200, itemBuilder: (context, index) => LoadingAnimWidget()),
      ];
    }

    final listBucket = singleColumnBuckets[hash];
    final unequipped = listBucket.unequipped;

    return [
      SliverSection(
          itemCount: 1,
          itemsPerRow: 1,
          itemHeight: 40,
          itemBuilder: (context, index) => BucketHeaderWidget(
                hash: hash,
                itemCount: unequipped.length,
                onChanged: (){
                  setState(() {});
                },
              )),
      buildUnequippedItems(unequipped, listBucket)
    ];
  }

  BucketDisplayOptions getBucketOptions(int bucketHash) {
    return userSettings.getDisplayOptionsForBucket("$bucketHash");
  }

  int getItemCountPerRow(BuildContext context, BucketDisplayOptions bucketOptions) {
    return bucketOptions.responsiveUnequippedItemsPerRow(context);
  }

  bool suppressEmptySpaces(bucketHash) => _suppressEmptySpaces?.contains(bucketHash) ?? false;

  SliverSection buildUnequippedItems(List<DestinyItemComponent> items, ListBucket bucket) {
    final bucketDef = bucketDefinitions[bucket.bucketHash];
    final bucketOptions = getBucketOptions(bucket.bucketHash);
    final maxSlots = bucketDef?.itemCount != null ? (bucketDef.itemCount - 1) : items.length;
    final itemsPerRow = getItemCountPerRow(context, bucketOptions);
    int bucketSize = maxSlots;
    if (!bucketDef.hasTransferDestination || suppressEmptySpaces(bucket.bucketHash)) {
      bucketSize = (items.length / itemsPerRow).ceil() * itemsPerRow;
    }
    final contentDensity = {
      BucketDisplayType.Large: ContentDensity.FULL,
      BucketDisplayType.Medium: ContentDensity.MEDIUM,
      BucketDisplayType.Small: ContentDensity.MINIMAL,
    }[bucketOptions.type];

    return SliverSection(
      itemBuilder: (context, index) {
        if(index > maxSlots){
          return Container();
        }
        if (index >= items.length) {
          return InventoryItemWrapperWidget(
            null,
            bucket.bucketHash,
            characterId: widget.character.characterId,
          );
        }
        final item = items[index];
        final itemKey = "equipped_${item?.itemInstanceId ?? item?.itemHash ?? 'empty'}";
        return InventoryItemWrapperWidget(
          item,
          item?.bucketHash,
          key: Key(itemKey),
          characterId: widget.character.characterId,
          density: contentDensity,
        );
      },
      itemCount: bucketSize,
      itemHeight: bucketOptions.unequippedItemHeight,
      itemsPerRow: itemsPerRow,
    );
  }
}
