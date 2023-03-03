import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/item_tag_filter_options.dart';
import 'package:little_light/services/littlelight/item_notes.consumer.dart';

import 'base_item_filter.dart';

class ItemTagFilter extends BaseItemFilter<ItemTagFilterOptions> with ItemNotesConsumer {
  ItemTagFilter() : super(ItemTagFilterOptions({}));

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
    final instanceId = item.instanceId;
    if (hash == null) return false;

    final tags = itemNotes.getTagsForItem(hash, instanceId);
    if (tags == null || tags.isEmpty) {
      return data.value.contains(null);
    }
    return data.value.any((element) => tags.any((t) => t.tagId == element));
  }

  @override
  Future<void> addValue(DestinyItemInfo item) async {
    final hash = item.itemHash;
    final instanceId = item.instanceId;
    if (hash == null) return;

    final tags = itemNotes.getTagsForItem(hash, instanceId);
    if (tags == null || tags.isEmpty) {
      data.availableValues.add(null);
      return;
    }
    data.availableValues.addAll(tags.map((e) => e.tagId).whereType<String>());
  }
}
