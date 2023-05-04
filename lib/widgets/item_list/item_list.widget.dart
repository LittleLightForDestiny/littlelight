// @dart=2.9

import 'dart:async';

import 'package:bungie_api/enums/bucket_scope.dart';
import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/core/utils/logger/logger.wrapper.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/selection/selection.consumer.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/item_list/character_info.widget.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sliver_section.dart';

import 'bucket_header.widget.dart';
import 'items/inventory_item_wrapper.widget.dart';

const _fullWidthBuckets = [
  InventoryBucket.consumables,
  InventoryBucket.modifications,
  InventoryBucket.lostItems,
  InventoryBucket.engrams
];

const _suppressEmptySpaces = [InventoryBucket.consumables, InventoryBucket.modifications, InventoryBucket.lostItems];

typedef OnBucketOptionsChanged = void Function();

class ItemListWidget extends StatefulWidget {
  final String characterId;

  final EdgeInsets padding;
  final List<int> bucketHashes;

  final int currentGroup;

  final bool shrinkWrap;

  final bool includeInfoHeader;

  final bool fixedSizedEquipmentBuckets;

  final OnBucketOptionsChanged onBucketOptionsChanged;

  final int columnCount;

  const ItemListWidget({
    Key key,
    this.padding,
    this.bucketHashes,
    this.characterId,
    this.includeInfoHeader = true,
    this.shrinkWrap = false,
    this.columnCount = 1,
    this.currentGroup,
    this.fixedSizedEquipmentBuckets = false,
    this.onBucketOptionsChanged,
  }) : super(key: key);
  @override
  ItemListWidgetState createState() => ItemListWidgetState();
}

