// @dart=2.9

import 'package:little_light/services/littlelight/item_notes.consumer.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/utils/item_sorters/base_item_sorter.dart';
import 'package:little_light/utils/item_with_owner.dart';

class PriorityTagsSorter extends BaseItemSorter with UserSettingsConsumer, ItemNotesConsumer {
  PriorityTagsSorter() : super(0);
  List<String> _priorityTags;

  List<String> get priorityTags {
    if (_priorityTags == null) {
      _priorityTags = List.from(userSettings.priorityTags);
    }
    return _priorityTags;
  }

  @override
  int sort(ItemWithOwner a, ItemWithOwner b) {
    Set<String> tagsA = itemNotes.getNotesForItem(a.item.itemHash, a.item.itemInstanceId)?.tags ?? Set();
    Set<String> tagsB = itemNotes.getNotesForItem(b.item.itemHash, b.item.itemInstanceId)?.tags ?? Set();
    var indexA = 9999;
    var indexB = 9999;
    for (var i = 0; i < priorityTags.length; i++) {
      var tag = priorityTags[i];
      if (indexA > 1000 && tagsA.contains(tag)) indexA = i;
      if (indexB > 1000 && tagsB.contains(tag)) indexB = i;
    }
    return indexA.compareTo(indexB);
  }
}
