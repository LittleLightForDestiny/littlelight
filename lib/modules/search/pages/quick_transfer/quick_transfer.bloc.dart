import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/modules/search/blocs/filter_types/base_filter_values_wrapper.dart';
import 'package:little_light/modules/search/blocs/filter_types/text_filter_wrapper.dart';
import 'package:little_light/modules/search/blocs/filters/base_item_filter.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/models/transfer_destination.dart';
import 'package:provider/provider.dart';

import '../../blocs/filters/text_filter.dart';

class QuickTransferBloc extends ChangeNotifier with ManifestConsumer {
  final ProfileBloc _profileBloc;
  final InventoryBloc _inventoryBloc;

  final int? bucketHash;
  final String? characterId;

  List<DestinyItemInfo>? _unfilteredItems;
  List<DestinyItemInfo>? _items;
  List<DestinyItemInfo>? get items => _items;

  Map<Type, BaseItemFilter> _filters = {
    TextFilterWrapper: TextFilter(),
  };

  final BuildContext _context;

  QuickTransferBloc(
    BuildContext this._context, {
    this.bucketHash,
    this.characterId,
  })  : _profileBloc = _context.read<ProfileBloc>(),
        _inventoryBloc = _context.read<InventoryBloc>() {
    _init();
  }
  void _init() async {
    final allItems = _profileBloc.allInstancedItems;
    final hashes = allItems.map((e) => e.itemHash).whereType<int>().toSet();
    final defs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes);
    final character = _profileBloc.getCharacterById(characterId);
    final characterClass = character?.character.classType;
    final acceptedClasses = [characterClass, DestinyClass.Unknown].whereType<DestinyClass>();
    final unfiltered = allItems.where((item) {
      final def = defs[item.itemHash];
      if (def == null) return false;
      if (item.bucketHash == bucketHash && item.characterId == characterId) return false;
      if (def.inventory?.bucketTypeHash != bucketHash) return false;
      if (!acceptedClasses.contains(def.classType)) return false;
      return true;
    });
    _unfilteredItems = unfiltered.toList();
    _items = unfiltered.toList();
    notifyListeners();
  }

  void filter() async {
    List<DestinyItemInfo> items = _unfilteredItems?.toList() ?? [];
    for (final _filter in _filters.values) {
      _items = await _filter.filter(_context, items);
    }
    notifyListeners();
  }

  void onItemTap(DestinyItemInfo item) async {
    final character = _profileBloc.getCharacterById(this.characterId);
    _inventoryBloc.transfer(item, TransferDestination(TransferDestinationType.character, character: character));
    Navigator.of(_context).pop();
  }

  void onItemHold(DestinyItemInfo item) {}

  Map<Type, BaseFilterValuesWrapper> get filters {
    return _filters.map(
      (key, value) => MapEntry(key, value.data),
    );
  }

  void updateFilterValue<T extends BaseFilterValuesWrapper>(T value) {
    final filter = this._filters[T];
    print(value);
    if (filter == null) return;
    filter.updateValue(value);
    notifyListeners();
    this.filter();
  }
}
