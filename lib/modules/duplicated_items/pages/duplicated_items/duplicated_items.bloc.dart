import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/models/item_info/definition_item_info.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/modules/item_details/pages/definition_item_details/definition_item_details.page_route.dart';
import 'package:little_light/modules/item_details/pages/inventory_item_details/inventory_item_details.page_route.dart';
import 'package:little_light/modules/search/blocs/filter_options/export.dart';
import 'package:little_light/modules/search/blocs/search_filter.bloc.dart';
import 'package:little_light/pages/item_details/item_details.page_route.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:provider/provider.dart';

typedef ItemsByBucket = Map<int, Map<int, List<DestinyItemInfo>>>;

class DuplicatedItemsBloc extends ChangeNotifier {
  final BuildContext context;

  @protected
  final ProfileBloc profileBloc;

  @protected
  final UserSettingsBloc userSettingsBloc;

  @protected
  final SearchFilterBloc filterBloc;

  @protected
  final SelectionBloc selectionBloc;

  @protected
  final ManifestService manifest;

  ItemsByBucket? _unfilteredItems;
  ItemsByBucket? _filteredItems;

  ItemsByBucket? get items => _filteredItems;

  Map<int, DefinitionItemInfo>? _genericItems;
  Map<int, DefinitionItemInfo>? get genericItems => _genericItems;

  bool _searchOpen = false;
  bool get searchOpen => _searchOpen;
  bool loaded = false;

  DuplicatedItemsBloc(BuildContext this.context)
      : profileBloc = context.read<ProfileBloc>(),
        manifest = context.read<ManifestService>(),
        filterBloc = context.read<SearchFilterBloc>(),
        selectionBloc = context.read<SelectionBloc>(),
        userSettingsBloc = context.read<UserSettingsBloc>(),
        super() {
    _init();
  }

  void _init() {
    this.profileBloc.addListener(_update);
    this.filterBloc.addListener(_filter);
    _loadDefinitions();
    _update();
  }

  void _loadDefinitions() async {
    final hashes = <int>[];
    final items = profileBloc.allItems;
    for (final i in items) {
      final itemHash = i.itemHash;
      if (itemHash != null) hashes.add(itemHash);
    }
    await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes);
    loaded = true;
    notifyListeners();
  }

  @override
  void dispose() {
    this.profileBloc.removeListener(_update);
    this.filterBloc.removeListener(_filter);
    super.dispose();
  }

  _update() async {
    final instancedItems = profileBloc.allInstancedItems;
    final hashes = instancedItems.map((e) => e.itemHash).whereType<int>().toSet();
    final defs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes);
    final map = <int, Map<int, List<DestinyItemInfo>>>{};
    final genericItems = _genericItems ??= {};
    for (final itemHash in hashes) {
      final def = defs[itemHash];
      final bucketHash = def?.inventory?.bucketTypeHash;
      if (bucketHash == null) continue;
      final bucketHashMap = map[bucketHash] ??= {};
      final items = profileBloc.getItemsByHash(itemHash);
      if (items.length <= 1) continue;
      if (def != null) genericItems[itemHash] ??= DefinitionItemInfo.fromDefinition(def);
      for (final item in items) filterBloc.addValue(item);
      bucketHashMap[itemHash] = items.toList();
    }
    _unfilteredItems = map;
    _filter();
  }

  _filter() async {
    final filtered = <int, Map<int, List<DestinyItemInfo>>>{};
    final unfiltered = _unfilteredItems;
    if (unfiltered == null) return;
    for (final bucket in unfiltered.entries) {
      final bucketHash = bucket.key;
      final itemTypes = bucket.value.entries;
      final filteredBucket = <int, List<DestinyItemInfo>>{};
      for (final itemType in itemTypes) {
        final filteredItems = await filterBloc.filter(itemType.value);
        if (filteredItems.isNotEmpty) filteredBucket[itemType.key] = filteredItems;
      }
      if (filteredBucket.isNotEmpty) filtered[bucketHash] = filteredBucket;
    }
    _filteredItems = filtered;
    notifyListeners();
  }

  void toggleSearchOpen() {
    _searchOpen = !_searchOpen;
    filterBloc.updateValue<TextFilterOptions>(TextFilterOptions(""));
    notifyListeners();
  }

  void onItemTap(DestinyItemInfo item) {
    if (item is InventoryItemInfo) _onInstanceItemTap(item);
    if (item is DefinitionItemInfo) _onDefinitionTap(item);
  }

  void _onInstanceItemTap(InventoryItemInfo item) {
    final hash = item.itemHash;
    final instanceId = item.instanceId;
    final stackIndex = item.stackIndex;

    if (hash == null) return;

    if (selectionBloc.hasSelection || userSettingsBloc.tapToSelect) {
      return selectionBloc.toggleSelected(
        hash,
        instanceId: instanceId,
        stackIndex: stackIndex,
      );
    }

    Navigator.of(context).push(InventoryItemDetailsPageRoute(item));
  }

  void _onDefinitionTap(DestinyItemInfo item) {
    final hash = item.itemHash;

    if (hash == null) return;

    if (selectionBloc.hasSelection || userSettingsBloc.tapToSelect) {
      final items = profileBloc.getItemsByHash(hash);
      if (items.isEmpty) return;
      final areAllSelected = items.every((element) => selectionBloc.isItemSelected(element));
      if (areAllSelected) {
        selectionBloc.unselectItems(items);
      } else {
        selectionBloc.selectItems(items);
      }
      return;
    }

    Navigator.of(context).push(DefinitionItemDetailsPageRoute(hash));
  }

  void onItemHold(DestinyItemInfo item) {
    if (item is InventoryItemInfo) _onInstanceItemHold(item);
    if (item is DefinitionItemInfo) _onDefinitionHold(item);
  }

  void _onInstanceItemHold(InventoryItemInfo item) {
    final hash = item.itemHash;
    final instanceId = item.instanceId;
    final stackIndex = item.stackIndex;
    if (hash == null) return;
    if (userSettingsBloc.tapToSelect) {
      Navigator.of(context).push(ItemDetailsPageRoute.itemInfo(item: item));
      return;
    }
    return selectionBloc.toggleSelected(
      hash,
      instanceId: instanceId,
      stackIndex: stackIndex,
    );
  }

  void _onDefinitionHold(DestinyItemInfo item) {
    final hash = item.itemHash;
    if (hash == null) return;

    if (userSettingsBloc.tapToSelect) {
      Navigator.of(context).push(DefinitionItemDetailsPageRoute(hash));
      return;
    }

    final items = profileBloc.getItemsByHash(hash);
    if (items.isEmpty) return;

    final allSelected = items.every((element) => selectionBloc.isItemSelected(element));
    if (allSelected) {
      selectionBloc.unselectItems(items);
    } else {
      selectionBloc.selectItems(items);
    }
  }
}
