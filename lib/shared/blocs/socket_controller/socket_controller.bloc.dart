import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/core/blocs/littlelight_data/littlelight_data.bloc.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/shared/utils/extensions/inventory_item_data.dart';
import 'package:little_light/shared/utils/helpers/stat_helpers.dart';
import 'package:provider/provider.dart';

class PlugSocket {
  final int index;
  final List<int> availablePlugHashes;

  PlugSocket(this.index, this.availablePlugHashes);
}

abstract class SocketControllerBloc<T> extends ChangeNotifier {
  Set<int>? _allAvailablePlugHashes;
  Set<int>? get allAvailablePlugHashes => _allAvailablePlugHashes;

  Set<int>? _allEquippedPlugHashes;
  Set<int>? get allEquippedPlugHashes => _allEquippedPlugHashes;

  Set<int>? _allSelectedPlugHashes;
  Set<int>? get allSelectedPlugHashes => _allSelectedPlugHashes;

  Map<int, List<int>?> _availablePlugHashesBySocket = {};
  List<int>? availablePlugHashesForSocket(int socket) => _availablePlugHashesBySocket[socket];

  Map<int, List<int>?> _randomPlugHashesBySocket = {};
  List<int>? randomPlugHashesForSocket(int socket) => _randomPlugHashesBySocket[socket];

  @protected
  Map<int, int?> selectedPlugHashes = {};
  int? _selectedSocketIndex;

  Map<int, Map<int, bool>>? _canApply;

  Map<int, Map<int, bool>>? _isAvailable;

  @protected
  final BuildContext context;

  @protected
  final ManifestService manifest;

  @protected
  final WishlistsService wishlists;

  @protected
  final ItemNotesBloc itemNotes;

  @protected
  final LittleLightDataBloc littlelightData;

  @protected
  DestinyInventoryItemDefinition? itemDefinition;

  @protected
  Map<int, DestinySocketCategoryDefinition>? categoryDefinitions;

  List<StatValues>? _stats;

  List<StatComparison>? _selectedPlugStats;
  List<StatComparison>? get selectedPlugStats => _selectedPlugStats;

  List<StatValues>? get stats => _stats;

  StatValues? _totalStats;
  StatValues? get totalStats => _totalStats;

  StatValues? _usedEnergyCapacity;
  StatValues? get usedEnergyCapacity => _usedEnergyCapacity;

  StatValues? _availableEnergyCapacity;
  StatValues? get availableEnergyCapacity => _availableEnergyCapacity;

  int? get itemHash => itemDefinition?.hash;

  int? get socketCount => itemDefinition?.sockets?.socketEntries?.length;

  bool get isBusy;

  SocketControllerBloc(this.context)
      : manifest = context.read<ManifestService>(),
        wishlists = getInjectedWishlistsService(),
        itemNotes = context.read<ItemNotesBloc>(),
        littlelightData = context.read<LittleLightDataBloc>(),
        super() {
    _initGameData();
  }

  void _initGameData() {
    littlelightData.addListener(_updateGameData);
    _updateGameData();
  }

  void _updateGameData() {
    notifyListeners();
  }

  @override
  dispose() {
    super.dispose();
    littlelightData.removeListener(_updateGameData);
  }

  List<DestinyItemSocketCategoryDefinition>? getSocketCategories(DestinySocketCategoryStyle? category) {
    final categories = itemDefinition?.sockets?.socketCategories?.where((socketCategory) {
      return socketsForCategory(socketCategory)?.isNotEmpty ?? false;
    }).toList();
    final categoryDefs = categoryDefinitions;
    final cosmeticSockets = littlelightData.gameData?.cosmeticSocketCategories;
    if (categories == null) return null;
    if (categoryDefs == null) return null;
    categories.sort((a, b) {
      final isCosmeticsA = (cosmeticSockets?.contains(a.socketCategoryHash) ?? false) ? 1 : 0;
      final isCosmeticsB = (cosmeticSockets?.contains(b.socketCategoryHash) ?? false) ? 1 : 0;
      final cosmeticsDiff = isCosmeticsA.compareTo(isCosmeticsB);
      if (cosmeticsDiff != 0) return cosmeticsDiff;
      final indexA = categoryDefs[a.socketCategoryHash]?.index ?? 0;
      final indexB = categoryDefs[b.socketCategoryHash]?.index ?? 0;
      return indexA.compareTo(indexB);
    });

    if (category == null) return categories;

    final filteredCategories = categories.where((element) {
      final def = categoryDefs[element.socketCategoryHash];
      return def?.categoryStyle == category;
    });
    return filteredCategories.toList();
  }

