// @dart=2.9

import 'dart:async';

import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/widgets/item_list/character_info.widget.dart';
import 'package:little_light/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/widgets/multisection_scrollview/sliver_section.dart';
import 'package:little_light/widgets/progress_tabs/pursuit_category_header.widget.dart';
import 'package:little_light/widgets/progress_tabs/pursuit_item/large_pursuit_item.widget.dart';
import 'package:little_light/widgets/progress_tabs/pursuit_item/pursuit_item.widget.dart';
import 'package:little_light/widgets/progress_tabs/pursuit_item/small_pursuit_item.widget.dart';

class _PursuitCategory {
  final int nameHash;
  final String customLabel;
  final List<DestinyItemComponent> items;
  final String categoryID;

  _PursuitCategory({this.nameHash, this.customLabel, this.items, this.categoryID});
}

extension PursuitLayoutOptions on BucketDisplayOptions {
  double get itemHeight {
    switch (type) {
      case BucketDisplayType.Hidden:
      case BucketDisplayType.OnlyEquipped:
        return 0;
      case BucketDisplayType.Large:
        return 150;
      case BucketDisplayType.Medium:
        return 132;
        break;
      case BucketDisplayType.Small:
        return null;
    }
    return null;
  }

  int get itemsPerRow {
    switch (type) {
      case BucketDisplayType.Hidden:
      case BucketDisplayType.OnlyEquipped:
        return 1;
      case BucketDisplayType.Large:
        return 1;
      case BucketDisplayType.Medium:
        return 2;
      case BucketDisplayType.Small:
        return 5;
    }
    return 1;
  }

  int get itemsPerRowTablet {
    switch (type) {
      case BucketDisplayType.Hidden:
      case BucketDisplayType.OnlyEquipped:
        return 1;
      case BucketDisplayType.Large:
        return 2;
      case BucketDisplayType.Medium:
        return 5;
      case BucketDisplayType.Small:
        return 10;
    }
    return 1;
  }

  int get itemsPerRowDesktop {
    switch (type) {
      case BucketDisplayType.Hidden:
      case BucketDisplayType.OnlyEquipped:
        return 1;
      case BucketDisplayType.Large:
        return 3;
      case BucketDisplayType.Medium:
        return 6;
      case BucketDisplayType.Small:
        return 15;
    }
    return 1;
  }
}

class CharacterPursuitsListWidget extends StatefulWidget {
  final String characterId;

  const CharacterPursuitsListWidget({Key key, this.characterId}) : super(key: key);

  @override
  _CharacterPursuitsListWidgetState createState() => _CharacterPursuitsListWidgetState();
}

