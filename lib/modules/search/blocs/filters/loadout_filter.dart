import 'package:flutter/material.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/core/blocs/loadouts/loadouts.bloc.dart';
import 'package:little_light/modules/search/blocs/filter_options/loadout_filter_options.dart';
import 'package:little_light/shared/utils/helpers/loadout_helpers.dart';
import 'package:provider/provider.dart';

import 'base_item_filter.dart';

class LoadoutFilter extends BaseItemFilter<LoadoutFilterOptions> {
  final Map<String, Set<String>> _loadoutsByItem = {};
  final LoadoutsBloc _loadoutsBloc;
  LoadoutFilter(BuildContext context)
      : _loadoutsBloc = context.read<LoadoutsBloc>(),
        super(LoadoutFilterOptions({}));

  @override
  Future<List<DestinyItemInfo>> filter(BuildContext context, List<DestinyItemInfo> items) async {
    if (data.value.isEmpty) {
      return items;
    }
    return super.filter(context, items);
  }

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final instanceId = item.instanceId;
    if (instanceId == null) return false;
    final itemLoadouts = _loadoutsByItem[instanceId];
    if (itemLoadouts == null || itemLoadouts.isEmpty) {
      if (data.value.contains(null)) {
        return true;
      }
      return false;
    }
    return itemLoadouts.any((id) => data.value.contains(id));
  }

  @override
  Future<void> addValue(DestinyItemInfo item) async {
    final instanceId = item.instanceId;
    if (instanceId == null) return;
    final loadouts = _loadoutsBloc.loadouts?.where((l) {
      return l.containsItem(instanceId);
    });
    if (loadouts == null) return;
    if (loadouts.isEmpty) data.availableValues.add(null);
    final ids = loadouts.map((e) => e.assignedId).whereType<String>();
    data.availableValues.addAll(ids);
    final itemLoadouts = _loadoutsByItem[instanceId] ??= {};
    itemLoadouts.addAll(ids);
  }
}
