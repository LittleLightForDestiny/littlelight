import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/modules/loadouts/blocs/loadouts.bloc.dart';
import 'package:little_light/modules/search/blocs/filter_options/loadout_filter_options.dart';
import 'package:provider/provider.dart';

import 'base_item_filter.dart';

class LoadoutFilter extends BaseItemFilter<LoadoutFilterOptions> {
  final LoadoutsBloc _loadoutsBloc;
  LoadoutFilter(BuildContext context, Set<String> values)
      : _loadoutsBloc = context.read<LoadoutsBloc>(),
        super(LoadoutFilterOptions(values));

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final hash = item.itemHash;
    final instanceId = item.instanceId;
    if (instanceId == null) return false;

    final loadouts =
        _loadoutsBloc.loadouts?.where((l) => data.value.contains(l.assignedId));
    if (loadouts == null) return true;
    for (final l in loadouts) {
      if (l.containsItem(instanceId)) {
        return true;
      }
    }
    return false;
  }
}
