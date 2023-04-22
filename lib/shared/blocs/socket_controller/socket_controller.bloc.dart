
import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/shared/utils/extensions/inventory_item_data.dart';
import 'package:little_light/shared/utils/helpers/plug_helpers.dart';
import 'package:little_light/shared/utils/helpers/stat_helpers.dart';
import 'package:provider/provider.dart';

const _cosmeticsCategories = [
  1926152773, //armor cosmetics
  2048875504, //weapon cosmetics
  2549160099, //ghost cosmetics
];

class PlugSocket {
  final int index;
  final List<int> availablePlugHashes;

  PlugSocket(this.index, this.availablePlugHashes);
}

abstract class SocketControllerBloc<T> extends ChangeNotifier {
  Map<int, int?> _selectedPlugHashes = {};
  int? _selectedSocketIndex;

  @protected
  final BuildContext context;

  @protected
  final ManifestService manifest;

  @protected
  final WishlistsService wishlists;

  @protected
  final ItemNotesBloc itemNotes;

  @protected
  DestinyInventoryItemDefinition? itemDefinition;

  @protected
  Map<int, DestinySocketCategoryDefinition>? categoryDefinitions;

  List<StatValues>? _stats;

  @protected
  DestinyStatGroupDefinition? statGroupDefinition;

  Map<int, DestinyInventoryItemDefinition>? plugDefinitions;

  @protected
  Map<int, DestinyMaterialRequirementSetDefinition>? materialRequirementDefinitions;

  List<StatValues>? get stats => _stats;

