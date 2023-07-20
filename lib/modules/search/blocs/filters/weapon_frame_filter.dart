import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/weapon_frame_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/inventory_item_data.dart';

import 'base_item_filter.dart';

final _intrinsicTraitCategory = 3956125808;

class WeaponFrameFilter extends BaseItemFilter<WeaponFrameFilterOptions> with ManifestConsumer {
  WeaponFrameFilter() : super(WeaponFrameFilterOptions(<String>{}));

  @override
  Future<List<DestinyItemInfo>> filter(BuildContext context, List<DestinyItemInfo> items) async {
    if (data.value.isEmpty) {
      return items;
    }
    return super.filter(context, items);
  }

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final plugHashes = await _getIntrinsicPlugHashes(item);
    if (plugHashes == null) return false;
    final definitions = await manifest.getDefinitions<DestinyInventoryItemDefinition>(plugHashes);
    final names = definitions.values.map((e) => e.displayProperties?.name).whereType<String>();
    return names.any((p) => data.value.contains(p));
  }

  @override
  Future<void> addValue(DestinyItemInfo item) async {
    final plugHashes = await _getIntrinsicPlugHashes(item);
    if (plugHashes == null) return;
    final definitions = await manifest.getDefinitions<DestinyInventoryItemDefinition>(plugHashes);
    final names = definitions.values.map((e) => e.displayProperties?.name).whereType<String>();
    data.availableValues.addAll(names);
  }

  Future<Iterable<int>?> _getIntrinsicPlugHashes(DestinyItemInfo item) async {
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
    if (def == null) return null;
    if (!def.isWeapon) return null;
    if (def.inventory?.tierType == TierType.Exotic) return null;
    final category = def.sockets?.socketCategories?.firstWhereOrNull(
      (element) => element.socketCategoryHash == _intrinsicTraitCategory,
    );
    final socketIndexes = category?.socketIndexes;
    final plugs = socketIndexes?.map((e) => item.sockets?[e].plugHash).whereType<int>();
    return plugs;
  }
}
