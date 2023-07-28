import 'package:bungie_api/destiny2.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/damage_type_filter_options.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'base_item_filter.dart';

class DamageTypeFilter extends BaseItemFilter<DamageTypeFilterOptions> with ManifestConsumer {
  DamageTypeFilter() : super(DamageTypeFilterOptions({}));

  @override
  Future<List<DestinyItemInfo>> filter(BuildContext context, List<DestinyItemInfo> items) async {
    if (data.value.isNotEmpty) {
      return super.filter(context, items);
    }
    return items;
  }

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    if (item.bucketHash == InventoryBucket.subclass) {
      final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
      final damageType = def?.talentGrid?.hudDamageType;
      return data.value.contains(damageType);
    }
    return data.value.contains(item.damageType);
  }

  @override
  Future<void> addValues(List<DestinyItemInfo> items) async {
    final subclassHashes = items.where((i) => i.bucketHash == InventoryBucket.subclass).map((i) => i.itemHash);
    final subclassDefs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(subclassHashes);
    final damageType = items.map((i) {
      if (i.bucketHash == InventoryBucket.subclass) {
        final def = subclassDefs[i.itemHash];
        final damageType = def?.talentGrid?.hudDamageType;
        return damageType ?? DamageType.None;
      }
      return i.damageType ?? DamageType.None;
    });
    data.availableValues.addAll(damageType);
  }

  @override
  void clearAvailable() {
    data.availableValues.clear();
  }
}
