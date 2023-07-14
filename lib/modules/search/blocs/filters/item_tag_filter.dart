import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/item_tag_filter_options.dart';
import 'package:provider/provider.dart';
import 'base_item_filter.dart';

class ItemTagFilter extends BaseItemFilter<ItemTagFilterOptions> {
  ItemNotesBloc? itemNotes;
  ItemTagFilter() : super(ItemTagFilterOptions({}));

  @override
  Future<List<DestinyItemInfo>> filter(BuildContext context, List<DestinyItemInfo> items) async {
    itemNotes = context.read<ItemNotesBloc>();
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

    final tags = itemNotes?.tagIdsFor(hash, instanceId);
    if (tags == null || tags.isEmpty) {
      return data.value.contains(null);
    }
    return data.value.any((element) => tags.contains(element));
  }

  @override
  Future<void> addValue(DestinyItemInfo item) async {
    final hash = item.itemHash;
    final instanceId = item.instanceId;
    if (hash == null) return;

    final tags = itemNotes?.tagIdsFor(hash, instanceId);
    if (tags == null || tags.isEmpty) {
      data.availableValues.add(null);
      return;
    }
    data.availableValues.addAll(tags.whereType<String>());
  }
}
