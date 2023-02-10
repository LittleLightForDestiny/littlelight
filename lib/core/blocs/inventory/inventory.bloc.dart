import 'dart:async';

import 'package:bungie_api/destiny2.dart';
import 'package:bungie_api/enums/platform_error_codes.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/app_lifecycle/app_lifecycle.bloc.dart';
import 'package:little_light/core/blocs/inventory/exceptions/inventory_exceptions.dart';
import 'package:little_light/core/blocs/inventory/transfer_error_messages.dart';
import 'package:little_light/core/blocs/notifications/notification_actions.dart';
import 'package:little_light/core/blocs/notifications/notifications.bloc.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/blocs/profile/profile_component_groups.dart';
import 'package:little_light/models/bungie_api.exception.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:provider/provider.dart';

const _refreshDelay = Duration(seconds: 30);
const _maxConcurrentTransfers = 5;

class _QueuedTransfer {
  bool started = false;
  final DestinyItemInfo item;
  final DestinyCharacterInfo? destinationCharacter;
  final SingleTransferAction? notification;
  final bool equip;

  _QueuedTransfer({
    required this.item,
    required this.destinationCharacter,
    required this.notification,
    this.equip = false,
  });
}

class _BusySlot {
  final String characterId;
  final int bucketHash;
  _BusySlot({
    required this.characterId,
    required this.bucketHash,
  });
}

class InventoryBloc extends ChangeNotifier with ManifestConsumer {
  final BuildContext _context;
  final NotificationsBloc _notificationsBloc;
  final ProfileBloc _profileBloc;
  final AppLifecycleBloc _lifecycleBloc;

  DateTime? _lastUpdated;
  Timer? _updateTimer;

  bool _isBusy = false;
  bool get isBusy => _isBusy;
  bool shouldUseAutoTransfer = false;

  List<String> instanceIdsToAvoid = [];
  List<_QueuedTransfer> _transferQueue = [];

  InventoryBloc(BuildContext context)
      : _context = context,
        _notificationsBloc = context.read<NotificationsBloc>(),
        _profileBloc = context.read<ProfileBloc>(),
        _lifecycleBloc = context.read<AppLifecycleBloc>();

