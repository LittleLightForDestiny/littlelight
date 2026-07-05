import 'package:bungie_api/enums/destiny_breaker_type.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/breaker_type_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'base_item_filter.dart';
import 'package:little_light/utils/intrinsic_breaker_utils.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/littlelight/littlelight_data.consumer.dart';

class BreakerTypeFilter extends BaseItemFilter<BreakerTypeFilterOptions>
    with ManifestConsumer, LittleLightDataConsumer {
  BreakerTypeFilter() : super(BreakerTypeFilterOptions(<DestinyBreakerType>{}));

  @override
  Future<List<DestinyItemInfo>> filter(BuildContext context, List<DestinyItemInfo> items) async {
    if (data.value.isNotEmpty) {
      return super.filter(context, items);
    }
    return items;
  }

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final breakerType = await IntrinsicBreakerUtils.getWeaponBreakerType(manifest, littleLightData, item.itemHash);
    return data.value.contains(breakerType);
  }

  @override
  Future<void> addValues(List<DestinyItemInfo> items) async {
    final haveWeapons = items.any((i) => InventoryBucket.weaponBucketHashes.contains(i.bucketHash));
    if (haveWeapons)
      data.availableValues.addAll([
        DestinyBreakerType.ShieldPiercing,
        DestinyBreakerType.Disruption,
        DestinyBreakerType.Stagger,
      ]);
  }

  @override
  void clearAvailable() {
    data.availableValues.clear();
  }
}
