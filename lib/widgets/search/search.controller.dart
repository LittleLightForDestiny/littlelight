// @dart=2.9

import 'dart:async';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/widgets.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/utils/item_filters/ammo_type_filter.dart';
import 'package:little_light/utils/item_filters/base_item_filter.dart';
import 'package:little_light/utils/item_filters/class_type_filter.dart';
import 'package:little_light/utils/item_filters/damage_type_filter.dart';
import 'package:little_light/utils/item_filters/energy_level_constraints_filter.dart';
import 'package:little_light/utils/item_filters/energy_type_filter.dart';
import 'package:little_light/utils/item_filters/item_bucket_filter.dart';
import 'package:little_light/utils/item_filters/item_subtype_filter.dart';
import 'package:little_light/utils/item_filters/item_tag_filter.dart';
import 'package:little_light/utils/item_filters/loadout_filter.dart';
import 'package:little_light/utils/item_filters/power_cap_filter.dart';
import 'package:little_light/utils/item_filters/power_level_constraints_filter.dart';
import 'package:little_light/utils/item_filters/pseudo_item_type_filter.dart';
import 'package:little_light/utils/item_filters/season_slot_filter.dart';
import 'package:little_light/utils/item_filters/text_filter.dart';
import 'package:little_light/utils/item_filters/tier_type_filter.dart';
import 'package:little_light/utils/item_filters/total_stats_constraints_filter.dart';
import 'package:little_light/utils/item_filters/wishlist_tag_filter.dart';
import 'package:little_light/utils/item_with_owner.dart';

List<BaseItemFilter> _replaceDefaultFilters(List<BaseItemFilter> defaultFilters, List<BaseItemFilter> filters) {
  List<BaseItemFilter> finalList = defaultFilters.toList();
  for (var filter in (filters ?? [])) {
    var index = finalList.indexWhere((element) => element.runtimeType == filter.runtimeType);
    if (index > -1) {
      finalList.replaceRange(index, index, [filter]);
    } else {
      finalList.insert(0, filter);
    }
  }
  return finalList;
}

class SearchController extends ChangeNotifier with ProfileConsumer, ManifestConsumer {
  List<ItemWithOwner> _unfilteredList;
  List<ItemWithOwner> _prefilteredList;
  List<ItemWithOwner> _filteredList;

  List<ItemWithOwner> get filtered => _filteredList;
  Map<int, DestinyInventoryItemDefinition> _itemDefinitions;

  List<BaseItemFilter> firstRunFilters;
  List<BaseItemFilter> preFilters;
  List<BaseItemFilter> filters;
  List<BaseItemFilter> postFilters;

  List<ItemSortParameter> defaultSorting;
  List<ItemSortParameter> customSorting;
  List<ItemSortParameterType> availableSorters;

  bool sortTags;

  SearchController(
      {this.firstRunFilters = const [],
      this.preFilters = const [],
      this.filters = const [],
      this.postFilters = const [],
      this.sortTags = true,
      this.defaultSorting,
      this.customSorting,
      this.availableSorters}) {
    _init();
  }

  factory SearchController.withDuplicatedItemsFilters(BuildContext context) {
    return SearchController(
        firstRunFilters: [
          PseudoItemTypeFilter([PseudoItemType.Weapons, PseudoItemType.Armor, PseudoItemType.Cosmetics],
              [PseudoItemType.Weapons, PseudoItemType.Armor, PseudoItemType.Cosmetics])
        ],
        sortTags: false,
        preFilters: [],
        filters: [
          PseudoItemTypeFilter(
              [PseudoItemType.Weapons, PseudoItemType.Armor, PseudoItemType.Cosmetics], [PseudoItemType.Weapons])
        ],
        postFilters: [TextFilter(context)],
        defaultSorting: [
              ItemSortParameter(
                active: true,
                type: ItemSortParameterType.BucketHash,
              )
            ] +
            getInjectedUserSettings().itemOrdering,
        customSorting: []);
  }

