import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/shared/utils/sorters/items/item_sorter.dart';
import 'package:little_light/utils/item_sorters/base_item_sorter.dart';
import 'package:little_light/utils/item_with_owner.dart';

class PriorityTagsSorter extends BaseItemSorter with UserSettingsConsumer {
  List<String>? _priorityTags;

  PriorityTagsSorter() : super(SorterDirection.None);

  List<String>? get priorityTags {
    final tags = _priorityTags;
    if (tags != null) return tags;
    final settingsTags = userSettings.priorityTags;
    if (settingsTags != null) return _priorityTags = List.from(settingsTags);
    return null;
  }

  @override
  int sort(ItemWithOwner a, ItemWithOwner b) {
    // Set<String> tagsA = itemNotes.tagIdsFor(a.item.itemHash, a.item.itemInstanceId) ?? <String>{};
    // Set<String> tagsB = itemNotes.tagIdsFor(b.item.itemHash, b.item.itemInstanceId) ?? <String>{};
    var indexA = 9999;
    var indexB = 9999;
    final tags = priorityTags;
    if (tags == null || tags.isEmpty) {
      return 0;
    }
    for (var i = 0; i < tags.length; i++) {
      var tag = tags[i];
      // if (indexA > 1000 && tagsA.contains(tag)) indexA = i;
      // if (indexB > 1000 && tagsB.contains(tag)) indexB = i;
    }
    return indexA.compareTo(indexB);
  }
}