  StatValues? get totalStats {
    final isArmor = itemDefinition?.isArmor ?? false;
    if (!isArmor) return null;
    final stats = this._stats;
    if (stats == null) return null;
    int equipped = 0;
    int equippedMasterWork = 0;
    int selected = 0;
    int selectedMasterwork = 0;
    for (final s in stats) {
      if (s.isHiddenStat) continue;
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

  StatValues? get usedEnergyCapacity {
    final totalSockets = itemDefinition?.sockets?.socketEntries?.length ?? 0;
    int totalEquipped = 0;
    int totalSelected = 0;
    for (int i = 0; i < totalSockets; i++) {
      final equippedPlug = getEquippedPlugHashForSocket(i);
      final selectedPlug = getSelectedPlugHashForSocket(i);
      final equippedDef = plugDefinitions?[equippedPlug];
      final selectedDef = plugDefinitions?[selectedPlug] ?? equippedDef;
      final equippedValue = equippedDef?.plug?.energyCost?.energyCost ?? 0;
      final selectedValue = selectedDef?.plug?.energyCost?.energyCost ?? 0;
      totalEquipped += equippedValue;
      totalSelected += selectedValue;
    }
    return StatValues(9999, rawEquipped: totalEquipped, rawSelected: totalSelected);
  }

  StatValues? get availableEnergyCapacity {
    final totalSockets = itemDefinition?.sockets?.socketEntries?.length ?? 0;
    int totalEquipped = 0;
    int totalSelected = 0;
    for (int i = 0; i < totalSockets; i++) {
      final equippedPlug = getEquippedPlugHashForSocket(i);
      final selectedPlug = getSelectedPlugHashForSocket(i);
      final equippedDef = plugDefinitions?[equippedPlug];
      final selectedDef = plugDefinitions?[selectedPlug] ?? equippedDef;
      final equippedValue = equippedDef?.plug?.energyCapacity?.capacityValue ?? 0;
      final selectedValue = selectedDef?.plug?.energyCapacity?.capacityValue ?? 0;
      totalEquipped += equippedValue;
      totalSelected += selectedValue;
    }
    return StatValues(9999, rawEquipped: totalEquipped, rawSelected: totalSelected);
  }

  SocketControllerBloc(this.context)
      : manifest = context.read<ManifestService>(),
        wishlists = getInjectedWishlistsService(),
        itemNotes = context.read<ItemNotesBloc>(),
        super();

  int? get itemHash => itemDefinition?.hash;

  bool get isBusy;

  List<DestinyItemSocketCategoryDefinition>? getSocketCategories(DestinySocketCategoryStyle? category) {
    final categories = itemDefinition?.sockets?.socketCategories?.where((socketCategory) {
      return socketsForCategory(socketCategory)?.isNotEmpty ?? false;
    }).toList();
    if (categories == null) return null;
    final categoryDefs = categoryDefinitions;
    if (categoryDefs == null) return null;
    categories.sort((a, b) {
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
    final statGroupDefinition =
        await manifest.getDefinition<DestinyStatGroupDefinition>(itemDefinition?.stats?.statGroupHash);
    this.statGroupDefinition = statGroupDefinition;
    final plugHashes = await getPossiblePlugHashesForItem(context, itemHash);
    final totalSockets = itemDefinition?.sockets?.socketEntries?.length ?? 0;
    for (int i = 0; i < totalSockets; i++) {
      final equipped = getEquippedPlugHashForSocket(i);
      final available = getAvailablePlugHashesForSocket(i);
      if (equipped != null) plugHashes.add(equipped);
      if (available != null) plugHashes.addAll(available);
    }
    final plugDefinitions = await manifest.getDefinitions<DestinyInventoryItemDefinition>(plugHashes);
    this.plugDefinitions = plugDefinitions;
    final materialRequirementHashes =
        plugDefinitions.values.map((def) => def.plug?.insertionMaterialRequirementHash).whereType<int>();
    final materialRequirementDefinitions =
        await manifest.getDefinitions<DestinyMaterialRequirementSetDefinition>(materialRequirementHashes);
    this.materialRequirementDefinitions = materialRequirementDefinitions;
    refreshStats();
  }

  void refreshStats() {
    final itemHash = this.itemHash;
    if (itemHash == null) return;
    final totalSockets = itemDefinition?.sockets?.socketEntries?.length ?? 0;
    final socketList = List<int>.generate(totalSockets, (index) => index);
    final equippedPlugHashes = Map<int, int?>.fromIterable(
      socketList,
      key: (i) => i,
      value: (index) => getEquippedPlugHashForSocket(index),
    );
    final selectedPlugHashes = Map<int, int?>.fromIterable(
      socketList,
      key: (i) => i,
      value: (index) => getSelectedPlugHashForSocket(index),
    );

    _stats = calculateStats(
      equippedPlugHashes,
      selectedPlugHashes,
      itemDefinition,
      statGroupDefinition,
      plugDefinitions,
    );
    notifyListeners();
  }

  List<StatComparison>? getSelectedPlugStats() {
    final totalSockets = itemDefinition?.sockets?.socketEntries?.length ?? 0;
    final socketList = List<int>.generate(totalSockets, (index) => index);
    final selectedSocketIndex = this.selectedSocketIndex;
    if (selectedSocketIndex == null) return null;
    final equippedPlugHash = getEquippedPlugHashForSocket(selectedSocketIndex);
    final selectedPlugHash = getSelectedPlugHashForSocket(selectedSocketIndex);

    final selectedPlugHashes = Map<int, int?>.fromIterable(
      socketList,
      key: (i) => i,
      value: (index) {
        return getSelectedPlugHashForSocket(index);
      },
    );
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

  List<PlugSocket>? socketsForCategory(DestinyItemSocketCategoryDefinition category) {
    final sockets = category.socketIndexes
        ?.map((socketIndex) {
          final hashes = getAvailablePlugHashesForSocket(socketIndex);
          if (hashes == null) return null;
          return PlugSocket(socketIndex, hashes);
        })
        .whereType<PlugSocket>()
        .toList();
    return sockets;
  }

  bool isEquipped(int socketIndex, int plugHash);

  bool isSelected(int socketIndex, int plugHash) {
    return _selectedPlugHashes[socketIndex] == plugHash;
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
      _selectedPlugHashes.remove(socketIndex);
      _selectedSocketIndex = null;
      refreshStats();
      notifyListeners();
      return;
    }

    _selectedPlugHashes[socketIndex] = plugHash;
    _selectedSocketIndex = socketIndex;
    refreshStats();
    notifyListeners();
    return;
  }

  Future<void> init(T object);
  Future<void> update(T object);

  List<int>? getAvailablePlugHashesForSocket(int socketIndex);

  int? getEquippedPlugHashForSocket(int? socketIndex);
  int? getSelectedPlugHashForSocket(int? socketIndex) => _selectedPlugHashes[socketIndex];

  int? selectedPlugForCategory(DestinyItemSocketCategoryDefinition category) {
    final categoryIsSelected = category.socketIndexes?.contains(_selectedSocketIndex) ?? false;
    if (!categoryIsSelected) return null;
    return _selectedPlugHashes[_selectedSocketIndex];
  }

  bool canFavorite(DestinyItemSocketCategoryDefinition category) {
    return _cosmeticsCategories.contains(category.socketCategoryHash);
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

  bool canApplySelectedPlug();

  void applyPlug(int socketIndex, int plugHash);

  void applySelectedPlug() {
    final socketIndex = selectedSocketIndex;
    final plugHash = getSelectedPlugHashForSocket(socketIndex);
    if (socketIndex == null || plugHash == null) return;
    applyPlug(socketIndex, plugHash);
  }
}
