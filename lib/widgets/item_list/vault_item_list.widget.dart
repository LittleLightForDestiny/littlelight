import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/widgets/item_list/bucket_header.widget.dart';
import 'package:little_light/widgets/item_list/item_list.widget.dart';
import 'package:little_light/widgets/item_list/vault_info.widget.dart';

class VaultItemListWidget extends ItemListWidget {
  VaultItemListWidget({EdgeInsets padding, List<int> bucketHashes, Key key, Map<int, double> scrollPositions})
      : super(key: key, padding: padding, bucketHashes: bucketHashes, scrollPositions: scrollPositions);
  @override
  VaultItemListWidgetState createState() => new VaultItemListWidgetState();
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
    this.bucketDefs = await manifest.getDefinitions<DestinyInventoryBucketDefinition>(widget.bucketHashes);
    Map<int, DestinyInventoryItemDefinition> itemDefs =
        await manifest.getDefinitions<DestinyInventoryItemDefinition>(itemsOnVault.map((i) => i.itemHash));
    this.buckets = [];
    for (int bucketHash in widget.bucketHashes) {
      List<DestinyItemComponent> unequipped = itemsOnVault.where((item) {
        var def = itemDefs[item.itemHash];
        return def?.inventory?.bucketTypeHash == bucketHash;
      }).toList();
      unequipped = (await InventoryUtils.sortDestinyItems(unequipped.map((i) => ItemWithOwner(i, null))))
          .map((i) => i.item)
          .toList();

      this.buckets.add(ListBucket(bucketHash: bucketHash, unequipped: unequipped));
    }

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget getItem(int index, List<ListItem> listIndex) {
    ListItem item = listIndex[index];
    switch (item?.type) {
      case ListItem.infoHeader:
        return VaultInfoWidget();

      case ListItem.bucketHeader:
        return BucketHeaderWidget(
          hash: item?.hash,
          itemCount: item.itemCount,
          onChanged: () {
            setState(() {});
          },
          isVault: true,
        );

      case ListItem.unequippedItem:
        if (item?.hash == null) return Container();
    }
    return super.getItem(index, listIndex);
  }

  @override
  Widget buildUnequippedItem(int index, ListItem item, String characterId) {
    return super.buildUnequippedItem(index, item, characterId);
  }

  @override
  BucketDisplayOptions getBucketOptions(ListItem item) {
    var options = userSettings.getDisplayOptionsForBucket("vault_${item?.bucketHash}");
    return options;
  }
}
