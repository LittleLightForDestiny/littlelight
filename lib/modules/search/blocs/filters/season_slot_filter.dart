import 'package:bungie_api/destiny2.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/season_slot_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'base_item_filter.dart';

class SeasonSlotFilter extends BaseItemFilter<SeasonSlotFilterOptions> with ManifestConsumer {
  SeasonSlotFilter(Set<int> values) : super(SeasonSlotFilterOptions(values.toSet(), values));

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final hash = item.itemHash;
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
    if (data.value.contains(-1)) {
      bool contains = false;
      final entries = def?.sockets?.socketEntries;
      if (entries == null) return true;
      for (var socket in entries) {
        contains = contains || data.value.contains(socket.singleInitialItemHash);
      }
      if (!contains) return true;
    }
    return false;
  }
}
