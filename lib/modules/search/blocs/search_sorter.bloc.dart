import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/blocs/profile/sorters.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/sorters/items/export.dart';
import 'package:provider/provider.dart';
import 'sorter_options.dart';

class SearchSorterBloc extends ChangeNotifier with ManifestConsumer {
  final BuildContext _context;
  final ProfileBloc _profileBloc;

  Map<int, DestinyInventoryItemDefinition>? _definitions;
  Map<int, DestinyInventoryItemDefinition>? get definitions => _definitions;

  List<DestinyItemInfo>? _unsorted;
  List<DestinyItemInfo>? get unsortedItems => _unsorted;

  final List<ItemSortParameter> _activeSorters;

  List<ItemSortParameter> get active => _activeSorters;
  List<ItemSortParameter> get available => searchSorterOptions
      .where(
        (option) =>
            !_activeSorters.any((s) => s.type == option.type && s.type != ItemSortParameterType.Stat) &&
            !_disabledSorters.contains(option.type),
      )
      .toList();

  Set<ItemSortParameterType> _disabledSorters = {};
  set disabledSorters(Set<ItemSortParameterType> value) => _disabledSorters = value;

  SearchSorterBloc(this._context, {List<ItemSortParameter>? activeSorters})
      : _activeSorters = activeSorters?.map((e) => e.clone()).toList() ?? <ItemSortParameter>[],
        _profileBloc = _context.read<ProfileBloc>();

  Future<List<DestinyItemInfo>> sort(Iterable<DestinyItemInfo> unsorted) async {
    final characters = _profileBloc.characters ?? [];
    final hashes = unsorted.map((e) => e.itemHash).whereType<int>().toSet();
    final defs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes);
    this._definitions = defs;
    this._unsorted = unsorted.toList();
    final sorters = getSortersFromStorage(_activeSorters, _context, defs, characters);
    final sorted = await MultiSorter(sorters).sort(unsorted.toList());
    return sorted;
  }

  void addSorter(ItemSortParameter param) {
    _activeSorters.insert(0, param);
    notifyListeners();
  }

  void removeSorter(ItemSortParameter param) {
    _activeSorters.remove(param);
    notifyListeners();
  }

  void updateDirection(ItemSortParameter param, SorterDirection direction) {
    param.direction = direction;
    notifyListeners();
  }

  void reorderSorters(int oldIndex, int newIndex) {
    final param = _activeSorters.removeAt(oldIndex);
    if (oldIndex < newIndex) newIndex--;
    _activeSorters.insert(newIndex, param);
    notifyListeners();
  }
}
