import 'package:collection/collection.dart';
import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/littlelight/item_notes.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/utils/destiny_data.dart';

abstract class BaseSocketController extends ChangeNotifier
    with ManifestConsumer, ItemNotesConsumer, ProfileConsumer {
  DestinyInventoryItemDefinition? get definition;
  List<DestinyItemSocketState>? get socketStates;
  Map<String, List<DestinyItemPlugBase>>? get reusablePlugs;

  Map<int, DestinyPlugSetDefinition>? _plugSetDefinitions;
  Map<int, DestinyInventoryItemDefinition>? _plugDefinitions;
  Map<int, DestinyMaterialRequirementSetDefinition>?
      _materialRequirementSetDefinitions;

  int? _armorTierIndex;

  Future<void> loadDefinitions() async {
    final itemDefinition = definition;
    if (itemDefinition == null) return;
    final plugHashes = <int>{};
    if (reusablePlugs != null) {
      plugHashes.addAll(socketStates
              ?.expand((socket) {
                Set<int?> hashes = {};
                hashes.add(socket.plugHash);
                return hashes.whereType<int>();
              })
              .where((i) => i != 0)
              .toSet() ??
          <int>{});
      reusablePlugs?.forEach((hash, reusable) {
        plugHashes.addAll(reusable.map((r) => r.plugItemHash).whereType<int>());
      });
    }
    final plugSetHashes = itemDefinition.sockets?.socketEntries
        ?.expand((s) => [s.reusablePlugSetHash, s.randomizedPlugSetHash])
        .whereType<int>()
        .where((h) => h != 0)
        .toSet();
    if (plugSetHashes == null) return;
    _plugSetDefinitions =
        await manifest.getDefinitions<DestinyPlugSetDefinition>(plugSetHashes);

    List<int?> socketTypeHashes = [];
    final definitionPlugHashes = itemDefinition.sockets?.socketEntries
        ?.expand((socket) {
          socketTypeHashes.add(socket.socketTypeHash);
          List<int?> hashes = [];
          hashes.add(socket.singleInitialItemHash);
          hashes.addAll(
              socket.reusablePlugItems?.map((p) => p.plugItemHash) ?? []);
          DestinyPlugSetDefinition? reusablePlugSet =
              _plugSetDefinitions?[socket.reusablePlugSetHash];
          DestinyPlugSetDefinition? randomizedPlugSet =
              _plugSetDefinitions?[socket.randomizedPlugSetHash];
          hashes.addAll(
              reusablePlugSet?.reusablePlugItems?.map((i) => i.plugItemHash) ??
                  []);
          hashes.addAll(randomizedPlugSet?.reusablePlugItems
                  ?.map((i) => i.plugItemHash) ??
              []);
          return hashes;
        })
        .whereType<int>()
        .where((i) => i != 0)
        .toSet();

    plugHashes.addAll(definitionPlugHashes ?? <int>{});
    _plugDefinitions = await manifest
        .getDefinitions<DestinyInventoryItemDefinition>(plugHashes);
    DestinyItemSocketCategoryDefinition? armorTierCategory = itemDefinition
        .sockets?.socketCategories
        ?.firstWhereOrNull((s) => DestinyData.socketCategoryTierHashes
            .contains(s.socketCategoryHash));
    _armorTierIndex = armorTierCategory?.socketIndexes?.first;

    final materialRequirementHashes = _plugDefinitions?.values
        .map((p) => p.plug?.insertionMaterialRequirementHash)
        .whereType<int>()
        .toSet();

    if (materialRequirementHashes != null) {
      _materialRequirementSetDefinitions = await manifest.getDefinitions<
          DestinyMaterialRequirementSetDefinition>(materialRequirementHashes);
    }

    notifyListeners();
  }

  DestinyEnergyCapacityEntry? get armorEnergyCapacity {
    if (_armorTierIndex == null) return null;
    if (_plugDefinitions == null) return null;
    var plugHash = socketEquippedPlugHash(_armorTierIndex!);
    var def = _plugDefinitions![plugHash];
    return def?.plug?.energyCapacity;
  }

  DestinyEnergyType? get armorEnergyType {
    return armorEnergyCapacity?.energyType;
  }

  List<int>? socketPlugHashes(int socketIndex) {
    final plugHashes = _socketPlugHashes(socketIndex);
    bool favoritable = isSocketFavoritable(socketIndex);
    if (!favoritable) return plugHashes;
    final plugs = plugHashes?.toList();
    plugs?.sort((a, b) {
      final favoriteA =
          itemNotes.getNotesForItem(a, null)?.tags?.contains("favorite") ??
              false;
      final favoriteB =
          itemNotes.getNotesForItem(b, null)?.tags?.contains("favorite") ??
              false;
      final valueA = favoriteA ? 1 : 0;
      final valueB = favoriteB ? 1 : 0;
      final favoriteOrder = valueB.compareTo(valueA);
      if (favoriteOrder != 0) return favoriteOrder;
      final orderA = plugHashes?.indexOf(a) ?? -1;
      final orderB = plugHashes?.indexOf(b) ?? -1;
      return orderB.compareTo(orderA);
    });
    return plugs;
  }

  List<int>? _socketPlugHashes(int socketIndex) {
    final entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);

    if (socketStates != null) {
      return _plugHashesFromSocketState(socketIndex);
    }

    if (!(entry?.defaultVisible ?? false)) {
      return null;
    }

    if (_plugSetDefinitions?.containsKey(entry?.reusablePlugSetHash) ?? false) {
      return _plugHashesFromPlugSetsDefinitions(socketIndex);
    }

    if ((entry?.reusablePlugItems?.length ?? 0) > 0) {
      return entry?.reusablePlugItems
          ?.map((p) => p.plugItemHash)
          .whereType<int>()
          .where((h) => h != 0)
          .toList();
    }

    if ((entry?.singleInitialItemHash ?? 0) != 0) {
      return [entry?.singleInitialItemHash].whereType<int>().toList();
    }

    return <int>[];
  }

  bool isSocketFavoritable(int socketIndex) {
    final categories = definition?.sockets?.socketCategories
        ?.where(
            (element) => element.socketIndexes?.contains(socketIndex) ?? false)
        .map((s) => s.socketCategoryHash)
        .toSet();

    final cosmeticsCategories = [
      1926152773, //armor cosmetics
      2048875504, //weapon cosmetics
      2549160099, //ghost cosmetics
    ];

    return categories?.any(cosmeticsCategories.contains) ?? false;
  }

  List<int>? _plugHashesFromSocketState(int socketIndex) {
    final entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);
    final state = socketStates?.elementAt(socketIndex);
    if (state?.isVisible == false) return null;
    if (state?.plugHash == null) return null;
    final hashes = <int>[];
    final plugSources = entry?.plugSources;

    final isPlugSet =
        (plugSources?.contains(SocketPlugSources.CharacterPlugSet) ?? false) ||
            (plugSources?.contains(SocketPlugSources.ProfilePlugSet) ?? false);
    final plugSetHash = entry?.reusablePlugSetHash;
    if (isPlugSet && plugSetHash != null) {
      var plugSet = profile.getPlugSets(plugSetHash);
      hashes.addAll(plugSet
          .where((p) => p.canInsert ?? false)
          .map((p) => p.plugItemHash)
          .where((p) {
        if (_armorTierIndex == null) return true;
        var def = _plugDefinitions?[p];
        var energyType =
            def?.plug?.energyCost?.energyType ?? DestinyEnergyType.Any;
        return (energyType == armorEnergyType ||
            energyType == DestinyEnergyType.Any);
      }).whereType<int>());
    }

    if (reusablePlugs?.containsKey("$socketIndex") ?? false) {
      final reusableHashes = reusablePlugs?["$socketIndex"]
          ?.map((r) => r.plugItemHash)
          .where((element) => !hashes.contains(element))
          .whereType<int>();
      hashes.addAll(reusableHashes ?? []);
    }
    final plugHash = state?.plugHash;
    if (plugHash != null && !hashes.contains(plugHash)) hashes.add(plugHash);
    return hashes.whereType<int>().toList();
  }

  List<int>? _plugHashesFromPlugSetsDefinitions(int socketIndex) {
    final entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);
    return _plugSetDefinitions?[entry?.reusablePlugSetHash]
        ?.reusablePlugItems
        ?.map((p) => p.plugItemHash)
        .where((p) {
          if (_armorTierIndex == null) return true;
          var def = _plugDefinitions?[p];
          var energyType =
              def?.plug?.energyCost?.energyType ?? DestinyEnergyType.Any;
          return (energyType == armorEnergyType ||
              energyType == DestinyEnergyType.Any);
        })
        .whereType<int>()
        .toList();
  }

  int? socketEquippedPlugHash(int socketIndex) {
    if (socketStates != null) {
      var state = socketStates?.elementAt(socketIndex);
      return state?.plugHash;
    }
    final entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);
    if ((entry?.singleInitialItemHash ?? 0) != 0) {
      return entry?.singleInitialItemHash;
    }
    final socketPlugs = socketPlugHashes(socketIndex);
    if ((socketPlugs?.length ?? 0) > 0) {
      return socketPlugs?.first;
    }
    final random = randomizedPlugHashes(socketIndex);
    if ((random?.length ?? 0) > 0) {
      return random?.first;
    }
    return null;
  }

  List<int>? randomizedPlugHashes(int socketIndex) {
    var entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);
    if ((entry?.randomizedPlugSetHash ?? 0) == 0) return <int>[];
    if (!(_plugSetDefinitions?.containsKey(entry?.randomizedPlugSetHash) ??
        false)) return <int>[];
    final hashes = _plugSetDefinitions?[entry?.randomizedPlugSetHash]
        ?.reusablePlugItems
        ?.map((p) => p.plugItemHash)
        .whereType<int>()
        .toList();
    return hashes;
  }

  bool canApplyPlug(int socketIndex, int plugHash) {
    final state = socketStates?[socketIndex];
    final isVisible = state?.isVisible ??
        definition?.sockets?.socketEntries?[socketIndex].defaultVisible ??
        false;
    if (!isVisible) {
      return false;
    }
    return _plugDefinitions?[plugHash]?.allowActions ?? false;
  }

  bool canApplyForFree(int socketIndex, int plugHash) {
    final canApply = canApplyPlug(socketIndex, plugHash);
    if (!canApply) return false;
    final materialRequirementHash =
        _plugDefinitions?[plugHash]?.plug?.insertionMaterialRequirementHash;
    if (materialRequirementHash == null || materialRequirementHash == 0) {
      return true;
    }
    final materials =
        _materialRequirementSetDefinitions?[materialRequirementHash]?.materials;
    if (materials == null) return true;
    for (var m in materials) {
      final count = m.count ?? 0;
      if (count > 0) return false;
    }
    return true;
  }
}
