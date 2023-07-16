import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:little_light/shared/blocs/bucket_options/bucket_options.bloc.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/bucket_display_type_data.dart';
import 'package:little_light/modules/progress/widgets/bucket_header_list_item.widget.dart';
import 'package:little_light/shared/widgets/character/vault_info.widget.dart';
import 'package:little_light/shared/widgets/inventory_item/empty_item.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item.dart';
import 'package:little_light/shared/widgets/inventory_item/interactive_item_wrapper.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sliver_section.dart';
import 'package:provider/provider.dart';

const _vaultInfoHeight = 108.0;

class EquipmentVaultBucketContent {
  final int bucketHash;
  final List<DestinyItemInfo> items;

  EquipmentVaultBucketContent(
    this.bucketHash, {
    required this.items,
  });
}

class EquipmentVaultTabContentWidget extends StatelessWidget with ManifestConsumer {
  final List<EquipmentVaultBucketContent> buckets;
  final List<DestinyItemComponent>? currencies;
  final int? itemsOnVault;

  ItemSectionOptionsBloc bucketOptionsState(BuildContext context) => context.watch<ItemSectionOptionsBloc>();

  const EquipmentVaultTabContentWidget({
    Key? key,
    required this.buckets,
    this.currencies,
    this.itemsOnVault,
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
          key: const Key("vault_tab"),
          builder: (context, constraints) => MultiSectionScrollView(
            [
              FixedHeightScrollSection(
                _vaultInfoHeight,
                itemBuilder: (context, _) => VaultInfoWidget(
                  currencies: currencies,
                  totalVaultItems: itemsOnVault,
                ),
              ),
              ...buckets
                  .map<List<ScrollableSection>>(
                      (e) => buildBucketSections(context, e, constraints, defs[e.bucketHash])) //
                  .fold<List<ScrollableSection>>([], (list, element) => list + element).toList()
            ],
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            padding: const EdgeInsets.all(8).copyWith(top: 0, bottom: 64),
          ),
        );
      },
    );
  }

  List<ScrollableSection> buildBucketSections(
    BuildContext context,
    EquipmentVaultBucketContent bucketContent,
    BoxConstraints constraints,
    DestinyInventoryBucketDefinition? bucketDef,
  ) {
    final items = bucketContent.items;
    final bucketHash = bucketContent.bucketHash;
    final sectionId = 'vault $bucketHash';
    final defaultType = BucketDisplayType.Small;
    final displayType = bucketOptionsState(context).getDisplayTypeForItemSection(sectionId, defaultValue: defaultType);
    final itemDensity = displayType.unequippedDensity;
    final idealCount = itemDensity?.getIdealCount(constraints.maxWidth) ?? 5;
    final itemCount = (items.length / idealCount).ceil() * idealCount;
    return [
      FixedHeightScrollSection(
        48,
        itemCount: 1,
        itemBuilder: (_, __) => BucketHeaderListItemWidget(
          bucketHash,
          itemCount: bucketContent.items.length,
          isVault: true,
          canEquip: false,
          defaultType: defaultType,
        ),
      ),
      if (itemDensity != null)
        buildItemSection(
          context,
          bucketContent,
          items,
          itemDensity,
          idealCount,
          itemCount,
        ),
    ].whereType<ScrollableSection>().toList();
  }

  ScrollableSection? buildItemSection(
    BuildContext context,
    EquipmentVaultBucketContent bucketContent,
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
            return buildItem(items[index], density);
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
