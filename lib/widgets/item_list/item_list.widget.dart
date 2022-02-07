// @dart=2.9

import 'dart:async';

import 'package:bungie_api/enums/bucket_scope.dart';
import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/notification/notification.package.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/services/selection/selection.consumer.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/item_list/character_info.widget.dart';
import 'package:little_light/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/widgets/multisection_scrollview/sliver_section.dart';

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

typedef void OnBucketOptionsChanged();

class ItemListWidget extends StatefulWidget {
  final String characterId;

  final EdgeInsets padding;
  final List<int> bucketHashes;

  final int currentGroup;

  final bool shrinkWrap;

  final bool includeInfoHeader;

  final bool fixedSizedEquipmentBuckets;

  final OnBucketOptionsChanged onBucketOptionsChanged;

  ItemListWidget(
      {this.padding,
      this.bucketHashes,
      this.characterId,
      this.includeInfoHeader = true,
      this.shrinkWrap = false,
      Key key,
      this.currentGroup,
      this.fixedSizedEquipmentBuckets = false,
      this.onBucketOptionsChanged})
      : super(key: key);
  @override
  ItemListWidgetState createState() => new ItemListWidgetState();
}

class ItemListWidgetState extends State<ItemListWidget>
    with
        AutomaticKeepAliveClientMixin,
        UserSettingsConsumer,
        ProfileConsumer,
        ManifestConsumer,
        NotificationConsumer,
        SelectionConsumer {
  Map<int, DestinyInventoryBucketDefinition> bucketDefs;
  List<ListBucket> buckets;
  StreamSubscription<NotificationEvent> notificationsSubscription;
  StreamSubscription<List<ItemWithOwner>> selectionSubscription;
  bool isSelectionOpen = false;

  bool suppressEmptySpaces(bucketHash) => _suppressEmptySpaces?.contains(bucketHash) ?? false;

  bool isFullWidthBucket(bucketHash) => _fullWidthBuckets?.contains(bucketHash) ?? false;

  @override
  void initState() {
    super.initState();
    buildIndex();
    notificationsSubscription = notifications.listen((event) {
      if (event.type == NotificationType.receivedUpdate || event.type == NotificationType.localUpdate) {
        buildIndex();
      }
    });
    selectionSubscription = selection.broadcaster.listen((event) {
      setState(() {
        isSelectionOpen = event.isNotEmpty;
      });
    });
  }

  @override
  dispose() {
    notificationsSubscription.cancel();
    selectionSubscription.cancel();
    super.dispose();
  }

  buildIndex() async {
    if (!mounted) return;
    List<DestinyItemComponent> equipment = profile.getCharacterEquipment(widget.characterId);
    List<DestinyItemComponent> characterInventory = profile.getCharacterInventory(widget.characterId);
    List<DestinyItemComponent> profileInventory = profile.getProfileInventory();
    this.bucketDefs = await manifest.getDefinitions<DestinyInventoryBucketDefinition>(widget.bucketHashes);
    this.buckets = [];
    for (int bucketHash in widget.bucketHashes) {
      DestinyInventoryBucketDefinition bucketDef = bucketDefs[bucketHash];
      List<DestinyItemComponent> inventory =
          bucketDef?.scope == BucketScope.Character ? characterInventory : profileInventory;
      DestinyItemComponent equipped = equipment.firstWhere((item) => item.bucketHash == bucketHash, orElse: () => null);
      List<DestinyItemComponent> unequipped = inventory.where((item) => item.bucketHash == bucketHash).toList();
      unequipped = (await InventoryUtils.sortDestinyItems(unequipped.map((i) => ItemWithOwner(i, null))))
          .map((i) => i.item)
          .toList();

      this.buckets.add(ListBucket(bucketHash: bucketHash, equipped: equipped, unequipped: unequipped));
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

  List<SliverSection> get _sections {
    List<SliverSection> list = [
      if (widget.includeInfoHeader) buildCharInfoSliver(),
    ];
    buckets.forEach((bucket) {
      final options = userSettings.getDisplayOptionsForBucket("${bucket.bucketHash}");
      final bool showEquipped = bucket.equipped != null && options.type != BucketDisplayType.Hidden;
      final bool showUnequipped = (showEquipped || (bucket.unequipped?.length ?? 0) > 0) &&
          ![BucketDisplayType.Hidden, BucketDisplayType.OnlyEquipped].contains(options.type);
      final bool addSpacer = showEquipped || showUnequipped;
      list += [
        buildBucketHeaderSliver(bucket),
        if (showEquipped) buildEquippedItem(bucket.equipped),
        if (showUnequipped) buildUnequippedItems(bucket.unequipped, bucket),
        if (addSpacer) spacer
      ];
    });

    if (isSelectionOpen) {
      list += [SliverSection(itemCount: 1, itemHeight: 160, itemBuilder: (context, index) => Container())];
    }

    return list;
  }

  SliverSection buildCharInfoSliver() {
    return SliverSection(
      itemHeight: 112,
      itemCount: 1,
      itemBuilder: (context, _) => CharacterInfoWidget(
        key: Key("characterinfo_${widget.characterId}"),
        characterId: widget.characterId,
      ),
    );
  }

  SliverSection buildBucketHeaderSliver(ListBucket bucket) {
    final itemCount = (bucket.equipped != null ? 1 : 0) + (bucket.unequipped?.length ?? 0);
    return SliverSection(
        itemBuilder: (context, _) => BucketHeaderWidget(
            key: Key("bucketheader_${widget.characterId}_${bucket.bucketHash}"),
            hash: bucket.bucketHash,
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
        itemHeight: 40);
  }

  SliverSection buildEquippedItem(DestinyItemComponent item) {
    String itemKey = "equipped_${item?.itemInstanceId ?? item?.itemHash ?? 'empty'}";
    final bucketOptions = getBucketOptions(item.bucketHash);
    return SliverSection(
        itemBuilder: (context, _) => InventoryItemWrapperWidget(
              item,
              item?.bucketHash,
              key: Key(itemKey),
              characterId: widget.characterId,
            ),
        itemCount: 1,
        itemHeight: bucketOptions.equippedItemHeight);
  }

  BucketDisplayOptions getBucketOptions(int bucketHash) {
    return userSettings.getDisplayOptionsForBucket("$bucketHash");
  }

  int getItemCountPerRow(BuildContext context, BucketDisplayOptions bucketOptions) {
    return bucketOptions.unequippedItemsPerRow;
  }

  SliverSection buildUnequippedItems(List<DestinyItemComponent> items, ListBucket bucket) {
    final bucketDef = bucketDefs[bucket.bucketHash];
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
          item,
          item?.bucketHash,
          key: Key(itemKey),
          characterId: widget.characterId,
          density: contentDensity,
        );
      },
      itemCount: bucketSize,
      itemHeight: bucketOptions.unequippedItemHeight,
      itemsPerRow: itemsPerRow,
    );
  }

  SliverSection get spacer => SliverSection(
        itemBuilder: (context, _) => Container(),
        itemCount: 1,
        itemHeight: 76,
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
