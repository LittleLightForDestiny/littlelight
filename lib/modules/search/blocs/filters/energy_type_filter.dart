import 'package:bungie_api/destiny2.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/energy_type_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

import 'base_item_filter.dart';

class EnergyTypeFilter extends BaseItemFilter<EnergyTypeFilterOptions>
    with ManifestConsumer {
  EnergyTypeFilter() : super(EnergyTypeFilterOptions(<DestinyEnergyType>{}));

  @override
  Future<List<DestinyItemInfo>> filter(
      BuildContext context, List<DestinyItemInfo> items) async {
    if (data.value.isEmpty) {
      return items;
    }
    return super.filter(context, items);
  }

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final instanceInfo = item.instanceInfo;
    final energy = instanceInfo?.energy?.energyType;
    return data.value.contains(energy);
  }

  @override
  Future<void> addValue(DestinyItemInfo item) async {
    final instanceInfo = item.instanceInfo;
    final energy = instanceInfo?.energy?.energyType;
    data.availableValues.add(energy);
  }
}
