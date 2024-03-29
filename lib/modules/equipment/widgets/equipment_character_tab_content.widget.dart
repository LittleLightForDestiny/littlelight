import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/shared/blocs/bucket_options/bucket_options.bloc.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/blocs/bucket_options/global_key_holder.dart';
import 'package:little_light/shared/utils/extensions/bucket_display_type_data.dart';
import 'package:little_light/shared/widgets/character/character_info.widget.dart';
import 'package:little_light/modules/progress/widgets/bucket_header_list_item.widget.dart';
import 'package:little_light/shared/widgets/inventory_item/empty_item.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item.dart';
import 'package:little_light/shared/widgets/inventory_item/quick_transfer_item.dart';
import 'package:little_light/shared/widgets/inventory_item/interactive_item_wrapper.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
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

class EquipmentCharacterTabContentWidget extends StatelessWidget with ManifestConsumer {
  final DestinyCharacterInfo character;
  final List<EquipmentCharacterBucketContent> buckets;
  final List<DestinyItemComponent>? currencies;
  final Key? scrollViewKey;

  ItemSectionOptionsBloc bucketOptionsState(BuildContext context) => context.watch<ItemSectionOptionsBloc>();

  const EquipmentCharacterTabContentWidget(
    this.character, {
    Key? key,
    required this.buckets,
    this.currencies,
    this.scrollViewKey,
  }) : super(key: key);

  Future<Map<int, DestinyInventoryBucketDefinition>> get bucketDefs async {
    final hashes = buckets.map((e) => e.bucketHash).whereType<int>().toList();
    final defs = await manifest.getDefinitions<DestinyInventoryBucketDefinition>(hashes);
    return defs;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<int, DestinyInventoryBucketDefinition>>(
      future: bucketDefs,
      builder: (context, snapshot) {
        final defs = snapshot.data;
        if (defs == null) {
          return Center(child: LoadingAnimWidget());
        }
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
              for (final bucket in buckets) ...buildBucketSections(context, bucket, constraints)
            ],
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            padding: const EdgeInsets.all(8).copyWith(top: 0, bottom: 64),
            scrollViewKey: scrollViewKey,
          ),
        );
      },
    );
  }

  List<ScrollableSection> buildBucketSections(
    BuildContext context,
    EquipmentCharacterBucketContent bucketContent,
    BoxConstraints constraints,
  ) {
    final equipped = bucketContent.equipped;
    final unequipped = bucketContent.unequipped;
    final bucketHash = bucketContent.bucketHash;
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
        48,
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