  @protected
  @mustCallSuper
  Future<void> loadDefinitions(int itemHash) async {
    itemDefinition = await manifest.getDefinition<DestinyInventoryItemDefinition>(itemHash);

    final categoryHashes = itemDefinition?.sockets?.socketCategories?.map((e) => e.socketCategoryHash);
    if (categoryHashes != null && categoryHashes.length > 0) {
      final categoryDefinitions = await manifest.getDefinitions<DestinySocketCategoryDefinition>(categoryHashes);
      this.categoryDefinitions = categoryDefinitions;
    }
    final plugHashes = <int>{};
    final totalSockets = itemDefinition?.sockets?.socketEntries?.length ?? 0;
    for (int i = 0; i < totalSockets; i++) {
      final equipped = equippedPlugHashForSocket(i);
      final available = await loadAvailablePlugHashesForSocket(i);
      final random = await loadRandomPlugHashesForSocket(i);
      if (equipped != null) plugHashes.add(equipped);
      if (available != null) plugHashes.addAll(available);
      final sortedAvailable = available?.toList().sorted((a, b) {
        final favoriteA = isFavoritePlug(a) ? 1 : 0;
        final favoriteB = isFavoritePlug(b) ? 1 : 0;
        final favoriteDiff = favoriteB.compareTo(favoriteA);
        if (favoriteDiff != 0) return favoriteDiff;
        return available.indexOf(a).compareTo(available.indexOf(b));
      });
      _availablePlugHashesBySocket[i] = sortedAvailable;
      _randomPlugHashesBySocket[i] = random;
    }
    _allAvailablePlugHashes = plugHashes;

    _canApply = await loadCanApply();

    loadAdditionalDefinitions();

    refresh();
  }

  List<PlugSocket>? socketsForCategory(DestinyItemSocketCategoryDefinition category) {
    final sockets = category.socketIndexes
        ?.map((socketIndex) {
          final hashes = availablePlugHashesForSocket(socketIndex);
          final hasAvailableRolls = hashes?.isNotEmpty ?? false;
          final hasRandomRolls = randomPlugHashesForSocket(socketIndex)?.isNotEmpty ?? false;
          if (!hasAvailableRolls && !hasRandomRolls) return null;
          return PlugSocket(socketIndex, hashes ?? []);
        })
        .whereType<PlugSocket>()
        .toList();
    return sockets;
  }

  PlugSocket? selectedSocketForCategory(DestinyItemSocketCategoryDefinition category) {
    final index = _selectedSocketIndex;
    if (index == null) return null;
    final categoryIsSelected = category.socketIndexes?.contains(index) ?? false;
    if (!categoryIsSelected) return null;
    final hashes = _availablePlugHashesBySocket[index];
    if (hashes == null) return null;
    return PlugSocket(index, hashes);
  }

  bool isEquipped(int socketIndex, int plugHash);

  bool isSelected(int socketIndex, int plugHash) {
    return selectedPlugHashes[socketIndex] == plugHash;
  }

  int? get selectedSocketIndex => _selectedSocketIndex;

  void toggleSocketSelection(int socketIndex) {
    final isSameSocketIndex = _selectedSocketIndex == socketIndex;
    if (isSameSocketIndex) {
      _selectedSocketIndex = null;
    } else {
      _selectedSocketIndex = socketIndex;
    }
    notifyListeners();
  }

  void toggleSelection(int socketIndex, int plugHash) {
    final isCurrentlySelected = isSelected(socketIndex, plugHash);
    final isSameSocketIndex = _selectedSocketIndex == socketIndex;
    if (isCurrentlySelected && isSameSocketIndex) {
      selectedPlugHashes.remove(socketIndex);
      _selectedSocketIndex = null;
      refresh();
      notifyListeners();
      return;
    }

    selectedPlugHashes[socketIndex] = plugHash;
    _selectedSocketIndex = socketIndex;
    refresh();
    notifyListeners();
    return;
  }

  Future<void> init(T object);
  Future<void> update(T object);

  int? equippedPlugHashForSocket(int? socketIndex);
  int? selectedPlugHashForSocket(int? socketIndex) => selectedPlugHashes[socketIndex];

  int? selectedSocketIndexForCategory(DestinyItemSocketCategoryDefinition category) {
    final categoryIsSelected = category.socketIndexes?.contains(_selectedSocketIndex) ?? false;
    if (!categoryIsSelected) return null;
    return _selectedSocketIndex;
  }

  int? selectedPlugForCategory(DestinyItemSocketCategoryDefinition category) {
    final categoryIsSelected = category.socketIndexes?.contains(_selectedSocketIndex) ?? false;
    if (!categoryIsSelected) return null;
    return selectedPlugHashes[_selectedSocketIndex];
  }

  bool canFavorite(DestinyItemSocketCategoryDefinition category) {
    return littlelightData.gameData?.cosmeticSocketCategories?.contains(category.socketCategoryHash) ?? false;
  }

