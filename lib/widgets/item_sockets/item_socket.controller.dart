import 'package:bungie_api/destiny2.dart';
import 'package:bungie_api/exceptions.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/models/bungie_api.exception.dart';
import 'package:little_light/services/analytics/analytics.consumer.dart';
import 'package:little_light/services/bungie_api/bungie_api.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/notification/notification.package.dart';
import 'package:little_light/services/profile/vendors.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/item_with_owner.dart';

class ItemSocketController extends ChangeNotifier
    with BungieApiConsumer, ProfileConsumer, ManifestConsumer, NotificationConsumer, AnalyticsConsumer {
  final int _itemHash;
  final ItemWithOwner? item;
  DestinyInventoryItemDefinition? definition;
  List<DestinyItemSocketState>? socketStates;
  List<bool>? _socketBusy;
  Map<String, List<DestinyItemPlugBase>>? reusablePlugs;
  List<int?>? _selectedSockets;
  List<int?>? _randomizedSelectedSockets;
  Map<int, DestinyInventoryItemDefinition>? _plugDefinitions;
  Map<int, DestinyPlugSetDefinition>? _plugSetDefinitions;

  Map<int, DestinyInventoryItemDefinition>? get plugDefinitions => _plugDefinitions;
  int? _selectedSocket;
  int? _selectedSocketIndex;
  int? get selectedSocketIndex => _selectedSocketIndex;
  int? get selectedPlugHash => _selectedSocket;
  int? _armorTierIndex;

  bool get socketsOffline => item != null && socketStates == null;

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

  int get usedEnergy {
    var energy = 0;
    for (var i = 0; i < socketCount; i++) {
      var plugHash = socketSelectedPlugHash(i);
      var def = plugDefinitions?[plugHash];
      energy += def?.plug?.energyCost?.energyCost ?? 0;
    }
    return energy;
  }

  int get usedEnergyWithoutFailedSocket {
    var energy = 0;
    for (var i = 0; i < socketCount; i++) {
      var plugHash = socketSelectedPlugHash(i);
      var def = plugDefinitions?[plugHash];
      if (selectedSocketIndex != i || selectedPlugHash == plugHash) {
        energy += def?.plug?.energyCost?.energyCost ?? 0;
      }
    }
    return energy;
  }

  int get requiredEnergy {
    if (_selectedSocketIndex == null) return 0;
    final socketSelectedHash = socketSelectedPlugHash(_selectedSocketIndex!);
    final used = usedEnergy;
    if (socketSelectedHash == selectedPlugHash) return used;
    final def = plugDefinitions?[selectedPlugHash];
    final currentDef = plugDefinitions?[socketSelectedHash];
    var selectedEnergy = def?.plug?.energyCost?.energyCost ?? 0;
    var currentEnergy = currentDef?.plug?.energyCost?.energyCost ?? 0;
    var energy = used - currentEnergy + selectedEnergy;
    return energy;
  }

  int get socketCount => definition?.sockets?.socketEntries?.length ?? 0;

  List<int?>? get selectedSockets => _selectedSockets;
  List<int?>? get randomizedSelectedSockets => _randomizedSelectedSockets;

  ItemSocketController._(this._itemHash, {this.item, this.socketStates, this.reusablePlugs}) {
    _init();
  }

  factory ItemSocketController.fromItem(ItemWithOwner item) {
    final profile = getInjectedProfileService();
    final itemInstanceID = item.item.itemInstanceId;
    final itemHash = item.item.itemHash;
    if (itemInstanceID == null || itemHash == null) {
      throw ("Can't initialize without itemInstanceID");
    }
    final socketStates = profile.getItemSockets(itemInstanceID);
    final reusablePlugs = profile.getItemReusablePlugs(itemInstanceID);
    return ItemSocketController._(itemHash, item: item, socketStates: socketStates, reusablePlugs: reusablePlugs);
  }

  factory ItemSocketController.fromVendorItem({
    required String characterId,
    required int vendorHash,
    required DestinyVendorSaleItemComponent vendorItem,
  }) {
    final itemHash = vendorItem.itemHash;
    if (itemHash == null) {
      throw ("Can't initialize without itemHash");
    }
    final vendorsService = VendorsService();
    final reusablePlugs =
        vendorsService.getSaleItemReusablePerksSync(characterId, vendorHash, vendorItem.vendorItemIndex);
    final socketStates = vendorsService.getSaleItemSocketsSync(characterId, vendorHash, vendorItem.vendorItemIndex);

    return ItemSocketController._(itemHash, socketStates: socketStates, reusablePlugs: reusablePlugs);
  }

  factory ItemSocketController.fromItemHash(int hash) {
    return ItemSocketController._(hash);
  }

  void _init() async {
    await _loadDefinitions();
    _initDefaults();
  }

  _initDefaults() {
    final entries = definition?.sockets?.socketEntries;

    _selectedSockets = List<int?>.filled(entries?.length ?? 0, null);
    _randomizedSelectedSockets = List<int?>.filled(entries?.length ?? 0, null);
    _socketBusy = List<bool>.generate(socketStates?.length ?? 0, (index) => false);
  }

  Future<void> _loadDefinitions() async {
    final itemDefinition = await manifest.getDefinition<DestinyInventoryItemDefinition>(_itemHash);
    if (itemDefinition == null) return;
    definition = itemDefinition;
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
    _plugSetDefinitions = await manifest.getDefinitions<DestinyPlugSetDefinition>(plugSetHashes);

    List<int?> socketTypeHashes = [];
    final definitionPlugHashes = itemDefinition.sockets?.socketEntries
        ?.expand((socket) {
          socketTypeHashes.add(socket.socketTypeHash);
          List<int?> hashes = [];
          hashes.add(socket.singleInitialItemHash);
          hashes.addAll(socket.reusablePlugItems?.map((p) => p.plugItemHash) ?? []);
          DestinyPlugSetDefinition? reusablePlugSet = _plugSetDefinitions?[socket.reusablePlugSetHash];
          DestinyPlugSetDefinition? randomizedPlugSet = _plugSetDefinitions?[socket.randomizedPlugSetHash];
          hashes.addAll(reusablePlugSet?.reusablePlugItems?.map((i) => i.plugItemHash) ?? []);
          hashes.addAll(randomizedPlugSet?.reusablePlugItems?.map((i) => i.plugItemHash) ?? []);
          return hashes;
        })
        .whereType<int>()
        .where((i) => i != 0)
        .toSet();

    plugHashes.addAll(definitionPlugHashes ?? <int>{});
    _plugDefinitions = await manifest.getDefinitions<DestinyInventoryItemDefinition>(plugHashes);

    DestinyItemSocketCategoryDefinition? armorTierCategory = itemDefinition.sockets?.socketCategories
        ?.firstWhereOrNull((s) => DestinyData.socketCategoryTierHashes.contains(s.socketCategoryHash));
    _armorTierIndex = armorTierCategory?.socketIndexes?.first;
    notifyListeners();
  }

  void selectSocket(int socketIndex, int plugHash) {
    if (plugHash == _selectedSocket && socketIndex == _selectedSocketIndex) {
      _selectedSocket = null;
      _selectedSocketIndex = null;
    } else {
      _selectedSocketIndex = socketIndex;
      _selectedSocket = plugHash;
      var can = canEquip(socketIndex, plugHash);
      if (can) {
        _selectedSockets?[socketIndex] = plugHash;
        final plugHashes = socketPlugHashes(socketIndex);
        final containsPlug = plugHashes?.contains(plugHash) ?? false;
        if (!containsPlug) {
          _randomizedSelectedSockets?[socketIndex] = plugHash;
        }
      }
    }
    notifyListeners();
  }

  void applySocket(int socketIndex, int plugHash) async {
    final instanceID = item?.item.itemInstanceId;
    if (instanceID == null) throw ("No item instance available");

    final characterID = profile.getItemOwner(instanceID) ?? profile.characters?.last.characterId;
    if (characterID == null) throw ("No character available");

    notifications.push(NotificationEvent(NotificationType.requestApplyPlug, item: item?.item, plugHash: plugHash));
    _socketBusy?[socketIndex] = true;
    notifyListeners();
    try {
      await bungieAPI.applySocket(instanceID, plugHash, socketIndex, characterID);
      socketStates?[socketIndex].plugHash = plugHash;
    } on BungieApiException catch (e, stackTrace) {
      if ([
        PlatformErrorCodes.DestinyCharacterNotInTower,
        PlatformErrorCodes.DestinyCannotPerformActionAtThisLocation,
      ].contains(e.errorCode)) {
        notifications.push(ErrorNotificationEvent(ErrorNotificationType.onCombatZoneApplyModError, item: item?.item));
        await Future.delayed(const Duration(seconds: 3));
      } else {
        analytics.registerNonFatal(e, stackTrace, additionalInfo: {
          "itemHash": "${item?.item.itemHash}",
          "errorCode": "${e.errorCode}",
          "plugHash": "$plugHash",
          "socketIndex": "$socketIndex"
        });
        rethrow;
      }
    } catch (e, stackTrace) {
      notifications.push(ErrorNotificationEvent(ErrorNotificationType.genericApplyModError, item: item?.item));
      await Future.delayed(const Duration(seconds: 3));
      analytics.registerNonFatal(e, stackTrace);
    }
    _socketBusy?[socketIndex] = false;

    notifyListeners();
    notifications.push(NotificationEvent(NotificationType.itemStateUpdate, item: item?.item));
  }

  bool isSocketBusy(int socketIndex) {
    if (socketIndex >= (_socketBusy?.length ?? 0)) return false;
    return _socketBusy?[socketIndex] ?? false;
  }

  bool canApplySocket(int socketIndex, int plugHash) {
    return _plugDefinitions?[plugHash]?.allowActions ?? false;
  }

  List<int>? _plugHashesFromSocketState(int socketIndex) {
    final entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);
    final state = socketStates?.elementAt(socketIndex);
    if (state?.isVisible == false) return null;
    if (state?.plugHash == null) return null;
    final hashes = <int>[];
    final plugSources = entry?.plugSources;

    final isPlugSet = (plugSources?.contains(SocketPlugSources.CharacterPlugSet) ?? false) ||
        (plugSources?.contains(SocketPlugSources.ProfilePlugSet) ?? false);
    final plugSetHash = entry?.reusablePlugSetHash;
    if (isPlugSet && plugSetHash != null) {
      var plugSet = profile.getPlugSets(plugSetHash);
      hashes.addAll(plugSet.where((p) => p.canInsert ?? false).map((p) => p.plugItemHash).where((p) {
        if (_armorTierIndex == null) return true;
        var def = _plugDefinitions?[p];
        var energyType = def?.plug?.energyCost?.energyType ?? DestinyEnergyType.Any;
        return (energyType == armorEnergyType || energyType == DestinyEnergyType.Any);
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
          var energyType = def?.plug?.energyCost?.energyType ?? DestinyEnergyType.Any;
          return (energyType == armorEnergyType || energyType == DestinyEnergyType.Any);
        })
        .whereType<int>()
        .toList();
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
      return entry?.reusablePlugItems?.map((p) => p.plugItemHash).whereType<int>().where((h) => h != 0).toList();
    }

    if ((entry?.singleInitialItemHash ?? 0) != 0) {
      return [entry?.singleInitialItemHash].whereType<int>().toList();
    }

    return <int>[];
  }

  bool isSocketFavoritable(int socketIndex) {
    final categories = definition?.sockets?.socketCategories
        ?.where((element) => element.socketIndexes?.contains(socketIndex) ?? false)
        .map((s) => s.socketCategoryHash)
        .toSet();

    final cosmeticsCategories = [
      1926152773, //armor cosmetics
      2048875504, //weapon cosmetics
      2549160099, //ghost cosmetics
    ];

    return categories?.any(cosmeticsCategories.contains) ?? false;
  }

  List<int>? socketPlugHashes(int socketIndex) {
    final plugHashes = _socketPlugHashes(socketIndex);
    bool favoritable = isSocketFavoritable(socketIndex);
    if (!favoritable) return plugHashes;
    final plugs = plugHashes?.toList();
    plugs?.sort((a, b) {
      final orderA = plugHashes?.indexOf(a) ?? -1;
      final orderB = plugHashes?.indexOf(b) ?? -1;
      return orderB.compareTo(orderA);
    });
    return plugs;
  }

  List<int>? possiblePlugHashes(int socketIndex) {
    final randomHashes = randomizedPlugHashes(socketIndex);
    if (randomHashes == null || randomHashes.isEmpty) {
      return [];
    }
    final hashes = socketPlugHashes(socketIndex);
    hashes?.addAll(randomHashes.where((p) => !hashes.contains(p)).whereType<int>());
    hashes?.sort((a, b) {
      final canRollA = canRollPerk(socketIndex, a) ? 1 : 0;
      final canRollB = canRollPerk(socketIndex, b) ? 1 : 0;
      return canRollB.compareTo(canRollA);
    });
    return hashes;
  }

  bool canRollPerk(int socketIndex, int plugHash) {
    final entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);
    if (_plugSetDefinitions?.containsKey(entry?.randomizedPlugSetHash) ?? false) {
      final randomPlugs = _plugSetDefinitions?[entry?.randomizedPlugSetHash]?.reusablePlugItems;
      final plug = randomPlugs?.lastWhereOrNull((p) => p.plugItemHash == plugHash);
      if (plug != null) return plug.currentlyCanRoll ?? false;
    }
    return true;
  }

  List<int>? randomizedPlugHashes(int socketIndex) {
    var entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);
    if ((entry?.randomizedPlugSetHash ?? 0) == 0) return <int>[];
    if (!(_plugSetDefinitions?.containsKey(entry?.randomizedPlugSetHash) ?? false)) return <int>[];
    final hashes = _plugSetDefinitions?[entry?.randomizedPlugSetHash]
        ?.reusablePlugItems
        ?.map((p) => p.plugItemHash)
        .whereType<int>()
        .toList();
    return hashes;
  }

  List<int>? otherPlugHashes(int socketIndex) {
    var entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);
    if ((entry?.randomizedPlugSetHash ?? 0) == 0) return <int>[];
    if (!(_plugSetDefinitions?.containsKey(entry?.randomizedPlugSetHash) ?? false)) return <int>[];
    final hashes = _plugSetDefinitions?[entry?.randomizedPlugSetHash]
        ?.reusablePlugItems
        ?.map((p) => p.plugItemHash)
        .whereType<int>()
        .toList();
    return hashes;
  }

  List<int>? bungieRollPlugHashes(int socketIndex) {
    var entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);

    if ((entry?.reusablePlugItems?.length ?? 0) > 0) {
      return entry?.reusablePlugItems?.map((p) => p.plugItemHash).whereType<int>().toList();
    }
    if ((entry?.singleInitialItemHash ?? 0) != 0) {
      return [entry?.singleInitialItemHash].whereType<int>().toList();
    }
    return [];
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

  int? socketSelectedPlugHash(int? socketIndex) {
    if (socketIndex == null) return null;
    var selected = selectedSockets?.elementAt(socketIndex);
    if (selected != null) return selected;
    return socketEquippedPlugHash(socketIndex);
  }

  int socketRandomizedSelectedPlugHash(int socketIndex) {
    var selected = randomizedSelectedSockets?.elementAt(socketIndex);
    if (selected != null) return selected;
    return 2328497849;
  }

  bool canEquip(int socketIndex, int plugHash) {
    var def = plugDefinitions?[plugHash];
    var cost = def?.plug?.energyCost?.energyCost;
    if (cost == 0 || cost == null) return true;
    var selectedDef = plugDefinitions?[socketSelectedPlugHash(socketIndex)];
    var selectedCost = selectedDef?.plug?.energyCost?.energyCost ?? 0;
    var energy = usedEnergy - selectedCost + cost;
    return energy <= (armorEnergyCapacity?.capacityValue ?? 0);
  }
}
