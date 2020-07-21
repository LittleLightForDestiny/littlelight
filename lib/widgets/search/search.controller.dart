import 'dart:async';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/widgets.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/user_settings/item_sort_parameter.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/utils/item_filters/ammo_type_filter.dart';
import 'package:little_light/utils/item_filters/base_item_filter.dart';
import 'package:little_light/utils/item_filters/class_type_filter.dart';
import 'package:little_light/utils/item_filters/damage_type_filter.dart';
import 'package:little_light/utils/item_filters/energy_level_constraints_filter.dart';
import 'package:little_light/utils/item_filters/energy_type_filter.dart';
import 'package:little_light/utils/item_filters/item_bucket_filter.dart';
import 'package:little_light/utils/item_filters/item_subtype_filter.dart';
import 'package:little_light/utils/item_filters/loadout_filter.dart';
import 'package:little_light/utils/item_filters/power_cap_filter.dart';
import 'package:little_light/utils/item_filters/power_level_constraints_filter.dart';
import 'package:little_light/utils/item_filters/season_slot_filter.dart';
import 'package:little_light/utils/item_filters/text_filter.dart';
import 'package:little_light/utils/item_filters/tier_type_filter.dart';
import 'package:little_light/utils/item_filters/total_stats_constraints_filter.dart';
import 'package:little_light/utils/item_filters/wishlist_tag_filter.dart';
import 'package:little_light/utils/item_with_owner.dart';

List<BaseItemFilter> _replaceDefaultFilters(
    List<BaseItemFilter> defaultFilters, List<BaseItemFilter> filters) {
  List<BaseItemFilter> finalList = defaultFilters.toList();
  for (var filter in (filters ?? [])) {
    var index = finalList
        .indexWhere((element) => element.runtimeType == filter.runtimeType);
    if (index > -1) {
      finalList.replaceRange(index, index, [filter]);
    } else {
      finalList.insert(0, filter);
    }
  }
  return finalList;
}

class SearchController extends ChangeNotifier {
  List<ItemWithOwner> _unfilteredList;
  List<ItemWithOwner> _prefilteredList;
  List<ItemWithOwner> _filteredList;

  StreamSubscription<NotificationEvent> _subscription;

  List<ItemWithOwner> get filtered => _filteredList;
  Map<int, DestinyInventoryItemDefinition> _itemDefinitions;

  List<BaseItemFilter> firstRunFilters;
  List<BaseItemFilter> preFilters;
  List<BaseItemFilter> filters;
  List<BaseItemFilter> postFilters;

  List<ItemSortParameter> defaultSorting;
  List<ItemSortParameter> customSorting;
  List<ItemSortParameterType> availableSorters;

  SearchController(
      {this.firstRunFilters = const [],
      this.preFilters = const [],
      this.filters = const [],
      this.postFilters = const [],
      this.defaultSorting,
      this.customSorting,
      this.availableSorters}) {
    _init();
  }

  factory SearchController.withDefaultFilters(
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
      PowerLevelConstraintsFilter(
          PowerLevelConstraints(), PowerLevelConstraints()),
      EnergyLevelConstraintsFilter(
          EnergyLevelConstraints(), EnergyLevelConstraints()),
      TotalStatsConstraintsFilter(
          TotalStatsConstraints(), TotalStatsConstraints()),
      LoadoutFilter(),
      WishlistTagFilter(),
    ];
    final _defaultPostFilters = <BaseItemFilter>[
      TextFilter(),
    ];
    return SearchController(
        firstRunFilters:
            _replaceDefaultFilters(_defaultFirstRunFilters, firstRunFilters),
        preFilters: _replaceDefaultFilters(_defaultPreFilters, preFilters),
        filters: _replaceDefaultFilters(_defaultFilters, filters),
        postFilters: _replaceDefaultFilters(_defaultPostFilters, postFilters),
        defaultSorting: defaultSorting ?? UserSettingsService().itemOrdering,
        customSorting: customSorting ?? [],
        availableSorters:
            availableSorters ?? ItemSortParameter.availableEquipmentSorters);
  }

  _init() {
    _reload();
    _subscription = NotificationService().listen((event) {
      if (event.type == NotificationType.receivedUpdate) {
        _reload();
      }
    });
  }

  @override
  dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }

  sort() async {
    this._prefilteredList = await InventoryUtils.sortDestinyItems(
        this._prefilteredList,
        sortingParams: this.customSorting + this.defaultSorting);
    await update();
  }

  _reload() async {
    this._unfilteredList = _getItems();
    this._itemDefinitions = await _loadItemDefinitions();
    this._prefilteredList =
        await filterItems(this._unfilteredList, this.firstRunFilters);
    await sort();
    var _plugDefinitions = await this._loadPlugDefinitions();
    this._itemDefinitions.addAll(_plugDefinitions);
    update();
  }

  prioritize(BaseItemFilter filter) {
    if (this.preFilters.contains(filter)) {
      this.preFilters.remove(filter);
      this.preFilters.insert(0, filter);
    }
    if (this.filters.contains(filter)) {
      this.filters.remove(filter);
      this.filters.insert(0, filter);
    }
    if (this.postFilters.contains(filter)) {
      this.postFilters.remove(filter);
      this.postFilters.insert(0, filter);
    }
  }

  Future<List<ItemWithOwner>> filterItems(
      List<ItemWithOwner> data, List<BaseItemFilter> filters) async {
    var result = data;
    for (var _filter in filters) {
      result = await _filter.filter(result, definitions: _itemDefinitions);
    }
    return result.toList();
  }

  update() async {
    var _filters = [preFilters, filters, postFilters]
        .expand((element) => element)
        .toList();
    this._filteredList = await this.filterItems(_prefilteredList, _filters);
    notifyListeners();
  }

  List<ItemWithOwner> _getItems() {
    List<ItemWithOwner> allItems = [];
    ProfileService profile = ProfileService();
    Iterable<String> charIds =
        profile.getCharacters().map((char) => char.characterId);
    charIds.forEach((charId) {
      allItems.addAll(profile
          .getCharacterEquipment(charId)
          .map((item) => ItemWithOwner(item, charId)));
      allItems.addAll(profile
          .getCharacterInventory(charId)
          .map((item) => ItemWithOwner(item, charId)));
    });
    allItems.addAll(
        profile.getProfileInventory().map((item) => ItemWithOwner(item, null)));
    return allItems;
  }

  _loadItemDefinitions() async {
    Set<int> hashes = _unfilteredList
        .map((item) => item?.item?.itemHash)
        .where((i) => i != null)
        .toSet();
    var _defs = await ManifestService()
        .getDefinitions<DestinyInventoryItemDefinition>(
            hashes?.where((element) => element != null));
    return _defs;
  }

  _loadPlugDefinitions() async {
    Set<int> hashes = Set();
    _prefilteredList.forEach((item) {
      var sockets = ProfileService().getItemSockets(item?.item?.itemInstanceId);
      var reusablePlugs =
          ProfileService().getItemReusablePlugs(item?.item?.itemInstanceId);
      hashes.addAll(sockets?.map((s) => s.plugHash) ?? []);
      reusablePlugs?.values?.forEach((plug) {
        hashes.addAll(plug?.map((p) => p.plugItemHash) ?? []);
      });
    });
    var _defs = await ManifestService()
        .getDefinitions<DestinyInventoryItemDefinition>(
            hashes?.where((element) => element != null));
    return _defs;
  }
}
