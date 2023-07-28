import 'package:bungie_api/destiny2.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/class_type_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'base_item_filter.dart';

class ClassTypeFilter extends BaseItemFilter<ClassTypeFilterOptions> with ManifestConsumer {
  ClassTypeFilter() : super(ClassTypeFilterOptions());

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
    return data.value.contains(def?.classType);
  }

  @override
  Future<void> addValues(List<DestinyItemInfo> item) async {
    final hashes = item.map((i) => i.itemHash);
    final defs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes);
    final classTypes = defs.values.map((d) => d.classType ?? DestinyClass.Unknown);
    data.availableValues.addAll(classTypes);
  }

  @override
  void clearAvailable() {
    data.availableValues.clear();
  }
}
