import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/loadouts/pages/edit_item_mods/edit_loadout_item_mods.page_route.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
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
  Map<int, int> selectedPlugs = {};

  EditLoadoutItemModsBloc(this.context) {
    _asyncInit();
  }

  _asyncInit() async {
    final itemInstanceID = context.read<EditLoadoutItemModsPageArguments>().itemInstanceID;

    this.item = profile.getItemsByInstanceId([itemInstanceID]).first;
    this.socketStates = profile.getItemSockets(itemInstanceID);
    this.reusablePlugs = profile.getItemReusablePlugs(itemInstanceID);

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

  int? equippedPlugHashForSocket(int index) => this.socketStates![index].plugHash;

  List<int>? availableIndexesForCategory(DestinyItemSocketCategoryDefinition category) {
    return category.socketIndexes?.where((element) => _availableSocketIndexes.contains(element)).toList();
  }

  List<int>? availablePlugHashesForSocket(int index) => _availablePlugHashesForSocketIndexes[index];
}
