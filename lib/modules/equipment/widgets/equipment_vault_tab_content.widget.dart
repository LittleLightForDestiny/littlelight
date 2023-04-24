import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/shared/blocs/bucket_options/bucket_options.bloc.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/bucket_display_type_data.dart';
import 'package:little_light/shared/widgets/headers/bucket_header/bucket_header_list_item.widget.dart';
import 'package:little_light/shared/widgets/inventory_item/empty_item.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item.dart';
import 'package:little_light/shared/widgets/inventory_item/interactive_item_wrapper.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/widgets/multisection_scrollview/sliver_section.dart';
import 'package:provider/provider.dart';

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

  BucketOptionsBloc bucketOptionsState(BuildContext context) => context.watch<BucketOptionsBloc>();

  const EquipmentVaultTabContentWidget({
    Key? key,
    required this.buckets,
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
            buckets //
                .map<List<SliverSection>>((e) => buildBucketSections(context, e, constraints, defs[e.bucketHash])) //
                .fold<List<SliverSection>>([], (list, element) => list + element).toList(),
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            padding: const EdgeInsets.all(8).copyWith(top: 0, bottom: 64),
          ),
        );
      },
    );
  }

  List<SliverSection> buildBucketSections(
    BuildContext context,
    EquipmentVaultBucketContent bucketContent,
    BoxConstraints constraints,
    DestinyInventoryBucketDefinition? bucketDef,
  ) {
    final items = bucketContent.items;
    final bucketHash = bucketContent.bucketHash;
    final displayType = bucketOptionsState(context).getDisplayTypeForVaultBucket(bucketHash);
    final itemDensity = displayType.unequippedDensity;
    final idealCount = itemDensity?.getIdealCount(constraints.maxWidth) ?? 5;
    final itemCount = (items.length / idealCount).ceil() * idealCount;
    return [
      SliverSection.fixedHeight(
        itemCount: 1,
        itemHeight: 48,
        itemBuilder: (_, __) => BucketHeaderListItemWidget(
          bucketHash,
          itemCount: bucketContent.items.length,
          isVault: true,
          canEquip: false,
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
    ].whereType<SliverSection>().toList();
  }

  SliverSection? buildItemSection(
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
      return SliverSection.fixedHeight(
        itemHeight: itemHeight + 4,
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
      return SliverSection.aspectRatio(
        itemAspectRatio: itemAspectRatio,
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
