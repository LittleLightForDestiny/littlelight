// @dart=2.9

import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/widgets/item_list/item_list.widget.dart';
import 'package:little_light/widgets/item_list/vault_info.widget.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sliver_section.dart';

import 'bucket_header.widget.dart';

class VaultItemListWidget extends ItemListWidget {
  const VaultItemListWidget({EdgeInsets padding, List<int> bucketHashes, Key key})
      : super(key: key, padding: padding, bucketHashes: bucketHashes);
  @override
  VaultItemListWidgetState createState() => VaultItemListWidgetState();
}

class VaultItemListWidgetState extends ItemListWidgetState
    with UserSettingsConsumer, ProfileConsumer, ManifestConsumer {
  @override
  bool suppressEmptySpaces(bucketHash) => true;

  @override
  bool isFullWidthBucket(bucketHash) => true;

  @override
  buildIndex() async {
    if (!mounted) return;
    List<DestinyItemComponent> itemsOnVault =
        profile.getProfileInventory().where((i) => i.bucketHash == InventoryBucket.general).toList();
    bucketDefs = await manifest.getDefinitions<DestinyInventoryBucketDefinition>(widget.bucketHashes);
    Map<int, DestinyInventoryItemDefinition> itemDefs =
        await manifest.getDefinitions<DestinyInventoryItemDefinition>(itemsOnVault.map((i) => i.itemHash));
    buckets = [];
    for (int bucketHash in widget.bucketHashes) {
      List<DestinyItemComponent> unequipped = itemsOnVault.where((item) {
        var def = itemDefs[item.itemHash];
        return def?.inventory?.bucketTypeHash == bucketHash;
      }).toList();
      unequipped = (await InventoryUtils.sortDestinyItems(unequipped.map((i) => ItemWithOwner(i, null))))
          .map((i) => i.item)
          .toList();

      buckets.add(ListBucket(bucketHash: bucketHash, unequipped: unequipped));
    }

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  ScrollableSection buildCharInfoSliver() {
    return FixedHeightScrollSection(
      112,
      itemCount: 1,
      itemBuilder: (context, _) => const VaultInfoWidget(),
    );
  }

  @override
  ScrollableSection buildBucketHeaderSliver(ListBucket bucket) {
    final itemCount = (bucket.equipped != null ? 1 : 0) + (bucket.unequipped?.length ?? 0);
    if (itemCount == 0) {
      return FixedHeightScrollSection(0, itemCount: 1, itemBuilder: (context, index) => Container());
    }
    return FixedHeightScrollSection(
      40,
      itemBuilder: (context, _) => BucketHeaderWidget(
        key: Key("bucketheader_vault_${bucket.bucketHash}"),
        presentationNodeHash: bucket.bucketHash,
        itemCount: itemCount,
        onChanged: () {
          setState(() {});
        },
        isVault: true,
      ),
      itemCount: 1,
    );
  }

  @override
  BucketDisplayOptions getBucketOptions(int bucketHash) {
    return userSettings.getDisplayOptionsForItemSection("vault_$bucketHash");
  }

  @override
  int getItemCountPerRow(BuildContext context, BucketDisplayOptions bucketOptions) {
    return bucketOptions.responsiveUnequippedItemsPerRow(context);
  }
}
