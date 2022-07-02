import 'package:flutter/material.dart';

abstract class BaseSocketController extends ChangeNotifier {
  // DestinyInventoryItemDefinition? get definition;
  // List<DestinyItemSocketState>? get socketStates;
  // Map<String, List<DestinyItemPlugBase>>? get reusablePlugs;
  // List<int?>? get _selectedSockets;
  // List<int?>? get _randomizedSelectedSockets;
  // Map<int, DestinyInventoryItemDefinition>? get _plugDefinitions;
  // Map<int, DestinyPlugSetDefinition>? get _plugSetDefinitions;

  // Map<int, DestinyInventoryItemDefinition>? get plugDefinitions => _plugDefinitions;

  // int? _selectedSocket;
  // int? _selectedSocketIndex;
  // int? get selectedSocketIndex => _selectedSocketIndex;
  // int? get selectedPlugHash => _selectedSocket;
  // int? _armorTierIndex;

  // DestinyEnergyCapacityEntry? get armorEnergyCapacity {
  //   if (_armorTierIndex == null) return null;
  //   if (_plugDefinitions == null) return null;
  //   var plugHash = socketEquippedPlugHash(_armorTierIndex!);
  //   var def = _plugDefinitions![plugHash];
  //   return def?.plug?.energyCapacity;
  // }

  // DestinyEnergyType? get armorEnergyType {
  //   return armorEnergyCapacity?.energyType;
  // }

  // int get usedEnergy {
  //   var energy = 0;
  //   for (var i = 0; i < socketCount; i++) {
  //     var plugHash = socketSelectedPlugHash(i);
  //     var def = plugDefinitions?[plugHash];
  //     energy += def?.plug?.energyCost?.energyCost ?? 0;
  //   }
  //   return energy;
  // }

  // int get usedEnergyWithoutFailedSocket {
  //   var energy = 0;
  //   for (var i = 0; i < socketCount; i++) {
  //     var plugHash = socketSelectedPlugHash(i);
  //     var def = plugDefinitions?[plugHash];
  //     if (selectedSocketIndex != i || selectedPlugHash == plugHash) {
  //       energy += def?.plug?.energyCost?.energyCost ?? 0;
  //     }
  //   }
  //   return energy;
  // }

  // int get requiredEnergy {
  //   if (_selectedSocketIndex == null) return 0;
  //   final socketSelectedHash = socketSelectedPlugHash(_selectedSocketIndex!);
  //   final used = usedEnergy;
  //   if (socketSelectedHash == selectedPlugHash) return used;
  //   final def = plugDefinitions?[selectedPlugHash];
  //   final currentDef = plugDefinitions?[socketSelectedHash];
  //   var selectedEnergy = def?.plug?.energyCost?.energyCost ?? 0;
  //   var currentEnergy = currentDef?.plug?.energyCost?.energyCost ?? 0;
  //   var energy = used - currentEnergy + selectedEnergy;
  //   return energy;
  // }

  // int get socketCount => definition?.sockets?.socketEntries?.length ?? 0;

  // List<int?>? get selectedSockets => _selectedSockets;
  // List<int?>? get randomizedSelectedSockets => _randomizedSelectedSockets;

  // void selectSocket(int socketIndex, int plugHash) {
  //   if (plugHash == this._selectedSocket && socketIndex == _selectedSocketIndex) {
  //     this._selectedSocket = null;
  //     this._selectedSocketIndex = null;
  //   } else {
  //     this._selectedSocketIndex = socketIndex;
  //     this._selectedSocket = plugHash;
  //     var can = canEquip(socketIndex, plugHash);
  //     if (can) {
  //       this._selectedSockets?[socketIndex] = plugHash;
  //       final plugHashes = socketPlugHashes(socketIndex);
  //       final containsPlug = plugHashes?.contains(plugHash) ?? false;
  //       if (!containsPlug) {
  //         this._randomizedSelectedSockets?[socketIndex] = plugHash;
  //       }
  //     }
  //   }
  //   this.notifyListeners();
  // }

  // bool canApplySocket(int socketIndex, int plugHash) {
  //   return _plugDefinitions?[plugHash]?.allowActions ?? false;
  // }

  // List<int>? _plugHashesFromSocketState(int socketIndex) {
  //   final entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);
  //   final state = socketStates?.elementAt(socketIndex);
  //   if (state?.isVisible == false) return null;
  //   if (state?.plugHash == null) return null;
  //   final hashes = <int>[];
  //   final plugSources = entry?.plugSources;