class ItemListWidgetState extends State<ItemListWidget>
    with AutomaticKeepAliveClientMixin, UserSettingsConsumer, ProfileConsumer, ManifestConsumer, SelectionConsumer {
  Map<int, DestinyInventoryBucketDefinition> bucketDefs;
  List<ListBucket> buckets;
  StreamSubscription<List<ItemWithOwner>> selectionSubscription;
  bool isSelectionOpen = false;

  bool suppressEmptySpaces(bucketHash) => _suppressEmptySpaces?.contains(bucketHash) ?? false;

  bool isFullWidthBucket(bucketHash) => _fullWidthBuckets?.contains(bucketHash) ?? false;

  @override
  void initState() {
    super.initState();
    buildIndex();
    profile.addListener(buildIndex);
    selectionSubscription = selection.broadcaster.listen((event) {
      setState(() {
        isSelectionOpen = event.isNotEmpty;
      });
    });
  }

  @override
  dispose() {
    profile.removeListener(buildIndex);
    selectionSubscription.cancel();
    super.dispose();
  }

  buildIndex() async {
    if (!mounted) return;
    List<DestinyItemComponent> equipment = profile.getCharacterEquipment(widget.characterId);
    List<DestinyItemComponent> characterInventory = profile.getCharacterInventory(widget.characterId);
    List<DestinyItemComponent> profileInventory = profile.getProfileInventory();
    bucketDefs = await manifest.getDefinitions<DestinyInventoryBucketDefinition>(widget.bucketHashes);
    buckets = [];
    for (int bucketHash in widget.bucketHashes) {
      DestinyInventoryBucketDefinition bucketDef = bucketDefs[bucketHash];
      List<DestinyItemComponent> inventory =
          bucketDef?.scope == BucketScope.Character ? characterInventory : profileInventory;
      DestinyItemComponent equipped = equipment.firstWhere((item) => item.bucketHash == bucketHash, orElse: () => null);
      List<DestinyItemComponent> unequipped = inventory.where((item) => item.bucketHash == bucketHash).toList();
      unequipped = (await InventoryUtils.sortDestinyItems(unequipped.map((i) => ItemWithOwner(i, null))))
          .map((i) => i.item)
          .toList();

      buckets.add(ListBucket(bucketHash: bucketHash, equipped: equipped, unequipped: unequipped));
    }

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return (buckets?.length ?? 0) == 0 ? buildLoading(context) : buildList(context);
  }

  Widget buildLoading(BuildContext context) => LoadingAnimWidget();

  Widget buildList(BuildContext context) {
    return Container(
        child: MultiSectionScrollView(
      _sections,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
    ));
  }

  List<ScrollableSection> get _sections {
    List<ScrollableSection> list = [
      if (widget.includeInfoHeader) buildCharInfoSliver(),
    ];
    for (var bucket in buckets) {
      final bucketDef = bucketDefs[bucket.bucketHash];
      final options = getBucketOptions(bucket.bucketHash);
      final bool showEquipped = bucket.equipped != null && options.type != BucketDisplayType.Hidden;
      final bool showUnequipped = ![BucketDisplayType.Hidden, BucketDisplayType.OnlyEquipped].contains(options.type) &&
          ((bucket.unequipped?.isNotEmpty ?? false) || bucketDef.hasTransferDestination);
      final bool addSpacer = showEquipped || showUnequipped;
      list += [
        buildBucketHeaderSliver(bucket),
        if (showEquipped) buildEquippedItem(bucket.equipped),
        if (showUnequipped) buildUnequippedItems(bucket.unequipped, bucket),
        if (addSpacer) spacer
      ];
    }

    if (isSelectionOpen) {
      list += [
        FixedHeightScrollSection(
          160,
          itemCount: 1,
          itemBuilder: (context, index) => Container(),
        ),
      ];
    }

    return list;
  }

  ScrollableSection buildCharInfoSliver() {
    return FixedHeightScrollSection(
      112,
      itemCount: 1,
      itemBuilder: (context, _) => CharacterInfoWidget(
        key: Key("characterinfo_${widget.characterId}"),
        characterId: widget.characterId,
      ),
    );
  }

  ScrollableSection buildBucketHeaderSliver(ListBucket bucket) {
    final itemCount = (bucket.equipped != null ? 1 : 0) + (bucket.unequipped?.length ?? 0);
    return FixedHeightScrollSection(
      40,
      itemBuilder: (context, _) => BucketHeaderWidget(
          key: Key("bucketheader_${widget.characterId}_${bucket.bucketHash}"),
          presentationNodeHash: bucket.bucketHash,
          itemCount: itemCount,
          isEquippable: bucket.equipped != null,
          onChanged: () {
            if (widget.onBucketOptionsChanged != null) {
              widget.onBucketOptionsChanged();
            }
            if (mounted) {
              setState(() {});
            }
          }),
      itemCount: 1,
    );
  }

  ScrollableSection buildEquippedItem(DestinyItemComponent item) {
    String itemKey = "equipped_${item?.itemInstanceId ?? item?.itemHash ?? 'empty'}";
    final bucketOptions = getBucketOptions(item.bucketHash);
    return FixedHeightScrollSection(
      bucketOptions.equippedItemHeight,
      itemBuilder: (context, _) => InventoryItemWrapperWidget(
        item != null ? ItemWithOwner(item, widget.characterId) : null,
        item?.bucketHash,
        key: Key(itemKey),
        characterId: widget.characterId,
      ),
      itemCount: 1,
    );
  }

  BucketDisplayOptions getBucketOptions(int bucketHash) {
    return userSettings.getDisplayOptionsForItemSection("$bucketHash");
  }

  int getItemCountPerRow(BuildContext context, BucketDisplayOptions bucketOptions) {
    return bucketOptions.responsiveUnequippedItemsPerRow(context, widget.columnCount);
  }

  ScrollableSection buildUnequippedItems(List<DestinyItemComponent> items, ListBucket bucket) {
    final bucketDef = bucketDefs[bucket.bucketHash];
    final bucketOptions = getBucketOptions(bucket.bucketHash);
    final maxSlots = bucketDef?.itemCount != null ? (bucketDef.itemCount - 1) : items.length;
    final itemsPerRow = getItemCountPerRow(context, bucketOptions);
    int bucketSize = maxSlots;
    if (bucketDef == null) {
      logger.info(bucket.bucketHash);
    }
    if (!bucketDef.hasTransferDestination || suppressEmptySpaces(bucket.bucketHash)) {
      bucketSize = (items.length / itemsPerRow).ceil() * itemsPerRow;
    }
    if (bucketDef.hasTransferDestination && bucketOptions.type == BucketDisplayType.Large) {
      bucketSize = (items.length + 1).clamp(0, bucketSize);
    }
    final contentDensity = {
      BucketDisplayType.Large: ContentDensity.FULL,
      BucketDisplayType.Medium: ContentDensity.MEDIUM,
      BucketDisplayType.Small: ContentDensity.MINIMAL,
    }[bucketOptions.type];

    return FixedHeightScrollSection(
      bucketOptions.unequippedItemHeight,
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return InventoryItemWrapperWidget(
            null,
            bucket.bucketHash,
            characterId: widget.characterId,
          );
        }
        final item = items[index];
        final itemKey = "equipped_${item?.itemInstanceId ?? item?.itemHash ?? 'empty'}";
        return InventoryItemWrapperWidget(
          item != null ? ItemWithOwner(item, widget.characterId) : null,
          item?.bucketHash,
          key: Key(itemKey),
          characterId: widget.characterId,
          density: contentDensity,
        );
      },
      itemCount: bucketSize,
      itemsPerRow: itemsPerRow,
    );
  }

  ScrollableSection get spacer => FixedHeightScrollSection(
        76.0,
        itemBuilder: (context, _) => Container(),
        itemCount: 1,
      );

  @override
  bool get wantKeepAlive => true;
}

class ListBucket {
  final int bucketHash;
  final DestinyItemComponent equipped;
  final List<DestinyItemComponent> unequipped;

  ListBucket({this.bucketHash, this.equipped, this.unequipped});
}