class _CharacterPursuitsListWidgetState extends State<CharacterPursuitsListWidget>
    with AutomaticKeepAliveClientMixin, UserSettingsConsumer, ProfileConsumer, ManifestConsumer {
  List<_PursuitCategory> categories;
  bool fullyLoaded = false;

  @override
  void initState() {
    super.initState();
    getPursuits();
    profile.addListener(getPursuits);
  }

  @override
  dispose() {
    profile.removeListener(getPursuits);
    super.dispose();
  }

  Future<void> getPursuits() async {
    var allItems = profile.getCharacterInventory(widget.characterId);
    var pursuits = allItems.where((i) => i.bucketHash == InventoryBucket.pursuits).toList();
    var pursuitHashes = pursuits.map((i) => i.itemHash);
    var defs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(pursuitHashes);
    pursuits = (await InventoryUtils.sortDestinyItems(pursuits.map((p) => ItemWithOwner(p, null)),
            sortingParams: userSettings.pursuitOrdering))
        .map((i) => i.item)
        .toList();

    List<DestinyItemComponent> questSteps = [];
    List<DestinyItemComponent> bounties = [];
    Map<String, List<DestinyItemComponent>> other = {};

    for (var p in pursuits) {
      var def = defs[p.itemHash];
      if (def?.itemCategoryHashes?.contains(16) ?? false) {
        questSteps.add(p);
        return;
      }
      if ((def?.itemCategoryHashes?.contains(1784235469) ?? false) ||
          (def?.inventory?.stackUniqueLabel?.contains("bounties") ?? false)) {
        bounties.add(p);
        return;
      }
      if (other[def.itemTypeDisplayName] == null) {
        other[def.itemTypeDisplayName] = [];
      }
      other[def.itemTypeDisplayName].add(p);
    }

    categories = <_PursuitCategory>[];

    if (bounties.isNotEmpty) {
      categories.add(_PursuitCategory(nameHash: 1784235469, items: bounties, categoryID: "pursuits_1784235469_null"));
    }

    if (questSteps.isNotEmpty) {
      categories.add(_PursuitCategory(nameHash: 53, items: questSteps, categoryID: "pursuits_53_null"));
    }

    other?.forEach((category, items) {
      categories.add(_PursuitCategory(customLabel: category, items: items, categoryID: "pursuits_null_$category"));
    });

    if (mounted) {
      setState(() {});
      fullyLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
        child: MultiSectionScrollView(
      _sections,
      padding: const EdgeInsets.all(4),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
    ));
  }

  List<SliverSection> get _sections {
    List<SliverSection> list = [
      buildCharInfoSliver(),
    ];
    if (categories == null) return list;
    for (var category in categories) {
      final options = userSettings.getDisplayOptionsForBucket(category.categoryID);
      final categoryVisible = ![BucketDisplayType.Hidden, BucketDisplayType.OnlyEquipped].contains(options.type);
      list += [
        buildCategoryHeaderSliver(category),
        if (categoryVisible) buildPursuitItemsSliver(category, options),
      ];
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

  SliverSection buildCategoryHeaderSliver(_PursuitCategory category) {
    return SliverSection(
        itemBuilder: (context, _) => PursuitCategoryHeaderWidget(
              hash: category.nameHash,
              label: category.customLabel,
              itemCount: category.items.length,
              onChanged: () {
                setState(() {});
              },
            ),
        itemCount: 1,
        itemHeight: 40);
  }

  SliverSection buildPursuitItemsSliver(_PursuitCategory category, BucketDisplayOptions options) {
    final itemsPerRow = MediaQueryHelper(context).responsiveValue<int>(
      options.itemsPerRow,
      tablet: options.itemsPerRowTablet,
      desktop: options.itemsPerRowDesktop,
    );
    return SliverSection(
        itemBuilder: (context, index) {
          final item = category.items[index];
          return buildPursuitItem(item, options);
        },
        itemsPerRow: itemsPerRow,
        itemCount: category.items.length,
        itemHeight: options.itemHeight);
  }

  Widget buildPursuitItem(DestinyItemComponent item, BucketDisplayOptions options) {
    switch (options.type) {
      case BucketDisplayType.Hidden:
      case BucketDisplayType.OnlyEquipped:
        return Container();
      case BucketDisplayType.Large:
        return LargePursuitItemWidget(
            item: ItemWithOwner(item, widget.characterId),
            selectable: true,
            key: Key("pursuits_${item?.itemHash}_${item?.itemInstanceId}_${widget.characterId}"));
      case BucketDisplayType.Medium:
        return PursuitItemWidget(
            item: ItemWithOwner(item, widget.characterId),
            selectable: true,
            key: Key("pursuits_${item?.itemHash}_${item?.itemInstanceId}_${widget.characterId}"));
      case BucketDisplayType.Small:
        return SmallPursuitItemWidget(
            item: ItemWithOwner(item, widget.characterId),
            selectable: true,
            key: Key("pursuits_${item?.itemHash}_${item?.itemInstanceId}_${widget.characterId}"));
    }
    return PursuitItemWidget(
        item: ItemWithOwner(item, widget.characterId),
        selectable: true,
        key: Key("pursuits_${item?.itemHash}_${item?.itemInstanceId}_${widget.characterId}"));
  }

  @override
  bool get wantKeepAlive => fullyLoaded ?? false;
}
