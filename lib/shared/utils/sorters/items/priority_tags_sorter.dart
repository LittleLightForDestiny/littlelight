import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/shared/utils/sorters/items/item_sorter.dart';
import 'package:provider/provider.dart';

class PriorityTagsSorter extends ItemSorter {
  List<String> _priorityTags;

  PriorityTagsSorter(BuildContext context, this._priorityTags) : super(context, SorterDirection.Ascending);

  @override
  int sort(DestinyItemInfo a, DestinyItemInfo b) {
    final itemNotes = context.read<ItemNotesBloc>();
    final tagsA = itemNotes.tagIdsFor(a.item.itemHash, a.item.itemInstanceId) ?? <String>{};
    final tagsB = itemNotes.tagIdsFor(b.item.itemHash, b.item.itemInstanceId) ?? <String>{};
    final tags = _priorityTags;

    int? indexA;
    int? indexB;
    if (tags.isEmpty) {
      return 0;
    }
    for (var i = 0; i < tags.length; i++) {
      if (indexA != null && indexB != null) break;
      var tag = tags[i];
      if (tagsA.contains(tag)) indexA ??= i;
      if (tagsB.contains(tag)) indexB ??= i;
    }
    indexA ??= 9999;
    indexB ??= 9999;
    return indexA.compareTo(indexB);
  }
}
