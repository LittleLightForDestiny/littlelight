import 'package:bungie_api/destiny2.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/damage_type_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

import 'base_item_filter.dart';

class DamageTypeFilter extends BaseItemFilter<DamageTypeFilterOptions>
    with ManifestConsumer {
  DamageTypeFilter() : super(DamageTypeFilterOptions({}));

  @override
  Future<List<DestinyItemInfo>> filter(
      BuildContext context, List<DestinyItemInfo> items) async {
    if (data.value.isNotEmpty) {
      return super.filter(context, items);
    }
    return items;
  }

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    return data.value.contains(item.instanceInfo?.damageType);
  }

  @override
  Future<void> addValue(DestinyItemInfo item) async {
    final damageType = item.instanceInfo?.damageType ?? DamageType.None;
    data.availableValues.add(damageType);
  }
}
