import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/modules/search/blocs/search_filter.bloc.dart';
import 'package:little_light/modules/search/blocs/search_sorter.bloc.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/models/transfer_destination.dart';
import 'package:provider/provider.dart';

class QuickTransferBloc extends ChangeNotifier with ManifestConsumer {
  final ProfileBloc _profileBloc;
  final InventoryBloc _inventoryBloc;
  final SearchFilterBloc _filtersBloc;
  final SearchSorterBloc _sortersBloc;

  final int? bucketHash;
  final String? characterId;

  List<DestinyItemInfo>? _unfilteredItems;
  List<DestinyItemInfo>? _unorderedItems;
  List<DestinyItemInfo>? _items;
  List<DestinyItemInfo>? get items => _items;

  final BuildContext _context;

  QuickTransferBloc._(
    this._context,
    this._profileBloc,
    this._inventoryBloc,
    this._filtersBloc,
    this._sortersBloc, {
    required this.bucketHash,
    required this.characterId,
  }) {
    _init();
  }

  factory QuickTransferBloc(
    BuildContext context, {
    int? bucketHash,
    String? characterId,
  }) =>
      QuickTransferBloc._(
        context,
        context.read<ProfileBloc>(),
        context.read<InventoryBloc>(),
        context.read<SearchFilterBloc>(),
        context.read<SearchSorterBloc>(),
        bucketHash: bucketHash,
        characterId: characterId,
      );

  void _init() async {
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
    final character = _profileBloc.getCharacterById(characterId);
    final characterClass = character?.character.classType;
    final acceptedClasses = [characterClass, DestinyClass.Unknown].whereType<DestinyClass>();

    bool hasArmor = false;
    bool hasWeapon = false;
    final unfiltered = allItems.where((item) {
      final def = defs[item.itemHash];
      if (def == null) return false;
      if (item.bucketHash == bucketHash && item.characterId == characterId) return false;
      if (def.inventory?.bucketTypeHash != bucketHash) return false;
      if (!acceptedClasses.contains(def.classType)) return false;
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
    final character = _profileBloc.getCharacterById(this.characterId);
    _inventoryBloc.transfer(item, TransferDestination(TransferDestinationType.character, character: character));
    Navigator.of(_context).pop();
  }

  void onItemHold(DestinyItemInfo item) {}
}
