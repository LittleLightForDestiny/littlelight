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
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';

const _pursuitDisplayOptions = {
  BucketDisplayType.Hidden,
  BucketDisplayType.Large,
  BucketDisplayType.Medium,
  BucketDisplayType.Small,
};

class QuestsCharacterContent {
  final int? categoryHash;
  final List<DestinyItemInfo> items;

  QuestsCharacterContent(
    this.categoryHash, {
    required this.items,
  });
}

const _characterInfoHeight = 128.0;
const _bountyCategoryHash = 1784235469;

class PursuitsCharacterTabContentWidget extends StatelessWidget with ManifestConsumer {
  final DestinyCharacterInfo character;
  final List<QuestsCharacterContent> quests;
  final List<DestinyItemInfo>? bounties;
  final List<DestinyItemComponent>? currencies;
  final Key? scrollViewKey;

  ItemSectionOptionsBloc sectionOptionsState(BuildContext context) => context.watch<ItemSectionOptionsBloc>();

  const PursuitsCharacterTabContentWidget(
    this.character, {
    Key? key,
    required this.quests,
    required this.bounties,
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
          ...buildBountiesSections(context, constraints),
          for (final q in quests) ...buildQuestSections(context, q, constraints)
        ],
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
        padding: const EdgeInsets.all(8).copyWith(top: 0),
        scrollViewKey: scrollViewKey,
      ),
    );
  }

  List<ScrollableSection> buildBountiesSections(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final items = this.bounties;
    if (items == null || items.isEmpty) return [];
    final defaultDisplayType = BucketDisplayType.Small;
    final sectionId = 'bounties';
    final displayType =
        sectionOptionsState(context).getDisplayTypeForItemSection(sectionId, defaultValue: defaultDisplayType);
    final unequippedDensity = displayType.unequippedDensity;
    final idealCount = unequippedDensity?.getIdealCount(constraints.maxWidth) ?? 5;
    final unequippedCount = (items.length / idealCount).ceil() * idealCount;
    return [
      FixedHeightScrollSection(
        48,
        itemCount: 1,
        itemBuilder: (_, __) => ItemSectionHeaderWidget(
          sectionIdentifier: sectionId,
          title: ManifestText<DestinyItemCategoryDefinition>(_bountyCategoryHash),
          defaultType: defaultDisplayType,
          availableOptions: _pursuitDisplayOptions,
          canEquip: false,
        ),
      ),
      if (unequippedDensity != null)
        buildItemSection(
          context,
          items,
          unequippedDensity,
          idealCount,
          unequippedCount,
        ),
    ].whereType<ScrollableSection>().toList();
  }

  List<ScrollableSection> buildQuestSections(
    BuildContext context,
    QuestsCharacterContent bucketContent,
    BoxConstraints constraints,
  ) {
    final items = bucketContent.items;
    final categoryHash = bucketContent.categoryHash;
    final defaultDisplayType = BucketDisplayType.Large;
    final sectionId = 'quest ${categoryHash}';
    final displayType = sectionOptionsState(context).getDisplayTypeForItemSection(
      sectionId,
      defaultValue: defaultDisplayType,
    );
    final unequippedDensity = displayType.unequippedDensity;
    final idealCount = unequippedDensity?.getIdealCount(constraints.maxWidth) ?? 5;
    final unequippedCount = (items.length / idealCount).ceil() * idealCount;
    return [
      FixedHeightScrollSection(
        48,
        itemCount: 1,
        itemBuilder: (_, __) => ItemSectionHeaderWidget(
          sectionIdentifier: sectionId,
          title: ManifestText<DestinyTraitDefinition>(categoryHash),
          defaultType: defaultDisplayType,
          availableOptions: _pursuitDisplayOptions,
          canEquip: false,
        ),
      ),
      if (unequippedDensity != null)
        buildItemSection(
          context,
          items,
          unequippedDensity,
          idealCount,
          unequippedCount,
        ),
    ].whereType<ScrollableSection>().toList();
  }

  ScrollableSection? buildItemSection(
    BuildContext context,
    List<DestinyItemInfo> items,
    InventoryItemWidgetDensity? density,
    int itemsPerRow,
    int itemCount,
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
      return AspectRatioScrollSection(
        itemAspectRatio,
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