  //   final isPlugSet = (plugSources?.contains(SocketPlugSources.CharacterPlugSet) ?? false) ||
  //       (plugSources?.contains(SocketPlugSources.ProfilePlugSet) ?? false);
  //   final plugSetHash = entry?.reusablePlugSetHash;
  //   if (isPlugSet && plugSetHash != null) {
  //     var plugSet = profile.getPlugSets(plugSetHash);
  //     hashes.addAll(plugSet.where((p) => p.canInsert ?? false).map((p) => p.plugItemHash).where((p) {
  //       if (_armorTierIndex == null) return true;
  //       var def = _plugDefinitions?[p];
  //       var energyType = def?.plug?.energyCost?.energyType ?? DestinyEnergyType.Any;
  //       return (energyType == armorEnergyType || energyType == DestinyEnergyType.Any);
  //     }).whereType<int>());
  //   }

  //   if (reusablePlugs?.containsKey("$socketIndex") ?? false) {
  //     final reusableHashes = reusablePlugs?["$socketIndex"]
  //         ?.map((r) => r.plugItemHash)
  //         .where((element) => !hashes.contains(element))
  //         .whereType<int>();
  //     hashes.addAll(reusableHashes ?? []);
  //   }
  //   final plugHash = state?.plugHash;
  //   if (plugHash != null && !hashes.contains(plugHash)) hashes.add(plugHash);
  //   return hashes.whereType<int>().toList();
  // }

  // List<int>? _plugHashesFromPlugSetsDefinitions(int socketIndex) {
  //   final entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);
  //   return _plugSetDefinitions?[entry?.reusablePlugSetHash]
  //       ?.reusablePlugItems
  //       ?.map((p) => p.plugItemHash)
  //       .where((p) {
  //         if (_armorTierIndex == null) return true;
  //         var def = _plugDefinitions?[p];
  //         var energyType = def?.plug?.energyCost?.energyType ?? DestinyEnergyType.Any;
  //         return (energyType == armorEnergyType || energyType == DestinyEnergyType.Any);
  //       })
  //       .whereType<int>()
  //       .toList();
  // }

  // List<int>? _socketPlugHashes(int socketIndex) {
  //   final entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);

  //   if (socketStates != null) {
  //     return _plugHashesFromSocketState(socketIndex);
  //   }

  //   if (!(entry?.defaultVisible ?? false)) {
  //     return null;
  //   }

  //   if (_plugSetDefinitions?.containsKey(entry?.reusablePlugSetHash) ?? false) {
  //     return _plugHashesFromPlugSetsDefinitions(socketIndex);
  //   }

  //   if ((entry?.reusablePlugItems?.length ?? 0) > 0) {
  //     return entry?.reusablePlugItems?.map((p) => p.plugItemHash).whereType<int>().where((h) => h != 0).toList();
  //   }

  //   if ((entry?.singleInitialItemHash ?? 0) != 0) {
  //     return [entry?.singleInitialItemHash].whereType<int>().toList();
  //   }

  //   return <int>[];
  // }

  // bool isSocketFavoritable(int socketIndex) {
  //   final categories = definition?.sockets?.socketCategories
  //       ?.where((element) => element.socketIndexes?.contains(socketIndex) ?? false)
  //       .map((s) => s.socketCategoryHash)
  //       .toSet();

  //   final cosmeticsCategories = [
  //     1926152773, //armor cosmetics
  //     2048875504, //weapon cosmetics
  //     2549160099, //ghost cosmetics
  //   ];

  //   return categories?.any(cosmeticsCategories.contains) ?? false;
  // }

  // List<int>? socketPlugHashes(int socketIndex) {
  //   final plugHashes = _socketPlugHashes(socketIndex);
  //   bool favoritable = isSocketFavoritable(socketIndex);
  //   if (!favoritable) return plugHashes;
  //   final plugs = plugHashes?.toList();
  //   plugs?.sort((a, b) {
  //     final favoriteA = itemNotes.getNotesForItem(a, null)?.tags?.contains("favorite") ?? false;
  //     final favoriteB = itemNotes.getNotesForItem(b, null)?.tags?.contains("favorite") ?? false;
  //     final valueA = favoriteA ? 1 : 0;
  //     final valueB = favoriteB ? 1 : 0;
  //     final favoriteOrder = valueB.compareTo(valueA);
  //     if (favoriteOrder != 0) return favoriteOrder;
  //     final orderA = plugHashes?.indexOf(a) ?? -1;
  //     final orderB = plugHashes?.indexOf(b) ?? -1;
  //     return orderB.compareTo(orderA);
  //   });
  //   return plugs;
  // }

