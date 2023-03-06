// @dart=2.9

import 'dart:async';

import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/pages/item_details/item_details.page_route.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/selection/selection.consumer.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_item_instance.widget.dart';
import 'package:little_light/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/widgets/multisection_scrollview/sliver_section.dart';
import 'package:little_light/widgets/search/search.controller.dart';

extension _GetOrCreate<K, V> on Map<K, V> {
  V getOrCreate(K key, V defaultValue) {
    if (containsKey(key) && this[key] != null) return this[key];
    this[key] = defaultValue;
    return this[key];
  }
}

class _DuplicatedListItem {
  final int itemHash;
  final List<ItemWithOwner> instances;

  _DuplicatedListItem(this.itemHash, this.instances);
}

class _DuplicatedItemsBucket {
  final int bucketHash;
  final List<_DuplicatedListItem> items;

  _DuplicatedItemsBucket(this.bucketHash, this.items);
}

class DuplicatedItemListWidget extends StatefulWidget {
  final SearchController searchController;
  const DuplicatedItemListWidget({Key key, this.searchController}) : super(key: key);

  @override
  DuplicatedItemListWidgetState createState() => DuplicatedItemListWidgetState();
}

class DuplicatedItemListWidgetState extends State<DuplicatedItemListWidget>
    with AutomaticKeepAliveClientMixin, SelectionConsumer, ManifestConsumer {
  List<_DuplicatedItemsBucket> duplicatedItemBuckets;

  @override
  initState() {
    super.initState();
    widget.searchController?.addListener(update);
  }

  @override
  dispose() {
    super.dispose();
    widget.searchController?.removeListener(update);
  }

  void update() async {
    if (widget.searchController.filtered == null) return;
    Map<int, Map<int, List<ItemWithOwner>>> _buckets = {};
    var items = widget.searchController.filtered;

    for (final item in items) {
      final itemHash = item.item.itemHash;
      final itemDef = await manifest.getDefinition<DestinyInventoryItemDefinition>(itemHash);
      final bucketHash = itemDef.inventory.bucketTypeHash;
      _buckets.getOrCreate(bucketHash, <int, List<ItemWithOwner>>{}).getOrCreate(itemHash, <ItemWithOwner>[]).add(item);
    }

    _buckets.forEach((hash, duplicates) {
      duplicates.removeWhere((key, value) => value.length < 2);
    });
    _buckets.removeWhere((key, value) => value.isEmpty);

    final orderedBucketHashes = _buckets.keys;

    duplicatedItemBuckets = [];
    for (final bucketHash in orderedBucketHashes) {
      final mappedItems = _buckets[bucketHash];
      final duplicatedItems = mappedItems
          .map((hash, items) => MapEntry<int, _DuplicatedListItem>(hash, _DuplicatedListItem(hash, items)))
          .values
          .toList();
      final itemBucket = _DuplicatedItemsBucket(bucketHash, duplicatedItems);
      duplicatedItemBuckets.add(itemBucket);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (duplicatedItemBuckets == null) {
      return LoadingAnimWidget();
    }

    return MultiSectionScrollView(
      sections,
      padding: const EdgeInsets.all(4),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
    );
  }

  List<SliverSection> get sections {
    final List<SliverSection> _sections = [];
    for (final bucket in duplicatedItemBuckets) {
      _sections.add(buildHeaderSliver(bucket));
      for (final duplicated in bucket.items) {
        _sections.add(buildDuplicateSliver(duplicated));
        _sections.add(buildDuplicateInstancesSliver(duplicated));
        _sections.add(buildSpacer());
      }
    }
    return _sections;
  }

  SliverSection buildHeaderSliver(_DuplicatedItemsBucket bucket) {
    return SliverSection(
        itemHeight: 40,
        itemCount: 1,
        itemBuilder: (context, _) => HeaderWidget(
              alignment: Alignment.centerLeft,
              child: ManifestText<DestinyInventoryBucketDefinition>(
                bucket.bucketHash,
                uppercase: true,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ));
  }

  SliverSection buildDuplicateSliver(_DuplicatedListItem duplicate) {
    return SliverSection(
      itemHeight: 96,
      itemCount: 1,
      itemBuilder: (context, _) => _DefinitionItemWrapper(duplicate.itemHash, duplicate.instances),
    );
  }

  SliverSection buildDuplicateInstancesSliver(_DuplicatedListItem duplicate) {
    final itemsPerRow = MediaQueryHelper(context).responsiveValue(2, tablet: 3, laptop: 6);
    return SliverSection(
        itemHeight: 132,
        itemCount: duplicate.instances.length,
        itemsPerRow: itemsPerRow,
        itemBuilder: (context, index) {
          final item = duplicate.instances[index];
          return DefinitionProviderWidget<DestinyInventoryItemDefinition>(
              item.item.itemHash,
              (def) => _ItemInstanceWrapper(
                    item: item,
                    definition: def,
                  ),
              key: Key("item_${item.item.itemHash}_${item.item.itemInstanceId}_${item.ownerId}"));
        });
  }

  SliverSection buildSpacer() {
    return SliverSection(itemHeight: 40, itemCount: 1, itemBuilder: (context, index) => Container());
  }

  @override
  bool get wantKeepAlive => true;
}

class _DefinitionItemWrapper extends StatefulWidget {
  final int hash;
  final List<ItemWithOwner> items;
  const _DefinitionItemWrapper(this.hash, this.items);
  @override
  State<StatefulWidget> createState() {
    return _DefinitionItemWrapperState();
  }
}

class _DefinitionItemWrapperState extends State<_DefinitionItemWrapper> with SelectionConsumer {
  bool get selected => widget.items.every((i) {
        return selection.isSelected(i);
      });

  @override
  void initState() {
    super.initState();

    StreamSubscription<List<ItemWithOwner>> sub;
    sub = selection.broadcaster.listen((selectedItems) {
      if (!mounted) {
        sub.cancel();
        return;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(key: Key("itemdef_${widget.hash}"), children: [
      DefinitionProviderWidget<DestinyInventoryItemDefinition>(
          widget.hash,
          (def) => BaseInventoryItemWidget(
                null,
                def,
                null,
                characterId: null,
                uniqueId: null,
              )),
      selected
          ? Positioned.fill(
              child: Container(
                foregroundDecoration: BoxDecoration(border: Border.all(color: Colors.lightBlue.shade400, width: 2)),
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
        onLongPress: () => onTap(context),
      ),
    );
  }

  void onTap(context) {
    if (selected) {
      for (var item in widget.items) {
        selection.removeItem(item);
      }
    } else {
      selection.activateMultiSelect();
      for (var item in widget.items) {
        if (!selection.isSelected(item)) {
          selection.addItem(item);
        }
      }
    }
  }
}

class _ItemInstanceWrapper extends StatefulWidget {
  final ItemWithOwner item;
  final DestinyInventoryItemDefinition definition;

  const _ItemInstanceWrapper({Key key, this.item, this.definition}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ItemInstanceWrapperState();
  }
}

class _ItemInstanceWrapperState extends State<_ItemInstanceWrapper>
    with UserSettingsConsumer, ProfileConsumer, SelectionConsumer {
  DestinyItemInstanceComponent instance;
  bool get selected => selection.isSelected(widget.item);

  @override
  void initState() {
    super.initState();

    instance = profile.getInstanceInfo(widget.item.item.itemInstanceId);

    StreamSubscription<List<ItemWithOwner>> sub;
    sub = selection.broadcaster.listen((selectedItems) {
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
          child: BaseItemInstanceWidget(widget.item.item, widget.definition, instance,
              characterId: widget.item.ownerId, uniqueId: null)),
      selected
          ? Positioned.fill(
              child: Container(
                foregroundDecoration: BoxDecoration(border: Border.all(color: Colors.lightBlue.shade400, width: 2)),
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
    if (selection.multiselectActivated) {
      onLongPress(context);
      return;
    }
    if (userSettings.tapToSelect) {
      selection.setItem(ItemWithOwner(widget.item.item, widget.item.ownerId));
      return;
    }
    selection.clear();
    Navigator.push(
      context,
      ItemDetailsPageRoute(
        item: widget.item,
      ),
    );
  }

  void onLongPress(context) {
    if (widget.definition.nonTransferrable) return;
    selection.activateMultiSelect();
    selection.addItem(widget.item);
    setState(() {});
  }
}
