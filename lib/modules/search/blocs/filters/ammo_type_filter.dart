import 'package:bungie_api/enums/destiny_ammunition_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/ammo_type_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

import 'base_item_filter.dart';

class AmmoTypeFilter extends BaseItemFilter<AmmoTypeFilterOptions> with ManifestConsumer {
  AmmoTypeFilter() : super(AmmoTypeFilterOptions(<DestinyAmmunitionType>{}));

  @override
  Future<List<DestinyItemInfo>> filter(BuildContext context, List<DestinyItemInfo> items) async {
    if (data.value.isNotEmpty) {
      return super.filter(context, items);
    }
    return items;
  }

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final hash = item.itemHash;
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
    return data.value.contains(def?.equippingBlock?.ammoType);
  }

  @override
  Future<void> addValue(DestinyItemInfo item) async {
    final hash = item.itemHash;
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
    final ammoType = def?.equippingBlock?.ammoType ?? DestinyAmmunitionType.Unknown;
    data.availableValues.add(ammoType);
  }
}