  // List<int>? possiblePlugHashes(int socketIndex) {
  //   final randomHashes = randomizedPlugHashes(socketIndex);
  //   if (randomHashes == null || randomHashes.isEmpty) {
  //     return [];
  //   }
  //   final hashes = socketPlugHashes(socketIndex);
  //   hashes?.addAll(randomHashes.where((p) => !hashes.contains(p)).whereType<int>());
  //   hashes?.sort((a, b) {
  //     final canRollA = canRollPerk(socketIndex, a) ? 1 : 0;
  //     final canRollB = canRollPerk(socketIndex, b) ? 1 : 0;
  //     return canRollB.compareTo(canRollA);
  //   });
  //   return hashes;
  // }

  // bool canRollPerk(int socketIndex, int plugHash) {
  //   final entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);
  //   if (_plugSetDefinitions?.containsKey(entry?.randomizedPlugSetHash) ?? false) {
  //     final randomPlugs = _plugSetDefinitions?[entry?.randomizedPlugSetHash]?.reusablePlugItems;
  //     final plug = randomPlugs?.lastWhereOrNull((p) => p.plugItemHash == plugHash);
  //     if (plug != null) return plug.currentlyCanRoll ?? false;
  //   }
  //   return true;
  // }

  // List<int>? randomizedPlugHashes(int socketIndex) {
  //   var entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);
  //   if ((entry?.randomizedPlugSetHash ?? 0) == 0) return <int>[];
  //   if (!(_plugSetDefinitions?.containsKey(entry?.randomizedPlugSetHash) ?? false)) return <int>[];
  //   final hashes = _plugSetDefinitions?[entry?.randomizedPlugSetHash]
  //       ?.reusablePlugItems
  //       ?.map((p) => p.plugItemHash)
  //       .whereType<int>()
  //       .toList();
  //   return hashes;
  // }

  // List<int>? otherPlugHashes(int socketIndex) {
  //   var entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);
  //   if ((entry?.randomizedPlugSetHash ?? 0) == 0) return <int>[];
  //   if (!(_plugSetDefinitions?.containsKey(entry?.randomizedPlugSetHash) ?? false)) return <int>[];
  //   final hashes = _plugSetDefinitions?[entry?.randomizedPlugSetHash]
  //       ?.reusablePlugItems
  //       ?.map((p) => p.plugItemHash)
  //       .whereType<int>()
  //       .toList();
  //   return hashes;
  // }

  // List<int>? bungieRollPlugHashes(int socketIndex) {
  //   var entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);

  //   if ((entry?.reusablePlugItems?.length ?? 0) > 0) {
  //     return entry?.reusablePlugItems?.map((p) => p.plugItemHash).whereType<int>().toList();
  //   }
  //   if ((entry?.singleInitialItemHash ?? 0) != 0) {
  //     return [entry?.singleInitialItemHash].whereType<int>().toList();
  //   }
  //   return [];
  // }

  // int? socketEquippedPlugHash(int socketIndex) {
  //   if (socketStates != null) {
  //     var state = socketStates?.elementAt(socketIndex);
  //     return state?.plugHash;
  //   }
  //   final entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);
  //   if ((entry?.singleInitialItemHash ?? 0) != 0) {
  //     return entry?.singleInitialItemHash;
  //   }
  //   final socketPlugs = socketPlugHashes(socketIndex);
  //   if ((socketPlugs?.length ?? 0) > 0) {
  //     return socketPlugs?.first;
  //   }
  //   final random = randomizedPlugHashes(socketIndex);
  //   if ((random?.length ?? 0) > 0) {
  //     return random?.first;
  //   }
  //   return null;
  // }

  // int? socketSelectedPlugHash(int? socketIndex) {
  //   if (socketIndex == null) return null;
  //   var selected = selectedSockets?.elementAt(socketIndex);
  //   if (selected != null) return selected;
  //   return socketEquippedPlugHash(socketIndex);
  // }

  // int socketRandomizedSelectedPlugHash(int socketIndex) {
  //   var selected = randomizedSelectedSockets?.elementAt(socketIndex);
  //   if (selected != null) return selected;
  //   return 2328497849;
  // }

  // bool canEquip(int socketIndex, int plugHash) {
  //   var def = plugDefinitions?[plugHash];
  //   var cost = def?.plug?.energyCost?.energyCost;
  //   if (cost == 0 || cost == null) return true;
  //   var selectedDef = plugDefinitions?[socketSelectedPlugHash(socketIndex)];
  //   var selectedCost = selectedDef?.plug?.energyCost?.energyCost ?? 0;
  //   var energy = usedEnergy - selectedCost + cost;
  //   return energy <= (armorEnergyCapacity?.capacityValue ?? 0);
  // }
}
