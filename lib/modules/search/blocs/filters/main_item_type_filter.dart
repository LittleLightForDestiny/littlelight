import 'package:bungie_api/destiny2.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/main_item_type_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/inventory_item_data.dart';
import 'package:little_light/shared/utils/helpers/bucket_type_groups.dart';

import 'base_item_filter.dart';

class MainItemTypeFilter extends BaseItemFilter<MainItemTypeFilterOptions> with ManifestConsumer {
  MainItemTypeFilter() : super(MainItemTypeFilterOptions(<EquipmentBucketGroup>{}));

  @override
  Future<List<DestinyItemInfo>> filter(BuildContext context, List<DestinyItemInfo> items) async {
    if (data.value.isEmpty) {
      return items;
    }
    return super.filter(context, items);
  }

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final hash = item.itemHash;
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
    if (def == null) return false;
    final filterAsWeapon = def.isWeapon || def.isSubclass;
    final filterAsArmor = def.isArmor;
    final filterAsInventory = !filterAsWeapon && !filterAsArmor;

    if (filterAsWeapon && data.value.contains(EquipmentBucketGroup.Weapons)) {
      return true;
    }

    if (filterAsArmor && data.value.contains(EquipmentBucketGroup.Armor)) {
      return true;
    }
    if (filterAsInventory && data.value.contains(EquipmentBucketGroup.Inventory)) {
      return true;
    }

    return false;
  }

  @override
  Future<void> addValues(List<DestinyItemInfo> items) async {
    final hashes = items.map((i) => i.itemHash);
    final defs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes);
    final values = <EquipmentBucketGroup>{};
    if (defs.values.any((element) => element.isWeapon || element.isSubclass)) {
      values.add(EquipmentBucketGroup.Weapons);
    }
    if (defs.values.any((element) => element.isArmor)) {
      values.add(EquipmentBucketGroup.Armor);
    }
    if (defs.values.any((element) => !element.isArmor && !element.isSubclass && !element.isWeapon)) {
      values.add(EquipmentBucketGroup.Inventory);
    }

    data.availableValues.addAll(values);
  }

  @override
  void clearAvailable() {
    data.availableValues.clear();
  }
}
