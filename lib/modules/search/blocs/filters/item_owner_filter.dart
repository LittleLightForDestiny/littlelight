import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/item_owner_filter_options.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';

import 'base_item_filter.dart';

class ItemOwnerFilter extends BaseItemFilter<ItemOwnerFilterOptions> {
  ItemOwnerFilter()
      : super(
          ItemOwnerFilterOptions(
            ItemOwnerValues(),
          ),
        );

  @override
  Future<List<DestinyItemInfo>> filter(BuildContext context, List<DestinyItemInfo> items) async {
    if (data.value.isEmpty) {
      return items;
    }
    return super.filter(context, items);
  }

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final characterId = item.characterId;
    if (characterId != null) {
      return data.value.characters.contains(characterId);
    }
    if (item.bucketHash == InventoryBucket.general) {
      return data.value.vault;
    }
    return data.value.profile;
  }

  @override
  Future<void> addValue(DestinyItemInfo item) async {
    final characterId = item.characterId;
    if (characterId != null) {
      data.availableValues.characters.add(characterId);
      return;
    }
    if (item.bucketHash == InventoryBucket.general) {
      data.availableValues.vault = true;
      return;
    }

    data.availableValues.profile = true;
  }
}
