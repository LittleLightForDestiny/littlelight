import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/blocs/bucket_options/bucket_options.bloc.dart';
import 'package:little_light/shared/utils/extensions/bucket_display_type_data.dart';
import 'package:little_light/shared/widgets/character/character_info.widget.dart';
import 'package:little_light/shared/widgets/headers/bucket_header/item_section_header.widget.dart';
import 'package:little_light/shared/widgets/inventory_item/empty_item.dart';
import 'package:little_light/shared/widgets/inventory_item/interactive_item_wrapper.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sliver_section.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';

const _pursuitDisplayOptions = {
  BucketDisplayType.Hidden,
  BucketDisplayType.Large,
  BucketDisplayType.Medium,
  BucketDisplayType.Small,
};

class PursuitCharacterBucketContent {
  final int? categoryHash;
  final List<DestinyItemInfo> items;

  PursuitCharacterBucketContent(
    this.categoryHash, {
    required this.items,
  });
}

const _characterInfoHeight = 128.0;

class PursuitsCharacterTabContentWidget extends StatelessWidget with ManifestConsumer {
  final DestinyCharacterInfo character;
  final List<PursuitCharacterBucketContent> buckets;
  final List<DestinyItemComponent>? currencies;
  final Key? scrollViewKey;

  ItemSectionOptionsBloc bucketOptionsState(BuildContext context) => context.watch<ItemSectionOptionsBloc>();

  const PursuitsCharacterTabContentWidget(
    this.character, {
    Key? key,
    required this.buckets,
    this.currencies,
    this.scrollViewKey,
  }) : super(key: key);

  Future<Map<int, DestinyInventoryBucketDefinition>> get bucketDefs async {
    final hashes = buckets.map((e) => e.categoryHash).whereType<int>().toList();
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
                  SliverSection.fixedHeight(
                    itemBuilder: (context, _) => CharacterInfoWidget(
                      character,
                      currencies: currencies,
                    ),
                    itemHeight: _characterInfoHeight,
                  )
                ] +
                buckets //
                    .map<List<SliverSection>>(
                        (e) => buildQuestSections(context, e, constraints, defs[e.categoryHash])) //
                    .fold<List<SliverSection>>([], (list, element) => list + element).toList(),
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            padding: const EdgeInsets.all(8).copyWith(top: 0),
            scrollViewKey: scrollViewKey,
          ),
        );
      },
    );
  }

  List<SliverSection> buildQuestSections(
    BuildContext context,
    PursuitCharacterBucketContent bucketContent,
    BoxConstraints constraints,
    DestinyInventoryBucketDefinition? bucketDef,
  ) {
    final unequipped = bucketContent.items;
    final categoryHash = bucketContent.categoryHash;
    final defaultDisplayType = BucketDisplayType.Large;
    final displayType = bucketOptionsState(context)
        .getDisplayTypeForItemSection('pursuit ${categoryHash}', defaultValue: defaultDisplayType);
    final unequippedDensity = displayType.unequippedDensity;
    final useBucketCount = bucketDef?.hasTransferDestination == true && bucketDef?.scope == BucketScope.Character;
    final bucketDefCount = (bucketDef?.itemCount ?? 10);
    final idealCount = unequippedDensity?.getIdealCount(constraints.maxWidth) ?? 5;
    final unequippedCount = ((useBucketCount ? bucketDefCount : unequipped.length) / idealCount).ceil() * idealCount;
    return [
      SliverSection.fixedHeight(
        itemCount: 1,
        itemHeight: 48,
        itemBuilder: (_, __) => ItemSectionHeaderWidget(
          sectionIdentifier: 'pursuit ${categoryHash}',
          title: ManifestText<DestinyTraitDefinition>(categoryHash),
          defaultType: defaultDisplayType,
          availableOptions: _pursuitDisplayOptions,
          canEquip: false,
        ),
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
    ].whereType<SliverSection>().toList();
  }

  SliverSection? buildItemSection(
    BuildContext context,
    PursuitCharacterBucketContent bucketContent,
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
      return SliverSection.fixedHeight(
        itemHeight: itemHeight + 4,
        itemCount: itemCount,
        itemsPerRow: itemsPerRow,
        itemBuilder: (_, index) {
          if (index < items.length) {
            return buildItem(items[index], density);
          }

          return EmptyItem(
            density: density,
          );
        },
      );
    }
    final itemAspectRatio = density.itemAspectRatio;
    if (itemAspectRatio != null) {
      return SliverSection.aspectRatio(
        itemAspectRatio: itemAspectRatio,
        itemsPerRow: itemsPerRow,
        itemCount: itemCount,
        itemBuilder: (_, index) {
          if (index < items.length) {
            return buildItem(items[index], density);
          }

          return EmptyItem(
            density: density,
          );
        },
      );
    }
    return null;
  }

  Widget buildItem(DestinyItemInfo item, InventoryItemWidgetDensity density) {
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
