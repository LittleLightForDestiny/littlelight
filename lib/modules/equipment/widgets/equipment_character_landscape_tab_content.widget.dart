import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/progress/widgets/bucket_header_list_item.widget.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/blocs/bucket_options/bucket_options.bloc.dart';
import 'package:little_light/shared/blocs/bucket_options/global_key_holder.dart';
import 'package:little_light/shared/utils/extensions/bucket_display_type_data.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/character/character_info.widget.dart';
import 'package:little_light/shared/widgets/inventory_item/empty_item.dart';
import 'package:little_light/shared/widgets/inventory_item/interactive_item_wrapper.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item.dart';
import 'package:little_light/shared/widgets/inventory_item/quick_transfer_item.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sections/intrinsic_height_scrollable_section.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sliver_section.dart';
import 'package:provider/provider.dart';

import 'equipment_character_bucket_content.dart';

const _defaultDisplayTypes = {
  InventoryBucket.engrams: BucketDisplayType.Small,
  InventoryBucket.lostItems: BucketDisplayType.Small,
  InventoryBucket.consumables: BucketDisplayType.Small,
  InventoryBucket.modifications: BucketDisplayType.Small,
};

const _characterInfoHeight = 128.0;
const _bucketHeaderHeight = 48.0;

class EquipmentCharacterLandscapeTabContentWidget extends StatelessWidget {
  final DestinyCharacterInfo character;
  final List<DestinyItemComponent>? currencies;
  final Key? scrollViewKey;
  final Map<int, EquipmentCharacterBucketContent> buckets;

  ItemSectionOptionsBloc bucketOptionsState(BuildContext context) => context.watch<ItemSectionOptionsBloc>();

  const EquipmentCharacterLandscapeTabContentWidget(
    this.character, {
    Key? key,
    required this.buckets,
    this.currencies,
    this.scrollViewKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        key: Key("character_tab_${character.characterId}"),
        builder: (context, constraints) => MultiSectionScrollView(
              [
                FixedHeightScrollSection(
                  _characterInfoHeight,
                  itemBuilder: (context, _) => CharacterInfoWidget(
                    character,
                    currencies: currencies,
                  ),
                ),
                buildMultiColumnSection(context, [InventoryBucket.subclass, InventoryBucket.helmet], constraints),
                buildMultiColumnSection(
                    context, [InventoryBucket.kineticWeapons, InventoryBucket.gauntlets], constraints),
                buildMultiColumnSection(
                    context, [InventoryBucket.energyWeapons, InventoryBucket.chestArmor], constraints),
                buildMultiColumnSection(context, [InventoryBucket.powerWeapons, InventoryBucket.legArmor], constraints),
                buildMultiColumnSection(context, [InventoryBucket.ghost, InventoryBucket.classArmor], constraints),
                buildMultiColumnSection(
                    context,
                    [
                      InventoryBucket.vehicle,
                      InventoryBucket.ships,
                      InventoryBucket.emblems,
                    ],
                    constraints),
                ...buildSingleColumnSections(context, InventoryBucket.consumables, constraints),
                ...buildSingleColumnSections(context, InventoryBucket.modifications, constraints),
              ],
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
              padding: const EdgeInsets.all(8).copyWith(top: 0, bottom: 64) +
                  EdgeInsets.only(
                    left: context.mediaQuery.padding.left,
                    right: context.mediaQuery.padding.right,
                  ),
              scrollViewKey: scrollViewKey,
            ));
  }

  ScrollableSection buildMultiColumnSection(BuildContext context, List<int> bucketHashes, BoxConstraints constraints) {
    final columnWidth = constraints.maxWidth / bucketHashes.length;
    return IntrinsicHeightScrollSection(
      itemBuilder: (context, index) {
        final bucketHash = bucketHashes[index];
        final bucket = buckets[bucketHash];
        if (bucket == null) return Container();
        return Builder(builder: (context) => buildShrinkwrapBucket(context, bucketHash, columnWidth));
      },
      itemCount: bucketHashes.length,
      itemsPerRow: bucketHashes.length,
      additionalCrossAxisSpacing: 8,
    );
  }