  factory SearchController.withDefaultFilters(BuildContext context,
      {List<BaseItemFilter> firstRunFilters,
      List<BaseItemFilter> preFilters,
      List<BaseItemFilter> filters,
      List<BaseItemFilter> postFilters,
      List<ItemSortParameter> defaultSorting,
      List<ItemSortParameter> customSorting,
      List<ItemSortParameterType> availableSorters}) {
    final _defaultFirstRunFilters = <BaseItemFilter>[];
    final _defaultPreFilters = <BaseItemFilter>[];
    final _defaultFilters = <BaseItemFilter>[
      DamageTypeFilter(),
      EnergyTypeFilter(),
      SeasonSlotFilter(),
      PowerCapFilter(),
      ClassTypeFilter(),
      AmmoTypeFilter(),
      TierTypeFilter(),
      ItemBucketFilter(),
      ItemSubtypeFilter(),
      PowerLevelConstraintsFilter(PowerLevelConstraints(), PowerLevelConstraints()),
      EnergyLevelConstraintsFilter(EnergyLevelConstraints(), EnergyLevelConstraints()),
      TotalStatsConstraintsFilter(TotalStatsConstraints(), TotalStatsConstraints()),
      LoadoutFilter(context),
      ItemTagFilter(),
      WishlistTagFilter(),
    ];
    final _defaultPostFilters = <BaseItemFilter>[
      TextFilter(context),
    ];
    return SearchController(
        firstRunFilters: _replaceDefaultFilters(_defaultFirstRunFilters, firstRunFilters),
        preFilters: _replaceDefaultFilters(_defaultPreFilters, preFilters),
        filters: _replaceDefaultFilters(_defaultFilters, filters),
        postFilters: _replaceDefaultFilters(_defaultPostFilters, postFilters),
        defaultSorting: defaultSorting ?? getInjectedUserSettings().itemOrdering,
        customSorting: customSorting ?? [],
        availableSorters: availableSorters ?? ItemSortParameter.availableEquipmentSorters);
  }

  _init() {
    _reload();
    profile.addListener(_reload);
  }

  @override
  dispose() {
    profile.removeListener(_reload);
    super.dispose();
  }

  sort() async {
    _prefilteredList = await InventoryUtils.sortDestinyItems(_prefilteredList,
        sortingParams: customSorting + defaultSorting, sortTags: sortTags);
    await update();
  }

  _reload() async {
    _unfilteredList = _getItems();
    _itemDefinitions = await _loadItemDefinitions();
    _prefilteredList = await filterItems(_unfilteredList, firstRunFilters);
    await sort();
    var _plugDefinitions = await _loadPlugDefinitions();
    _itemDefinitions.addAll(_plugDefinitions);
    update();
  }

  prioritize(BaseItemFilter filter) {
    if (preFilters.contains(filter)) {
      preFilters.remove(filter);
      preFilters.insert(0, filter);
    }
    if (filters.contains(filter)) {
      filters.remove(filter);
      filters.insert(0, filter);
    }
    if (postFilters.contains(filter)) {
      postFilters.remove(filter);
      postFilters.insert(0, filter);
    }
  }

  Future<List<ItemWithOwner>> filterItems(List<ItemWithOwner> data, List<BaseItemFilter> filters) async {
    var result = data;
    for (var _filter in filters) {
      result = await _filter.filter(result, definitions: _itemDefinitions);
    }
    return result.toList();
  }

  update() async {
    var _filters = [preFilters, filters, postFilters].expand((element) => element).toList();
    _filteredList = await filterItems(_prefilteredList, _filters);
    notifyListeners();
  }

  List<ItemWithOwner> _getItems() {
    List<ItemWithOwner> allItems = [];

    Iterable<String> charIds = profile.characters.map((char) => char.characterId);
    for (var charId in charIds) {
      allItems.addAll(profile.getCharacterEquipment(charId).map((item) => ItemWithOwner(item, charId)));
      allItems.addAll(profile.getCharacterInventory(charId).map((item) => ItemWithOwner(item, charId)));
    }
    allItems.addAll(profile.getProfileInventory().map((item) => ItemWithOwner(item, null)));
    return allItems;
  }

  _loadItemDefinitions() async {
    Set<int> hashes = _unfilteredList.map((item) => item?.item?.itemHash).where((i) => i != null).toSet();
    var _defs =
        await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes?.where((element) => element != null));
    return _defs;
  }

  _loadPlugDefinitions() async {
    Set<int> hashes = {};
    for (var item in _prefilteredList) {
      var sockets = profile.getItemSockets(item?.item?.itemInstanceId);
      var reusablePlugs = profile.getItemReusablePlugs(item?.item?.itemInstanceId);
      hashes.addAll(sockets?.map((s) => s.plugHash) ?? []);
      for (var plug in reusablePlugs?.values) {
        hashes.addAll(plug?.map((p) => p.plugItemHash) ?? []);
      }
    }
    var _defs =
        await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes?.where((element) => element != null));
    return _defs;
  }
}