  init() async {
    await _firstLoad();
    updateInventory();
    // _startAutoUpdater();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  _startAutoUpdater() {
    if (_updateTimer?.isActive ?? false) return;
    _updateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_lifecycleBloc.isActive) return;
      if (isBusy) return;
      final lastUpdated = _lastUpdated;
      if (lastUpdated == null) return;
      final elapsedTime = DateTime.now().difference(lastUpdated);
      if (elapsedTime > _refreshDelay) {
        print("last refresh was on $lastUpdated, auto-refreshing");
        updateInventory();
      }
    });
  }

  Future<void> _firstLoad() async {
    if (_lastUpdated != null || isBusy) return;
    _isBusy = true;
    notifyListeners();
    await _profileBloc.loadFromStorage();
    _isBusy = false;
    notifyListeners();
  }

  Future<void> updateInventory() async {
    if (isBusy) return;
    final notification = _notificationsBloc.createNotification(UpdateAction());
    try {
      _isBusy = true;
      notifyListeners();
      await _profileBloc.refresh(ProfileComponentGroups.basicProfile);
      _lastUpdated = DateTime.now();
      await Future.delayed(Duration(seconds: 1));
      _isBusy = false;
      notifyListeners();
      notification.dismiss();
    } catch (e) {
      notification.dismiss();
      _isBusy = false;
      notifyListeners();
      final errorNotification = _notificationsBloc.createNotification(UpdateErrorAction());
      await Future.delayed(Duration(seconds: 2));
      errorNotification.dismiss();
    }
  }

  Future<void> transfer(
    DestinyItemInfo item,
    String? characterId,
  ) async {
    await _addTransferToQueue(item, characterId);
    await _startTransferQueue();
  }

  Future<void> equip(
    DestinyItemInfo item,
    String? characterId,
  ) async {
    await _addTransferToQueue(item, characterId, equip: true);
    await _startTransferQueue();
  }

  Future<void> _addTransferToQueue(DestinyItemInfo item, String? characterId, {bool equip = false}) async {
    final sourceCharacter = _profileBloc.getCharacterById(item.characterId);
    final destinationCharacter = _profileBloc.getCharacterById(characterId);
    if (sourceCharacter?.characterId == destinationCharacter?.characterId &&
        sourceCharacter?.characterId != null &&
        item.item.bucketHash != InventoryBucket.lostItems &&
        equip == (item.instanceInfo?.isEquipped ?? false)) {
      print("item is already on destination. Skipping.");
      return;
    }
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(item.item.itemHash);
    if (def?.nonTransferrable == true && sourceCharacter?.characterId != destinationCharacter?.characterId) {
      print("can't transfer nonTransferrable item to a different character");
      return;
    }

    final notification = _notificationsBloc.createNotification(SingleTransferAction(
      item: item,
      sourceCharacter: sourceCharacter,
      destinationCharacter: destinationCharacter,
    ));
    final transfer = _QueuedTransfer(
      item: item,
      destinationCharacter: destinationCharacter,
      notification: notification,
      equip: equip,
    );
    final instanceId = item.item.itemInstanceId;
    if (instanceId != null) {
      instanceIdsToAvoid.add(instanceId);
    }
    _transferQueue.add(transfer);
  }

  Future<void> _startTransferQueue() async {
    final transfersWaiting = _transferQueue.where((t) => !t.started);
    if (transfersWaiting.length == 0) {
      _isBusy = false;
      instanceIdsToAvoid.clear();
      return;
    }
    _isBusy = true;
    final runningTransfers = _transferQueue.where((t) => t.started);
    if (runningTransfers.length > _maxConcurrentTransfers - 1) return;
    final next = await _findNextTransfer(transfersWaiting, runningTransfers);
    if (next == null) return;
    _transfer(
      next.item,
      next.destinationCharacter?.characterId,
      notification: next.notification,
      transfer: next,
      equip: next.equip,
    );
    await Future.delayed(Duration(milliseconds: 100));
    _startTransferQueue();
  }

  Future<_QueuedTransfer?> _findNextTransfer(
      Iterable<_QueuedTransfer> waiting, Iterable<_QueuedTransfer> running) async {
    final next = waiting.firstWhereOrNull((t) => t.item.item.bucketHash != InventoryBucket.lostItems);
    if (next != null) return next;
    final postmasterTransfers = running.where((t) => t.item.item.bucketHash == InventoryBucket.lostItems);
    final busySlots = <_BusySlot>[];
    for (final transfer in postmasterTransfers) {
      final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(transfer.item.item.itemHash);
      final charId = transfer.item.characterId;
      final bucketHash = def?.inventory?.bucketTypeHash;
      if (charId == null) continue;
      if (bucketHash == null) continue;
      busySlots.add(_BusySlot(characterId: charId, bucketHash: bucketHash));
    }
    for (final transfer in waiting) {
      final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(transfer.item.item.itemHash);
      final charId = transfer.item.characterId;
      final bucketHash = def?.inventory?.bucketTypeHash;
      if (charId == null) continue;
      if (bucketHash == null) continue;
      if (busySlots.any((b) => b.characterId == charId && b.bucketHash == bucketHash)) continue;
      return transfer;
    }
    return null;
  }

  Future<void> transferMultiple(List<DestinyItemInfo> items, String? characterId) async {
    for (final item in items) {
      await _addTransferToQueue(item, characterId);
    }
    await _startTransferQueue();
  }

  Future<void> _transfer(
    DestinyItemInfo item,
    String? characterId, {
    int? stackSize,
    SingleTransferAction? notification,
    _QueuedTransfer? transfer,
    bool equip = false,
  }) async {
    final bool isInstanced = item.item.itemInstanceId != null;
    transfer?.started = true;
    if (isInstanced) {
      await _transferInstanced(item, characterId, notification: notification, shouldEquip: equip);
    }
    _transferQueue.remove(transfer);
    _startTransferQueue();
  }

  Future<void> _transferInstanced(
    DestinyItemInfo itemInfo,
    String? characterId, {
    SingleTransferAction? notification,
    bool shouldEquip = false,
  }) async {
    final item = itemInfo.item;
    final itemHash = item.itemHash;
    final itemInstanceId = item.itemInstanceId;
    final isOnPostmaster = item.location == ItemLocation.Postmaster || item.bucketHash == InventoryBucket.lostItems;
    if (itemHash == null) throw ("Missing item Hash");
    if (itemInstanceId == null) throw ("Missing item instance ID");
    final sourceCharacterId = itemInfo.characterId;
    final destinationCharacterId = characterId;
    final isOnVault = item.location == ItemLocation.Vault;
    final shouldMoveToVault = sourceCharacterId != destinationCharacterId && !isOnVault;
    final shouldMoveToOtherCharacter = sourceCharacterId != destinationCharacterId && destinationCharacterId != null;
    final isEquipped = itemInfo.instanceInfo?.isEquipped ?? false;
    notification?.createSteps(
      isEquipped: isEquipped,
      isOnPostmaster: isOnPostmaster,
      moveToVault: shouldMoveToVault,
      moveToCharacter: shouldMoveToOtherCharacter,
      equipOnCharacter: shouldEquip,
    );
    if (isOnPostmaster) {
      if (sourceCharacterId == null) throw ("Missing item owner when pulling from postmaster");
      for (int tries = 0; true; tries++) {
        try {
          notification?.currentStep = TransferSteps.PullFromPostmaster;
          await _profileBloc.pullFromPostMaster(itemInfo, 1);
          break;
        } on BungieApiException catch (e) {
          if (e.errorCode == PlatformErrorCodes.DestinyNoRoomInDestination && shouldUseAutoTransfer && tries < 3) {
            await _makeRoomOnCharacter(sourceCharacterId, itemHash);
            continue;
          }
          notification?.error(_context.getTransferErrorMessage(e));
          return;
        } catch (e) {
          notification?.error(_context.getTransferErrorMessage(null));
          return;
        }
      }
      notifyListeners();
    }
    if (isEquipped) {
      try {
        notification?.currentStep = TransferSteps.Unequip;
        final substitute = await _findSubstitute(itemInfo);
        if (substitute == null) throw SubstituteNotFoundException();
        await _profileBloc.equipItem(substitute);
      } on BaseInventoryException catch (e) {
        notification?.error(e.getMessage(_context));
        return;
      } on BungieApiException catch (e) {
        notification?.error(_context.getTransferErrorMessage(e));
        return;
      } catch (e) {
        notification?.error(_context.getTransferErrorMessage(null));
        return;
      }
    }

    if (shouldMoveToVault) {
      if (sourceCharacterId == null) throw ("Missing item owner when moving to vault");
      notification?.currentStep = TransferSteps.MoveToVault;
      try {
        await _profileBloc.transferItem(itemInfo, 1, true, sourceCharacterId);
      } on BungieApiException catch (e) {
        notification?.error(_context.getTransferErrorMessage(e));
        return;
      } catch (e) {
        notification?.error(_context.getTransferErrorMessage(null));
        return;
      }
      notifyListeners();
    }
    if (shouldMoveToOtherCharacter) {
      if (destinationCharacterId == null) throw ("Missing item owner when moving to character");
      print('moving to character');
      for (int tries = 0; true; tries++) {
        try {
          notification?.currentStep = TransferSteps.MoveToCharacter;
          await _profileBloc.transferItem(itemInfo, 1, false, destinationCharacterId);
          break;
        } on BungieApiException catch (e) {
          if (e.errorCode == PlatformErrorCodes.DestinyNoRoomInDestination && shouldUseAutoTransfer && tries < 3) {
            print("$tries try to make roon on character");
            await _makeRoomOnCharacter(destinationCharacterId, itemHash);
            continue;
          }
          print("giving up after $tries");
          notification?.error(_context.getTransferErrorMessage(e));
          return;
        } catch (e) {
          notification?.error(_context.getTransferErrorMessage(null));
          return;
        }
      }
      notifyListeners();
    }
    if (shouldEquip) {
      if (destinationCharacterId == null) throw ("Missing destination character when equipping");
      print('equipping');
      try {
        notification?.currentStep = TransferSteps.EquipOnCharacter;
        await _profileBloc.equipItem(itemInfo);
      } on BungieApiException catch (e) {
        notification?.error(_context.getTransferErrorMessage(e));
        return;
      } catch (e) {
        notification?.error(_context.getTransferErrorMessage(null));
        return;
      }

      notifyListeners();
    }
    notification?.success();
    print('done');
  }

  Future<void> _transferUninstanced(
    DestinyItemInfo itemInfo,
  ) async {}

  Future<DestinyItemInfo?> _findSubstitute(DestinyItemInfo itemInfo) async {
    final characterId = itemInfo.characterId;
    if (characterId == null) return null;
    final candidates = _profileBloc.allItems.where((item) =>
        item.item.bucketHash == itemInfo.item.bucketHash && //
        !instanceIdsToAvoid.contains(item.item.itemInstanceId) &&
        item.characterId == characterId &&
        !(item.instanceInfo?.isEquipped ?? false));
    final character = _profileBloc.getCharacter(characterId);
    final itemDef = await manifest.getDefinition<DestinyInventoryItemDefinition>(itemInfo.item.itemHash);
    final itemTierType = itemDef?.inventory?.tierType;

    for (final c in candidates) {
      final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(c.item.itemHash);
      final tierType = def?.inventory?.tierType;
      final classType = def?.classType;
      final acceptableClasses = [character?.classType, DestinyClass.Unknown];
      if (!acceptableClasses.contains(classType)) continue;
      if (tierType != TierType.Exotic || tierType == itemTierType) return c;
    }

    return null;
  }

  Future<DestinyItemInfo?> _makeRoomOnCharacter(
    String characterId,
    int itemHash, {
    List<int>? hashesToAvoid,
  }) async {
    //TODO: implement notification logic for side effects
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(itemHash);
    final bucketHash = def?.inventory?.bucketTypeHash;
    if (bucketHash == null) return null;
    final bucketDef = await manifest.getDefinition<DestinyInventoryBucketDefinition>(def?.inventory?.bucketTypeHash);
    final availableSlots = (bucketDef?.itemCount ?? 0) - (bucketDef?.category == BucketCategory.Equippable ? 1 : 0);
    final itemsOnBucket =
        _profileBloc.allItems.where((item) => item.item.bucketHash == bucketHash && item.characterId == characterId);
    if (itemsOnBucket.length < availableSlots) return null;
    final itemToTransfer = itemsOnBucket.lastWhereOrNull((i) {
      final avoidId = instanceIdsToAvoid.contains(i.item.itemInstanceId);
      if (avoidId) return false;
      final avoidHash = hashesToAvoid?.contains(i.item.itemHash) ?? false;
      if (avoidHash) return false;
      return true;
    });
    if (itemToTransfer == null) return null;
    final itemInstanceId = itemToTransfer.item.itemInstanceId;
    if (itemInstanceId != null) {
      instanceIdsToAvoid.add(itemInstanceId);
    }
    await _transfer(itemToTransfer, null);
    return itemToTransfer;
  }

  Future<void> transferLoadout(LoadoutItemIndex loadout, String? characterId, {int? freeSlots}) async {}

  Future<void> equipLoadout(LoadoutItemIndex loadout, String? characterId, {int? freeSlots}) async {}
}
