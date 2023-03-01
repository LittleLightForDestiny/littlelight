import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/modules/search/blocs/filter_options/ammo_type_filter_options.dart';
import 'package:little_light/modules/search/blocs/filter_options/base_filter_values_options.dart';
import 'package:little_light/modules/search/blocs/filter_options/class_type_filter_options.dart';
import 'package:little_light/modules/search/blocs/filter_options/damage_type_filter_options.dart';
import 'package:little_light/modules/search/blocs/filter_options/energy_level_filter_options.dart';
import 'package:little_light/modules/search/blocs/filter_options/energy_type_filter_options.dart';
import 'package:little_light/modules/search/blocs/filter_options/item_bucket_filter_options.dart';
import 'package:little_light/modules/search/blocs/filter_options/item_owner_filter_options.dart';
import 'package:little_light/modules/search/blocs/filter_options/text_filter_options.dart';
import 'package:little_light/modules/search/blocs/filters/ammo_type_filter.dart';
import 'package:little_light/modules/search/blocs/filters/base_item_filter.dart';
import 'package:little_light/modules/search/blocs/filters/class_type_filter.dart';
import 'package:little_light/modules/search/blocs/filters/damage_type_filter.dart';
import 'package:little_light/modules/search/blocs/filters/energy_level_filter.dart';
import 'package:little_light/modules/search/blocs/filters/energy_type_filter.dart';
import 'package:little_light/modules/search/blocs/filters/item_bucket_filter.dart';
import 'package:little_light/modules/search/blocs/filters/item_owner_filter.dart';
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
    TextFilterOptions: TextFilter(),
    AmmoTypeFilterOptions: AmmoTypeFilter(),
    DamageTypeFilterOptions: DamageTypeFilter(),
    ClassTypeFilterOptions: ClassTypeFilter(),
    EnergyLevelFilterOptions: EnergyLevelFilter(),
    EnergyTypeFilterOptions: EnergyTypeFilter(),
    ItemBucketFilterOptions: ItemBucketFilter(),
    ItemOwnerFilterOptions: ItemOwnerFilter(),
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
    final defs =
        await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes);
    final character = _profileBloc.getCharacterById(characterId);
    final characterClass = character?.character.classType;
    final acceptedClasses =
        [characterClass, DestinyClass.Unknown].whereType<DestinyClass>();
    final unfiltered = allItems.where((item) {
      final def = defs[item.itemHash];
      if (def == null) return false;
      if (item.bucketHash == bucketHash && item.characterId == characterId)
        return false;
      if (def.inventory?.bucketTypeHash != bucketHash) return false;
      if (!acceptedClasses.contains(def.classType)) return false;
      _addValueToFilters(item);
      return true;
    });
    _unfilteredItems = unfiltered.toList();
    _items = unfiltered.toList();
    notifyListeners();
  }

  void _addValueToFilters(DestinyItemInfo item) {
    for (final f in _filters.values) {
      f.addValue(item);
    }
  }

  void filter() async {
    List<DestinyItemInfo> items = _unfilteredItems?.toList() ?? [];
    for (final _filter in _filters.values) {
      items = await _filter.filter(_context, items);
    }
    _items = items;
    notifyListeners();
  }

  void onItemTap(DestinyItemInfo item) async {
    final character = _profileBloc.getCharacterById(this.characterId);
    _inventoryBloc.transfer(
        item,
        TransferDestination(TransferDestinationType.character,
            character: character));
    Navigator.of(_context).pop();
  }

  void onItemHold(DestinyItemInfo item) {}

  Map<Type, BaseFilterOptions> get filters {
    return _filters.map(
      (key, value) => MapEntry(key, value.data),
    );
  }

  void updateFilterValue<T extends BaseFilterOptions>(T value) {
    final filter = this._filters[T];
    if (filter == null) return;
    filter.updateValue(value);
    notifyListeners();
    this.filter();
  }

  void updateFilterEnabledStatus<T extends BaseFilterOptions>(bool value) {
    final filter = this._filters[T];
    if (filter == null) return;
    filter.updateEnabled(value);
    notifyListeners();
    this.filter();
  }

  void updateFilterSetValue<Y, T extends BaseFilterOptions<Set<Y>>>(
      T type, Y value, bool forceAdd) {
    final filter = this._filters[T];
    if (filter == null) return;
    final elements = type.value.toSet();
    final multiselect = forceAdd || elements.length > 1;
    final isSelected = elements.contains(value);
    if (multiselect && !isSelected) {
      elements.add(value);
    } else if (isSelected) {
      elements.remove(value);
    } else {
      elements.clear();
      elements.add(value);
    }
    type.value = elements;
    filter.updateValue(type);
    notifyListeners();
    this.filter();
  }
}
