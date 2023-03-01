// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:little_light/modules/loadouts/blocs/loadouts.bloc.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:provider/provider.dart';

import 'base_item_filter.dart';

class LoadoutFilter extends BaseItemFilter<Set<String>> {
  final BuildContext context;
  List<LoadoutItemIndex> allLoadouts;

  LoadoutFilter(this.context) : super(<String>{}, <String>{});

  clear() {
    availableValues.clear();
  }

  @override
  Future<List<ItemWithOwner>> filter(List<ItemWithOwner> items,
      {Map<int, DestinyInventoryItemDefinition> definitions}) async {
    clear();

    allLoadouts = context.read<LoadoutsBloc>().loadouts;
    availableValues.addAll(allLoadouts?.map((l) => l.assignedId) ?? []);
    available = availableValues.length > 1;
    value.retainAll(availableValues);
    return super.filter(items, definitions: definitions);
  }

  @override
  bool filterItem(ItemWithOwner item,
      {Map<int, DestinyInventoryItemDefinition> definitions}) {
    if (value.isEmpty) {
      return true;
    }

    for (var assignedId in value) {
      var loadout =
          allLoadouts.firstWhere((element) => element.assignedId == assignedId);
      if (loadout.containsItem(item.item.itemInstanceId)) return true;
    }
    return false;
  }
}
