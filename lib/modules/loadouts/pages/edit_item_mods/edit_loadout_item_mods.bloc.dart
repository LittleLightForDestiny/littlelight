import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/loadouts/pages/edit_item_mods/edit_loadout_item_mods.page_route.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/shared/blocs/socket_controller/base_socket_controller.bloc.dart';
import 'package:provider/provider.dart';

class EditLoadoutItemModsBloc extends BaseSocketController with ManifestConsumer, ProfileConsumer {
  final BuildContext context;

  DestinyItemComponent? item;
  DestinyInventoryItemDefinition? definition;
  List<DestinyItemSocketState>? socketStates;
  Map<String, List<DestinyItemPlugBase>>? reusablePlugs;

  Map<int, List<int>> _availablePlugHashesForSocketIndexes = {};
  Set<int> _availableSocketIndexes = {};
  Set<int> _availableCategoryHashes = {};
  Map<int, int> _selectedPlugs = {};

  int? _selectedSocket;

  bool hasChanges = false;

  int? get emblemHash => _emblemHash;
  int? _emblemHash;

  EditLoadoutItemModsBloc(this.context) {
    _asyncInit();
  }

  _asyncInit() async {
    final args = context.read<EditLoadoutItemModsPageArguments>();

    final itemInstanceID = args.itemInstanceID;
    final emblemHash = args.emblemHash;
    final plugHashes = args.plugHashes;

    this._emblemHash = emblemHash;

    this.item = profile.getItemsByInstanceId([itemInstanceID]).first;
    this.socketStates = profile.getItemSockets(itemInstanceID);
    this.reusablePlugs = profile.getItemReusablePlugs(itemInstanceID);

    if (plugHashes != null) {
      this._selectedPlugs = Map.from(plugHashes);
    }

    final itemHash = item?.itemHash;
    definition = await manifest.getDefinition<DestinyInventoryItemDefinition>(itemHash);

    await loadDefinitions();
    await computeAvailableCategories();
    notifyListeners();
  }

  Future<void> computeAvailableCategories() async {
    final categories = definition?.sockets?.socketCategories;
    final socketCount = definition?.sockets?.socketEntries?.length ?? 0;
    final itemSockets = this.socketStates;
    if (categories == null || itemSockets == null) return;

    Map<int, List<int>> availablePlughashesForIndexes = {};
    Set<int> availableSocketIndexes = {};
    Set<int> availableCategoryHashes = {};

    for (var index = 0; index < socketCount; index++) {
      final plugHashes = socketPlugHashes(index)?.where((p) => canApplyForFree(index, p)).toList();
      if (plugHashes != null && plugHashes.length > 1) {
        availablePlughashesForIndexes[index] = plugHashes;
        availableSocketIndexes.add(index);
      }
    }
    for (final cat in categories) {
      final containsValidSockets =
          cat.socketIndexes?.any((element) => availableSocketIndexes.contains(element)) ?? false;
      final categoryHash = cat.socketCategoryHash;
      if (containsValidSockets && categoryHash != null) {
        availableCategoryHashes.add(categoryHash);
      }
    }
    this._availableCategoryHashes = availableCategoryHashes;
    this._availablePlugHashesForSocketIndexes = availablePlughashesForIndexes;
    this._availableSocketIndexes = availableSocketIndexes;
    notifyListeners();
  }

  List<DestinyItemSocketCategoryDefinition>? get categories => definition?.sockets?.socketCategories
      ?.where((element) => _availableCategoryHashes.contains(element.socketCategoryHash))
      .toList();

  int? selectedSelectedPlugHash(int index) => _selectedPlugs[index];

  List<int>? availableIndexesForCategory(DestinyItemSocketCategoryDefinition category) {
    return category.socketIndexes?.where((element) => _availableSocketIndexes.contains(element)).toList();
  }

  void selectSocket(int socketIndex) {
    _selectedSocket = socketIndex;
    notifyListeners();
  }

  void unselectSockets() {
    _selectedSocket = null;
    notifyListeners();
  }

  void selectPlugHashForSocket(int plugHash, int socketIndex) {
    _selectedPlugs[socketIndex] = plugHash;
    hasChanges = true;
    notifyListeners();
  }

  void removePlugHashForSocket(int socketIndex) {
    _selectedPlugs.remove(socketIndex);
    hasChanges = true;
    notifyListeners();
  }

  bool isSocketSelected(int socketIndex) => _selectedSocket == socketIndex;

  bool isPlugSelectedForSocket(int? plugHash, int socketIndex) => _selectedPlugs[socketIndex] == plugHash;
  bool isPlugEquippedForSocket(int? plugHash, int socketIndex) => socketEquippedPlugHash(socketIndex) == plugHash;

  List<int?>? selectedSocketPlugs() {
    final selectedSocket = _selectedSocket;
    if (selectedSocket == null) return null;
    List<int?>? plugs = _availablePlugHashesForSocketIndexes[selectedSocket];
    if (plugs == null) return null;
    final equipped = socketEquippedPlugHash(selectedSocket);
    plugs = plugs.where((p) => p != equipped).toList();
    plugs = [null, equipped] + plugs;
    return plugs;
  }

  int? get selectedSocketSelectedPlugHash {
    final socket = _selectedSocket;
    if (socket == null) return null;
    return selectedSelectedPlugHash(socket);
  }

  int? get selectedSocketDefaultPlugHash {
    final socket = _selectedSocket;
    if (socket == null) return null;
    final defaultPlugHash = definition?.sockets?.socketEntries?[socket].singleInitialItemHash;
    if (defaultPlugHash != null && defaultPlugHash != 0) return defaultPlugHash;
    return selectedSelectedPlugHash(socket);
  }

  int? get selectedSocket => _selectedSocket;

  bool isCategorySelected(DestinyItemSocketCategoryDefinition category) =>
      category.socketIndexes?.contains(_selectedSocket) ?? false;

  void updateMods() {
    Navigator.of(context).pop(this._selectedPlugs);
  }
}
