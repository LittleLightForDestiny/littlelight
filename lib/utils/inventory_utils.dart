// @dart=2.9

import 'dart:math';

import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/interpolation_point.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/modules/loadouts/providers/loadout_item_index.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/utils/item_sorters/base_item_sorter.dart';
import 'package:little_light/utils/item_sorters/priority_tags_sorter.dart';
import 'package:little_light/utils/item_with_owner.dart';

class InventoryUtils {
  static ProfileService get _profile => getInjectedProfileService();
  static ManifestService get _manifest => getInjectedManifestService();
  static int interpolateStat(int investmentValue, List<InterpolationPoint> displayInterpolation) {
    var interpolation = displayInterpolation.toList();
    interpolation.sort((a, b) => a.value.compareTo(b.value));
    var upperBound = interpolation.firstWhere((point) => point.value >= investmentValue, orElse: () => null);
    var lowerBound = interpolation.lastWhere((point) => point.value <= investmentValue, orElse: () => null);

    if (upperBound == null && lowerBound == null) {
      print('Invalid displayInterpolation');
      return investmentValue;
    }
    if (lowerBound == null) {
      return upperBound.weight;
    } else if (upperBound == null) {
      return lowerBound.weight;
    }
    var factor = (investmentValue - lowerBound.value) / max((upperBound.value - lowerBound.value).abs(), 1);

    var displayValue = lowerBound.weight + (upperBound.weight - lowerBound.weight) * factor;
    return displayValue.round();
  }

  static Future<List<ItemWithOwner>> sortDestinyItems(Iterable<ItemWithOwner> items,
      {List<ItemSortParameter> sortingParams, bool sortTags = true}) async {
    if (sortingParams == null) {
      final userSettings = getInjectedUserSettings();
      sortingParams = userSettings.itemOrdering;
    }
    await _manifest.getDefinitions<DestinyInventoryItemDefinition>(items.map((i) => i?.item?.itemHash));
    List<BaseItemSorter> sorters = sortingParams.map((p) => p.sorter).where((s) => s != null).toList();
    if (sortTags) {
      sorters = <BaseItemSorter>[PriorityTagsSorter()] + sorters;
    }
    var originalOrder = items.toList();
    var list = items.toList();
    list.sort((a, b) {
      for (var sorter in sorters) {
        var res = sorter.sort(a, b);
        if (res != 0) return res;
      }
      return originalOrder.indexOf(a).compareTo(originalOrder.indexOf(b));
    });
    return list;
  }

  static debugLoadout(LoadoutItemIndex loadout, int classType) async {
    var isInDebug = false;
    assert(isInDebug = true);
    if (!isInDebug) return;
    for (var item in loadout.generic.values) {
      if (item == null) continue;
      var def = await _manifest.getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
      var bucket = await _manifest.getDefinition<DestinyInventoryBucketDefinition>(def.inventory.bucketTypeHash);
      var instance = _profile.getInstanceInfo(item.itemInstanceId);
      print("---------------------------------------------------------------");
      print(bucket.displayProperties.name);
      print("---------------------------------------------------------------");
      print("${def.displayProperties.name} ${instance?.primaryStat?.value}");
      print("---------------------------------------------------------------");
    }
    for (var items in loadout.classSpecific.values) {
      var item = items[classType];
      if (item == null) continue;
      var def = await _manifest.getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
      var bucket = await _manifest.getDefinition<DestinyInventoryBucketDefinition>(def.inventory.bucketTypeHash);
      var instance = _profile.getInstanceInfo(item.itemInstanceId);
      print("---------------------------------------------------------------");
      print(bucket.displayProperties.name);
      print("---------------------------------------------------------------");
      print("${def.displayProperties.name} ${instance?.primaryStat?.value}");
      print("---------------------------------------------------------------");
    }
  }
}