  List<ScrollableSection> buildSingleColumnSections(
    BuildContext context,
    int bucketHash,
    BoxConstraints constraints,
  ) {
    final bucketContent = buckets[bucketHash];
    if (bucketContent == null) return [];
    final equipped = bucketContent.equipped;
    final unequipped = bucketContent.unequipped;
    final defaultDisplayType = _defaultDisplayTypes[bucketHash] ?? BucketDisplayType.Medium;
    final displayType = bucketOptionsState(context).getDisplayTypeForItemSection(
      "$bucketHash",
      defaultValue: defaultDisplayType,
    );
    final bucketDef = context.definition<DestinyInventoryBucketDefinition>(bucketHash);
    final equippedDensity = displayType.equippedDensity;
    final unequippedDensity = displayType.unequippedDensity;
    final useBucketCount = bucketDef?.hasTransferDestination == true && bucketDef?.scope == BucketScope.Character;
    final bucketDefCount = (bucketDef?.itemCount ?? 10) - (equipped != null ? 1 : 0);
    final idealCount = unequippedDensity?.getIdealCount(constraints.maxWidth) ?? 5;
    final unequippedCount = ((useBucketCount ? bucketDefCount : unequipped.length) / idealCount).ceil() * idealCount;
    final key = "${character.characterId} $bucketHash";
    return [
      FixedHeightScrollSection(
        _bucketHeaderHeight,
        itemCount: 1,
        itemBuilder: (_, __) => BucketHeaderListItemWidget(
          bucketHash,
          menuGlobalKey: context.getGlobalKeyFor(key),
          canEquip: equipped != null,
          itemCount: bucketContent.unequipped.length + (bucketContent.equipped != null ? 1 : 0),
          defaultType: defaultDisplayType,
        ),
      ),
      if (equipped != null)
        buildItemSection(
          context,
          bucketContent,
          [equipped],
          equippedDensity,
          1,
          1,
          1,
          false,
        ),
      if (unequippedDensity != null)
        buildItemSection(
          context,
          bucketContent,
          unequipped,
          unequippedDensity,
          idealCount,
          unequippedCount,
          bucketDefCount,
          bucketDef?.hasTransferDestination == true,
        ),
    ].whereType<ScrollableSection>().toList();
  }

  ScrollableSection? buildItemSection(
    BuildContext context,
    EquipmentCharacterBucketContent bucketContent,
    List<DestinyItemInfo> items,
    InventoryItemWidgetDensity? density,
    int itemsPerRow,
    int itemCount,
    int bucketCount,
    bool canTransfer,
  ) {
    if (density == null) return null;
    final itemHeight = density.itemHeight;
    if (itemHeight != null) {
      return FixedHeightScrollSection(
        itemHeight + 4,
        itemCount: itemCount,
        itemsPerRow: itemsPerRow,
        itemBuilder: (_, index) {
          if (index < items.length) {
            return buildItem(context, items[index], density);
          }
          final bucketHash = bucketContent.bucketHash;
          final characterId = character.characterId;
          if (canTransfer && index < bucketCount && characterId != null) {
            return QuickTransferItem(
              bucketHash: bucketHash,
              characterId: characterId,
            );
          }
          return EmptyItem(
            bucketHash: bucketContent.bucketHash,
            density: density,
          );
        },
      );
    }
    final itemAspectRatio = density.itemAspectRatio;
    if (itemAspectRatio != null) {
      return AspectRatioScrollSection(
        itemAspectRatio,
        itemsPerRow: itemsPerRow,
        itemCount: itemCount,
        itemBuilder: (_, index) {
          if (index < items.length) {
            return buildItem(context, items[index], density);
          }
          final characterId = character.characterId;
          if (canTransfer && index < bucketCount && characterId != null) {
            return QuickTransferItem(
              bucketHash: bucketContent.bucketHash,
              characterId: characterId,
            );
          }
          return EmptyItem(
            bucketHash: bucketContent.bucketHash,
            density: density,
          );
        },
      );
    }
    return null;
  }

