import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/littlelight/item_notes.consumer.dart';
import 'package:little_light/services/littlelight/item_notes.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
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
  final ItemNotesService itemNotes;

  @protected
  DestinyInventoryItemDefinition? itemDefinition;

  @protected
  Map<int, DestinySocketCategoryDefinition>? categoryDefinitions;

  @protected
  Map<int, DestinyPlugSetDefinition>? plugSetDefinitions;

  SocketControllerBloc(this.context)
      : manifest = context.read<ManifestService>(),
        itemNotes = getInjecteditemNotes(),
        super();

  int? get itemHash => itemDefinition?.hash;

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

    final plugSetHashes = itemDefinition?.sockets?.socketEntries
        ?.map((e) => [e.reusablePlugSetHash, e.randomizedPlugSetHash])
        .flattened
        .whereType<int>();
    if (plugSetHashes != null) {
      final plugSetDefinitions = await manifest.getDefinitions<DestinyPlugSetDefinition>(plugSetHashes);
      this.plugSetDefinitions = plugSetDefinitions;
    }

    refreshStats();
  }

  refreshStats() {
    final itemHash = this.itemHash;
    if (itemHash == null) return;
    final totalSockets = itemDefinition?.sockets?.socketEntries?.length ?? 0;
    final socketList = List<int>.generate(totalSockets, (index) => index);
    final equippedPlugHashes = Map<int, int?>.fromIterable(
      socketList,
      key: (i) => i,
      value: (index) => getEquippedPlugHashesForSocket(index),
    );
    final selectedPlugHashes = Map<int, int?>.fromIterable(
      socketList,
      key: (i) => i,
      value: (index) => getSelectedPlugHashesForSocket(index),
    );

    calculateStats(
      context,
      itemHash,
      equippedPlugHashes,
      selectedPlugHashes,
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

  void toggleSelection(int socketIndex, int plugHash) {
    final isCurrentlySelected = isSelected(socketIndex, plugHash);
    final isSameSocketIndex = _selectedSocketIndex == socketIndex;
    if (isCurrentlySelected && isSameSocketIndex) {
      _selectedPlugHashes.remove(socketIndex);
      _selectedSocketIndex = null;
      notifyListeners();
      return;
    }

    _selectedPlugHashes[socketIndex] = plugHash;
    _selectedSocketIndex = socketIndex;
    notifyListeners();
    return;
  }

  Future<void> init(T object);
  Future<void> update(T object);

  @protected
  List<int>? getAvailablePlugHashesForSocket(int socketIndex);

  @protected
  int? getEquippedPlugHashesForSocket(int socketIndex);

  @protected
  int? getSelectedPlugHashesForSocket(int socketIndex) => _selectedPlugHashes[socketIndex];

  int? selectedPlugForCategory(DestinyItemSocketCategoryDefinition category) {
    final categoryIsSelected = category.socketIndexes?.contains(_selectedSocketIndex) ?? false;
    if (!categoryIsSelected) return null;
    return _selectedPlugHashes[_selectedSocketIndex];
  }

  bool canFavorite(DestinyItemSocketCategoryDefinition category) {
    return _cosmeticsCategories.contains(category.socketCategoryHash);
  }

  bool isFavoritePlug(int plugHash) {
    return itemNotes.getNotesForItem(plugHash, null)?.tags?.contains("favorite") ?? false;
  }

  Future<void> setFavoritePlug(int plugHash, bool favorite) async {
    final notes = itemNotes.getNotesForItem(plugHash, null, true);
    favorite ? notes?.tags?.add("favorite") : notes?.tags?.remove("favorite");
    if (notes == null) return;
    itemNotes.saveNotes(notes);
    notifyListeners();
  }
}