  bool canFavoriteSocket(int? socketIndex) {
    final cosmeticCategories = littlelightData.gameData?.cosmeticSocketCategories;
    if (cosmeticCategories == null) return false;
    final categories = itemDefinition?.sockets?.socketCategories;
    if (categories == null || categories.isEmpty) return false;
    return categories.any((c) =>
        cosmeticCategories.contains(
          c.socketCategoryHash,
        ) &&
        (c.socketIndexes?.contains(
              socketIndex,
            ) ??
            false));
  }

  bool isFavoritePlug(int plugHash) {
    return itemNotes.hasTag(plugHash, null, "favorite");
  }

  Future<void> setFavoritePlug(int plugHash, bool favorite) async {
    favorite ? itemNotes.addTag(plugHash, null, 'favorite') : itemNotes.removeTag(plugHash, null, 'favorite');
    notifyListeners();
  }

  List<DestinyObjectiveProgress>? getPlugObjectives(int plugHash);

  Set<WishlistTag>? getWishlistTagsForPlug(int plugHash) {
    final itemHash = this.itemHash;
    if (itemHash == null) return null;
    final tags = wishlists.getPlugTags(itemHash, plugHash);
    return tags;
  }

  void applyPlug(int socketIndex, int plugHash);

  void applySelectedPlug() {
    final socketIndex = selectedSocketIndex;
    final plugHash = selectedPlugHashForSocket(socketIndex);
    if (socketIndex == null || plugHash == null) return;
    applyPlug(socketIndex, plugHash);
  }

  void refresh() async {
    final itemHash = this.itemHash;
    if (itemHash == null) return;
    final totalSockets = itemDefinition?.sockets?.socketEntries?.length ?? 0;
    final socketList = List<int>.generate(totalSockets, (index) => index);
    final equippedPlugHashes = Map<int, int?>.fromIterable(
      socketList,
      key: (i) => i,
      value: (index) => equippedPlugHashForSocket(index),
    );

    final allEquippedPlugHashes = equippedPlugHashes.values.whereType<int>().toSet();

    final selectedPlugHashes = Map<int, int?>.fromIterable(
      socketList,
      key: (i) => i,
      value: (index) => selectedPlugHashForSocket(index),
    );

    final plugDefinitions = await manifest.getDefinitions<DestinyInventoryItemDefinition>({
      ...allEquippedPlugHashes,
      ...selectedPlugHashes.values,
    });

    final statGroupDefinition =
        await manifest.getDefinition<DestinyStatGroupDefinition>(itemDefinition?.stats?.statGroupHash);

    _allEquippedPlugHashes = allEquippedPlugHashes;
    _allSelectedPlugHashes = selectedPlugHashes.values.whereType<int>().toSet();

    _stats = calculateStats(
      equippedPlugHashes,
      selectedPlugHashes,
      itemDefinition,
      statGroupDefinition,
      plugDefinitions,
    );
    _selectedPlugStats = await _calculateSelectedPlugStats();
    _totalStats = await _calculateTotalStats();

    _usedEnergyCapacity = await _calculateUsedEnergyCapacity();
    _availableEnergyCapacity = await _calculateAvailableEnergyCapacity();

    _isAvailable = await _calculateIsAvailable();

    notifyListeners();
  }

  bool isSelectable(int socketIndex, int plugHash);

  bool isAvailable(int? socketIndex, int plugHash) => _isAvailable?[socketIndex]?[plugHash] ?? false;

  bool canApply(int socketIndex, int plugHash) => _canApply?[socketIndex]?[plugHash] ?? false;

  /// async calculations

  Future<List<StatComparison>?> _calculateSelectedPlugStats() async {
    final totalSockets = itemDefinition?.sockets?.socketEntries?.length ?? 0;
    final socketList = List<int>.generate(totalSockets, (index) => index);
    final selectedSocketIndex = this.selectedSocketIndex;
    if (selectedSocketIndex == null) return null;
    final equippedPlugHash = equippedPlugHashForSocket(selectedSocketIndex);
    final selectedPlugHash = selectedPlugHashForSocket(selectedSocketIndex);

    final selectedPlugHashes = Map<int, int?>.fromIterable(
      socketList,
      key: (i) => i,
      value: (index) {
        return selectedPlugHashForSocket(index);
      },
    );
    final plugDefinitions = await manifest.getDefinitions<DestinyInventoryItemDefinition>({
      ...selectedPlugHashes.values,
      equippedPlugHash,
      selectedPlugHash,
    });
    final statGroupDefinition =
        await manifest.getDefinition<DestinyStatGroupDefinition>(itemDefinition?.stats?.statGroupHash);
    return comparePlugStats(
      selectedPlugHashes,
      selectedSocketIndex,
      equippedPlugHash,
      selectedPlugHash,
      itemDefinition,
      statGroupDefinition,
      plugDefinitions,
    );
  }

