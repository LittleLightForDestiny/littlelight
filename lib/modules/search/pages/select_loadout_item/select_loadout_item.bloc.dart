import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/modules/search/blocs/search_filter.bloc.dart';
import 'package:little_light/modules/search/blocs/search_sorter.bloc.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/helpers/page_transition_helpers.dart';
import 'package:provider/provider.dart';

class SelectLoadoutItemBloc extends ChangeNotifier with ManifestConsumer {
  final BuildContext _context;
  final ProfileBloc _profileBloc;
  final SearchFilterBloc _filtersBloc;
  final SearchSorterBloc _sortersBloc;

  final int? emblemHash;
  final List<String>? idsToAvoid;

  final int? bucketHash;
  final DestinyClass? classType;

  List<DestinyItemInfo>? _unfilteredItems;
  List<DestinyItemInfo>? _unorderedItems;
  List<DestinyItemInfo>? _items;

  List<DestinyItemInfo>? get items => _items;

  bool _busy = true;
  bool get busy => _busy;

  SelectLoadoutItemBloc(
    BuildContext context, {
    int? this.bucketHash,
    DestinyClass? this.classType,
    int? this.emblemHash,
    List<String>? this.idsToAvoid,
  })  : this._context = context,
        this._profileBloc = context.read<ProfileBloc>(),
        this._filtersBloc = context.read<SearchFilterBloc>(),
        this._sortersBloc = context.read<SearchSorterBloc>(),
        super() {
    _init();
  }

  void _init() async {
    await _context.waitForPageTransitionToFinish();
    _busy = false;
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
    final acceptedClasses = [classType, DestinyClass.Unknown].whereType<DestinyClass>();

    bool hasArmor = false;
    bool hasWeapon = false;
    final unfiltered = allItems.where((item) {
      final def = defs[item.itemHash];
      if (def == null) return false;
      if (classType != null && !acceptedClasses.contains(def.classType)) return false;
      if (def.inventory?.bucketTypeHash != bucketHash) return false;
      if (idsToAvoid?.contains(item.instanceId) ?? false) return false;

      if (def.itemType == DestinyItemType.Armor) hasArmor = true;
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

  void onItemTap(InventoryItemInfo item) async {
    Navigator.of(_context).pop(item);
  }

  void onItemHold(DestinyItemInfo item) {
    //TODO: implement read only item details
  }
}
