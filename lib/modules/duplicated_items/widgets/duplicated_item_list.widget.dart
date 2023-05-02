import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/item_info/definition_item_info.dart';
import 'package:little_light/modules/duplicated_items/pages/duplicated_items/duplicated_items.bloc.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';
import 'package:little_light/shared/widgets/inventory_item/duplicated_item.widget.dart';
import 'package:little_light/shared/widgets/inventory_item/high_density_inventory_item.dart';
import 'package:little_light/shared/widgets/inventory_item/interactive_item_wrapper.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sliver_section.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

List<int> _bucketHashesOrder = [
  InventoryBucket.subclass,
  InventoryBucket.kineticWeapons,
  InventoryBucket.energyWeapons,
  InventoryBucket.powerWeapons,
  InventoryBucket.helmet,
  InventoryBucket.gauntlets,
  InventoryBucket.chestArmor,
  InventoryBucket.legArmor,
  InventoryBucket.classArmor,
  InventoryBucket.ghost,
  InventoryBucket.vehicle,
  InventoryBucket.ships,
];

class DuplicatedItemListWidget extends StatelessWidget {
  final ItemsByBucket items;
  final Map<int, DefinitionItemInfo>? genericItems;
  final EdgeInsets? padding;
  final int itemsPerRow;
  const DuplicatedItemListWidget(
    this.items, {
    this.genericItems,
    this.padding,
    this.itemsPerRow = 3,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: MultiSectionScrollView(
        sections(context),
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        padding: padding,
      ),
    );
  }

  List<SliverSection> sections(BuildContext context) {
    return [
      for (final bucketHash in _bucketHashesOrder) ...buildBucketSections(context, bucketHash),
    ];
  }

  List<SliverSection> buildBucketSections(BuildContext context, int bucketHash) {
    final bucketItems = items[bucketHash];
    if (bucketItems == null || bucketItems.isEmpty) return [];
    return [
      buildHeaderSection(context, bucketHash),
      for (final itemHash in bucketItems.keys) ...buildItemType(context, bucketHash, itemHash),
    ];
  }

  SliverSection buildHeaderSection(BuildContext context, int bucketHash) {
    return SliverSection.fixedHeight(
      itemCount: 1,
      itemHeight: 48,
      itemBuilder: (_, __) => HeaderWidget(
        child: ManifestText<DestinyInventoryBucketDefinition>(
          bucketHash,
          uppercase: true,
        ),
      ),
    );
  }

  List<SliverSection> buildItemType(BuildContext context, int bucketHash, int itemHash) {
    final itemInstances = items[bucketHash]?[itemHash];
    if (itemInstances == null || itemInstances.isEmpty) return [];
    return [
      buildItemDefinitionSection(context, itemHash),
      buildItemInstances(context, bucketHash, itemHash),
    ].whereType<SliverSection>().toList();
  }

  SliverSection? buildItemDefinitionSection(BuildContext context, int itemHash) {
    final item = genericItems?[itemHash];
    if (item == null) return null;
    return SliverSection.fixedHeight(
      itemCount: 1,
      itemHeight: 96,
      itemBuilder: (_, __) => InteractiveItemWrapper(
        HighDensityInventoryItem(item),
        item: item,
        itemMargin: 1,
      ),
    );
  }

  SliverSection? buildItemInstances(BuildContext context, int bucketHash, int itemHash) {
    final itemInstances = items[bucketHash]?[itemHash];
    if (itemInstances == null || itemInstances.isEmpty) return null;
    return SliverSection.fixedHeight(
      itemCount: itemInstances.length,
      itemsPerRow: itemsPerRow,
      itemHeight: DuplicatedItemWidget.expectedSize.height,
      itemBuilder: (_, index) => InteractiveItemWrapper(
        DuplicatedItemWidget(itemInstances[index]),
        item: itemInstances[index],
        itemMargin: 1,
      ),
    );
  }
}