  Future<StatValues?> _calculateTotalStats() async {
    final isArmor = itemDefinition?.isArmor ?? false;
    if (!isArmor) return null;
    final stats = this._stats;
    if (stats == null) return null;
    int equipped = 0;
    int equippedMasterWork = 0;
    int selected = 0;
    int selectedMasterwork = 0;
    for (final s in stats) {
      equipped += s.equipped;
      selected += s.equipped;
      equippedMasterWork += s.equippedMasterwork;
      selectedMasterwork += s.selectedMasterwork;
    }
    return StatValues(
      9999,
      rawEquipped: equipped,
      rawEquippedMasterwork: equippedMasterWork,
      rawSelected: selected,
      rawSelectedMasterwork: selectedMasterwork,
    );
  }

  Future<StatValues?> _calculateUsedEnergyCapacity() async {
    final totalSockets = itemDefinition?.sockets?.socketEntries?.length ?? 0;
    int totalEquipped = 0;
    int totalSelected = 0;
    for (int i = 0; i < totalSockets; i++) {
      final equippedPlug = equippedPlugHashForSocket(i);
      final selectedPlug = selectedPlugHashForSocket(i) ?? equippedPlug;
      final equippedDef = await manifest.getDefinition<DestinyInventoryItemDefinition>(equippedPlug);
      final selectedDef = await manifest.getDefinition<DestinyInventoryItemDefinition>(selectedPlug);
      final equippedValue = equippedDef?.plug?.energyCost?.energyCost ?? 0;
      final selectedValue = selectedDef?.plug?.energyCost?.energyCost ?? 0;
      totalEquipped += equippedValue;
      totalSelected += selectedValue;
    }
    return StatValues(9999, rawEquipped: totalEquipped, rawSelected: totalSelected);
  }

  Future<StatValues?> _calculateAvailableEnergyCapacity() async {
    final totalSockets = itemDefinition?.sockets?.socketEntries?.length ?? 0;
    int totalEquipped = 0;
    int totalSelected = 0;
    for (int i = 0; i < totalSockets; i++) {
      final equippedPlug = equippedPlugHashForSocket(i);
      final selectedPlug = selectedPlugHashForSocket(i) ?? equippedPlug;
      final equippedDef = await manifest.getDefinition<DestinyInventoryItemDefinition>(equippedPlug);
      final selectedDef = await manifest.getDefinition<DestinyInventoryItemDefinition>(selectedPlug);
      final equippedValue = equippedDef?.plug?.energyCapacity?.capacityValue ?? 0;
      final selectedValue = selectedDef?.plug?.energyCapacity?.capacityValue ?? 0;
      totalEquipped += equippedValue;
      totalSelected += selectedValue;
    }
    return StatValues(9999, rawEquipped: totalEquipped, rawSelected: totalSelected);
  }

  Future<Map<int, Map<int, bool>>?> _calculateIsAvailable() async {
    final socketCount = itemDefinition?.sockets?.socketEntries?.length;
    if (socketCount == null) return null;
    final result = <int, Map<int, bool>>{};
    for (int socketIndex = 0; socketIndex < socketCount; socketIndex++) {
      final plugHashes = availablePlugHashesForSocket(socketIndex);
      if (plugHashes == null) continue;
      final plugs = result[socketIndex] ??= {};
      for (final plugHash in plugHashes) {
        plugs[plugHash] = await calculateIsPlugAvailable(socketIndex, plugHash);
      }
    }
    return result;
  }

  Future<bool> calculateIsPlugAvailable(int socketIndex, int plugHash);

  @protected
  Future<Map<int, Map<int, bool>>?> loadCanApply() async {
    final socketCount = itemDefinition?.sockets?.socketEntries?.length;
    if (socketCount == null) return null;
    final result = <int, Map<int, bool>>{};
    for (int socketIndex = 0; socketIndex < socketCount; socketIndex++) {
      final plugHashes = availablePlugHashesForSocket(socketIndex);
      if (plugHashes == null) continue;
      final plugs = result[socketIndex] ??= {};
      for (final plugHash in plugHashes) {
        plugs[plugHash] = await loadCanApplyPlug(socketIndex, plugHash);
      }
    }
    return result;
  }

  @protected
  Future<bool> loadCanApplyPlug(int socketIndex, int plugHash);

  /// async load data

  @protected
  Future<List<int>?> loadAvailablePlugHashesForSocket(int socketIndex);

  @protected
  Future<List<int>?> loadRandomPlugHashesForSocket(int selectedIndex);

  @protected
  Future<void> loadAdditionalDefinitions() async => null;
}
