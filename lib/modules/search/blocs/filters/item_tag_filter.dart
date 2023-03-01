import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/item_tag_filter_options.dart';
import 'package:little_light/services/littlelight/item_notes.consumer.dart';

import 'base_item_filter.dart';

class ItemTagFilter extends BaseItemFilter<ItemTagFilterOptions>
    with ItemNotesConsumer {
  ItemTagFilter(Set<String> values) : super(ItemTagFilterOptions(values));

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final hash = item.itemHash;
    final instanceId = item.instanceId;
    if (hash == null) return false;

    final tags = itemNotes.getTagsForItem(hash, instanceId);
    if (tags == null) return false;
    if (tags.isEmpty) return false;
    return data.value.any((element) => tags.any((t) => t.tagId == element));
  }
}