  Widget buildShrinkwrapBucket(BuildContext context, int bucketHash, double columnWidth) {
    final bucketContent = buckets[bucketHash];
    if (bucketContent == null) return Container();
    final equipped = bucketContent.equipped;
    final unequipped = bucketContent.unequipped;
    final defaultDisplayType = _defaultDisplayTypes[bucketHash] ?? BucketDisplayType.Medium;
    final displayType = bucketOptionsState(context).getDisplayTypeForItemSection(
      "$bucketHash",
      defaultValue: defaultDisplayType,
    );
    final bucketDef = context.definition<DestinyInventoryBucketDefinition>(bucketHash);
    final equippedDensity = displayType.equippedDensity;
    final unequippedDensity = displayType.unequippedDensity;
    final bucketDefCount = (bucketDef?.itemCount ?? 10) - (equipped != null ? 1 : 0);
    final idealCount = unequippedDensity?.getIdealCount(columnWidth) ?? 5;
    final unequippedCount = ((bucketDefCount) / idealCount).ceil() * idealCount;
    final key = "${character.characterId} $bucketHash";
    return Column(children: [
      Container(
        height: _bucketHeaderHeight,
        child: BucketHeaderListItemWidget(
          bucketHash,
          menuGlobalKey: context.getGlobalKeyFor(key),
          canEquip: equipped != null,
          itemCount: bucketContent.unequipped.length + (bucketContent.equipped != null ? 1 : 0),
          defaultType: defaultDisplayType,
        ),
      ),
      if (equipped != null)
        buildShrinkwrapItemSection(
          context,
          bucketContent,
          [equipped],
          equippedDensity,
          1,
          1,
          1,
          false,
        ),
      if (unequippedDensity != null)
        buildShrinkwrapItemSection(
          context,
          bucketContent,
          unequipped,
          unequippedDensity,
          idealCount,
          unequippedCount,
          bucketDefCount,
          bucketDef?.hasTransferDestination == true,
        ),
    ]);
  }

  Widget buildShrinkwrapItemSection(
    BuildContext context,
    EquipmentCharacterBucketContent bucketContent,
    List<DestinyItemInfo> items,
    InventoryItemWidgetDensity? density,
    int itemsPerRow,
    int itemCount,
    int bucketCount,
    bool canTransfer,
  ) {
    if (density == null) return Container();
    final itemHeight = density.itemHeight;
    final itemAspectRatio = density.itemAspectRatio;
    final itemWidgets = List.generate(itemCount, (index) {
      final item = index < items.length ? items[index] : null;
      return buildShrinkwrapItem(
        context,
        item,
        density,
        bucketHash: bucketContent.bucketHash,
        canTransfer: canTransfer,
        index: index,
        bucketCount: bucketCount,
      );
    });
    final itemRows = itemWidgets.slices(itemsPerRow);

    if (itemHeight != null) {
      return Column(
        children: itemRows.map((rowItems) {
          return Row(
              children: rowItems.map((item) {
            return Expanded(
              child: Container(
                height: itemHeight + 4,
                child: item,
              ),
            );
          }).toList());
        }).toList(),
      );
    }
    if (itemAspectRatio != null) {
      return Column(
        children: itemRows.map((rowItems) {
          return Row(
              children: rowItems.map((item) {
            return Expanded(
              child: AspectRatio(
                aspectRatio: itemAspectRatio,
                child: item,
              ),
            );
          }).toList());
        }).toList(),
      );
    }

    return Container();
  }

  Widget buildShrinkwrapItem(
    BuildContext context,
    DestinyItemInfo? item,
    InventoryItemWidgetDensity density, {
    bool canTransfer = false,
    int index = 0,
    int bucketCount = 0,
    int? bucketHash,
  }) {
    if (item != null) {
      return buildItem(context, item, density);
    }
    final characterId = character.characterId;
    if (canTransfer && index < bucketCount && characterId != null && bucketHash != null) {
      return QuickTransferItem(
        bucketHash: bucketHash,
        characterId: characterId,
      );
    }
    return EmptyItem(
      bucketHash: bucketHash,
      density: density,
    );
  }

  Widget buildItem(BuildContext context, DestinyItemInfo item, InventoryItemWidgetDensity density) {
    return InteractiveItemWrapper(
      InventoryItemWidget(
        item,
        density: density,
      ),
      item: item,
      density: density,
    );
  }
}
