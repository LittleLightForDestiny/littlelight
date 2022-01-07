import 'dart:math' as math;

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_power_cap_definition.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'base_item_filter.dart';

class PowerCapFilter extends BaseItemFilter<Set<int>> {
  PowerCapFilter() : super(Set(), Set());

  clear() {
    availableValues.clear();
  }

  Map<int, int> powercapValues = Map();

  @override
  Future<List<ItemWithOwner>> filter(List<ItemWithOwner> items,
      {Map<int, DestinyInventoryItemDefinition> definitions}) async {
    clear();
    Set<int> powerCaps = Set();
    for (var item in items) {
      var def = definitions[item.item.itemHash];
      if (def?.quality?.versions != null &&
          def?.quality?.currentVersion != null) {
        var powercapHash =
            def.quality.versions[def.quality.currentVersion].powerCapHash;
        var powerCapDef = await manifest
            .getDefinition<DestinyPowerCapDefinition>(powercapHash);
        var powerCap = math.min(powerCapDef.powerCap, 9000);
        powercapValues[powercapHash] = powerCap;
        powerCaps.add(powerCap);
      }
    }
    availableValues.addAll(powerCaps);

    this.available = availableValues.length > 1;
    // if(available) availableValues.add(-1);
    value.retainAll(availableValues);
    return super.filter(items, definitions: definitions);
  }

  bool filterItem(ItemWithOwner item,
      {Map<int, DestinyInventoryItemDefinition> definitions}) {
    if (value?.length == 0) {
      return true;
    }
    var def = definitions[item.item.itemHash];
    if (def?.quality?.versions == null ||
        def?.quality?.currentVersion == null) {
      if (value.contains(-1)) return true;
      return false;
    }
    var version = def.quality.versions[item.item.versionNumber];
    var powercapValue = powercapValues[version.powerCapHash];
    if (value.contains(powercapValue)) return true;
    return false;
  }
}
