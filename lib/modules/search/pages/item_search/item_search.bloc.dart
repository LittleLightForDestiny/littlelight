import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/modules/item_details/pages/inventory_item_details/inventory_item_details.page_route.dart';
import 'package:little_light/modules/search/blocs/filter_options/item_bucket_type_filter_options.dart';
import 'package:little_light/modules/search/blocs/search_filter.bloc.dart';
import 'package:little_light/modules/search/blocs/search_sorter.bloc.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/helpers/bucket_type_groups.dart';
import 'package:provider/provider.dart';

class ItemSearchBloc extends ChangeNotifier with ManifestConsumer {
  final ProfileBloc _profileBloc;
  final SearchFilterBloc _filtersBloc;
  final SearchSorterBloc _sortersBloc;
  final UserSettingsBloc _userSettingsBloc;
  final SelectionBloc _selectionBloc;
  Set<EquipmentBucketGroup> bucketGroups;

  List<DestinyItemInfo>? _unfilteredItems;
  List<DestinyItemInfo>? _unorderedItems;
  List<DestinyItemInfo>? _items;

  List<DestinyItemInfo>? get items => _items;

  final BuildContext _context;

  ItemSearchBloc._(
    this._context,
    this._profileBloc,
    this._filtersBloc,
    this._sortersBloc,
    this._userSettingsBloc,
    this._selectionBloc,
    Set<EquipmentBucketGroup> this.bucketGroups,
  ) {
    _init();
  }

  factory ItemSearchBloc(BuildContext context, {Set<EquipmentBucketGroup> bucketGroups = const {}}) => ItemSearchBloc._(
        context,
        context.read<ProfileBloc>(),
        context.read<SearchFilterBloc>(),
        context.read<SearchSorterBloc>(),
        context.read<UserSettingsBloc>(),
        context.read<SelectionBloc>(),
        bucketGroups,
      );

  void _init() async {
    _filtersBloc.getFilter<ItemBucketTypeFilterOptions>()?.value = this.bucketGroups;
    _update();
    _profileBloc.addListener(_update);
    _sortersBloc.addListener(_sort);
    _filtersBloc.addListener(filter);
  }

  @override
  void dispose() {
    _profileBloc.removeListener(_update);
    _sortersBloc.removeListener(_sort);
    _filtersBloc.removeListener(filter);
    super.dispose();
  }

  void _update() async {
    final allItems = _profileBloc.allInstancedItems;
    final hashes = allItems.map((e) => e.itemHash).whereType<int>().toSet();
    final defs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes);
    bool hasArmor = false;
    bool hasWeapon = false;
    final unfiltered = allItems.where((item) {
      final def = defs[item.itemHash];
      if (def == null) return false;
      if (def.itemType == DestinyItemType.Armor) hasArmor = true;
      if (def.itemType == DestinyItemType.Weapon) hasWeapon = true;
      _filtersBloc.addValue(item);
      return true;
    });
    final _disabledSorters = <ItemSortParameterType>{
      if (!hasArmor) ItemSortParameterType.StatTotal,
      if (!hasWeapon) ItemSortParameterType.AmmoType,
      if (!hasWeapon) ItemSortParameterType.DamageType,
      ItemSortParameterType.BucketHash,
      ItemSortParameterType.Quantity,
    };

    _sortersBloc.disabledSorters = _disabledSorters;

    _unorderedItems = unfiltered.toList();
    _unfilteredItems = await _sortersBloc.sort(unfiltered);
    filter();
  }

  void _sort() async {
    final unfiltered = _unorderedItems;
    if (unfiltered == null) return;
    _unfilteredItems = await _sortersBloc.sort(unfiltered);
    filter();
  }

  void filter() async {
    List<DestinyItemInfo> items = _unfilteredItems?.toList() ?? [];
    _items = await _filtersBloc.filter(items);
    notifyListeners();
  }

  void onItemTap(InventoryItemInfo item) {
    final hash = item.itemHash;
    final instanceId = item.instanceId;
    final stackIndex = item.stackIndex;

    if (hash == null) return;

    if (_selectionBloc.hasSelection || _userSettingsBloc.tapToSelect) {
      return _selectionBloc.toggleSelected(
        hash,
        instanceId: instanceId,
        stackIndex: stackIndex,
      );
    }

    Navigator.of(_context).push(InventoryItemDetailsPageRoute(item));
  }

  void onItemHold(InventoryItemInfo item) {
    final hash = item.itemHash;
    final instanceId = item.instanceId;
    final stackIndex = item.stackIndex;
    if (hash == null) return;
    if (_userSettingsBloc.tapToSelect) {
      Navigator.of(_context).push(InventoryItemDetailsPageRoute(item));
      return;
    }
    return _selectionBloc.toggleSelected(
      hash,
      instanceId: instanceId,
      stackIndex: stackIndex,
    );
  }
}
