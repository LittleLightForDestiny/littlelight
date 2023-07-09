import 'dart:async';
import 'package:bungie_api/destiny2.dart';
import 'package:bungie_api/enums/platform_error_codes.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/app_lifecycle/app_lifecycle.bloc.dart';
import 'package:little_light/core/blocs/inventory/actions/queued_actions.dart';
import 'package:little_light/core/blocs/inventory/apply_mods_error_messages.dart';
import 'package:little_light/core/blocs/inventory/exceptions/inventory_exceptions.dart';
import 'package:little_light/core/blocs/inventory/transfer_error_messages.dart';
import 'package:little_light/core/blocs/notifications/notification_actions.dart';
import 'package:little_light/core/blocs/notifications/notifications.bloc.dart';
import 'package:little_light/core/blocs/offline_mode/offline_mode.bloc.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/core/utils/logger/logger.wrapper.dart';
import 'package:little_light/models/bungie_api.exception.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_index.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_info.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/models/transfer_destination.dart';
import 'package:little_light/shared/utils/helpers/loadout_helpers.dart';
import 'package:little_light/shared/utils/helpers/plug_helpers.dart';
import 'package:little_light/shared/utils/sorters/items/item_sorter.dart';
import 'package:little_light/shared/utils/sorters/items/tier_type_sorter.dart';
import 'package:provider/provider.dart';

const _refreshDelay = Duration(seconds: 30);
const _maxConcurrentTransfers = 5;

class _PutBackTransfer {
  final InventoryItemInfo item;
  final TransferDestination destination;

  _PutBackTransfer(this.item, this.destination);
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
  final OfflineModeBloc _offlineModeBloc;
  final UserSettingsBloc _userSettingsBloc;

  DateTime? _lastUpdated;
  Timer? _updateTimer;

  bool _isBusy = false;
  bool get isBusy => _isBusy;
  bool get shouldUseAutoTransfer => _userSettingsBloc.enableAutoTransfers;

  List<String> instanceIdsToAvoid = [];
  final List<QueuedAction> _actionQueue = [];

  InventoryBloc(BuildContext context)
      : _context = context,
        _offlineModeBloc = context.read<OfflineModeBloc>(),
        _notificationsBloc = context.read<NotificationsBloc>(),
        _profileBloc = context.read<ProfileBloc>(),
        _lifecycleBloc = context.read<AppLifecycleBloc>(),
        _userSettingsBloc = context.read<UserSettingsBloc>();

  init() async {
    await _firstLoad();
    updateInventory();
    _startAutoUpdater();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  _startAutoUpdater() {
    if (_updateTimer?.isActive ?? false) return;
    _updateTimer = Timer.periodic(const Duration(seconds: 1), _timedUpdate);
  }

  void _timedUpdate(Timer timer) {
    if (!_lifecycleBloc.isActive) return;
    if (isBusy) return;
    final lastUpdated = _lastUpdated;
    if (lastUpdated == null) return;
    if (_offlineModeBloc.isOffline) return;
    final elapsedTime = DateTime.now().difference(lastUpdated);
    if (elapsedTime > _refreshDelay) {
      logger.info("last refresh was on $lastUpdated, auto-refreshing");
      updateInventory();
    }
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
      await _profileBloc.refresh();
      _lastUpdated = DateTime.now();
      await Future.delayed(const Duration(seconds: 1));
      _isBusy = false;
      notifyListeners();
      notification.dismiss();
    } catch (e) {
      notification.dismiss();
      _isBusy = false;
      notifyListeners();
      final errorNotification = _notificationsBloc.createNotification(UpdateErrorAction());
      await Future.delayed(const Duration(seconds: 2));
      errorNotification.dismiss();
    }
  }

  Future<void> transfer(
    InventoryItemInfo item,
    TransferDestination destination, {
    int stackSize = 1,
  }) async {
    final action = await _addTransferToQueue(item, destination, stackSize: stackSize);
    _startActionQueue();
    await action?.future.future;
  }

  Future<void> equip(
    InventoryItemInfo item,
    TransferDestination destination,
  ) async {
    final action = await _addTransferToQueue(item, destination, equip: true);
    _startActionQueue();
    await action?.future.future;
  }

  Future<void> applyPlugs(InventoryItemInfo item, Map<int, int> plugs) async {
    final action = await _addApplyPlugsToQueue(item, plugs);
    _startActionQueue();
    await action?.future.future;
  }

  Future<void> changeItemLockState(InventoryItemInfo item, bool locked) async {
    await _profileBloc.changeItemLockState(item, locked);
  }

  Future<QueuedApplyPlugs?> _addApplyPlugsToQueue(InventoryItemInfo item, Map<int, int> plugs) async {
    final notification = _notificationsBloc.createNotification(ApplyPlugsNotification(
      item: item,
    ));
    final action = QueuedApplyPlugs(item: item, notification: notification, plugs: plugs);
    final instanceId = item.instanceId;
    if (instanceId != null) instanceIdsToAvoid.add(instanceId);
    _actionQueue.add(action);
    return action;
  }

  Future<QueuedTransfer?> _addTransferToQueue(InventoryItemInfo item, TransferDestination destination,
      {bool equip = false, int stackSize = 1}) async {
    final sourceCharacter = _profileBloc.getCharacterById(item.characterId);
    final sourceType = item.characterId != null
        ? TransferDestinationType.character
        : item.bucketHash == InventoryBucket.general
            ? TransferDestinationType.vault
            : TransferDestinationType.profile;
    final source = TransferDestination(sourceType, character: sourceCharacter);

    final destinationCharacter = destination.character;
    if (sourceCharacter?.characterId == destinationCharacter?.characterId &&
        sourceCharacter?.characterId != null &&
        item.bucketHash != InventoryBucket.lostItems &&
        equip == (item.instanceInfo?.isEquipped ?? false)) {
      logger.info("item is already on destination. Skipping.");
      return null;
    }
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
    if (def?.nonTransferrable == true &&
        sourceCharacter?.characterId != destinationCharacter?.characterId &&
        destination.type != TransferDestinationType.profile) {
      logger.info("can't transfer nonTransferrable item to a different character");
      return null;
    }

    final sameItemTranfers = _actionQueue.where(
      (t) =>
          t is QueuedTransfer && //
          t.item.instanceId == item.instanceId &&
          t.item.itemHash == item.itemHash,
    );
    for (final t in sameItemTranfers) {
      t.cancel(_context);
      if (!t.started) _actionQueue.remove(t);
    }

    final notification = _notificationsBloc.createNotification(TransferNotification(
      item: item,
      source: source,
      destination: destination,
    ));
    final transfer = equip
        ? QueuedEquip(
            item: item,
            destination: destination,
            notification: notification,
          )
        : QueuedTransfer(
            item: item,
            destination: destination,
            notification: notification,
            stackSize: stackSize,
          );
    final instanceId = item.instanceId;
    if (instanceId != null) {
      instanceIdsToAvoid.add(instanceId);
    }
    _actionQueue.add(transfer);
    return transfer;
  }

  void _startActionQueue() async {
    final transfersWaiting = _actionQueue.where((t) => !t.started);
    if (_actionQueue.isEmpty) {
      _isBusy = false;
      instanceIdsToAvoid.clear();
      return;
    }
    _isBusy = true;
    final runningTransfers = _actionQueue.where((t) => t.started);
    if (runningTransfers.length > _maxConcurrentTransfers - 1) return;
    final next = await _findNextTransfer(transfersWaiting, runningTransfers);
    if (next == null) return;
    if (next is QueuedTransfer) {
      _transfer(
        next.item,
        next.destination,
        notification: next.notification,
        transfer: next,
        equip: next is QueuedEquip,
        stackSize: next.stackSize,
      );
    }
    if (next is QueuedApplyPlugs) {
      _applyPlugs(
        next.item,
        notification: next.notification,
        action: next,
      );
    }

    await Future.delayed(const Duration(milliseconds: 100));
    _startActionQueue();
  }

  Future<QueuedAction?> _findNextTransfer(
    Iterable<QueuedAction> waiting,
    Iterable<QueuedAction> running,
  ) async {
    final postmasterTransfers = running.whereType<QueuedTransfer>().where((t) => t.startedOnPostmaster);
    final busySlots = <_BusySlot>[];
    for (final transfer in postmasterTransfers) {
      final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(transfer.item.itemHash);
      final characterId = transfer.item.characterId;
      final bucketHash = def?.inventory?.bucketTypeHash;
      if (bucketHash == null) continue;
      if (characterId == null) continue;
      if (!shouldUseAutoTransfer) continue;
      busySlots.add(_BusySlot(characterId: characterId, bucketHash: bucketHash));
    }
    final equipmentBusyBlocks = <String>{};
    final equipTransfers = (waiting.toList() + running.toList()).whereType<QueuedEquip>();
    for (final transfer in equipTransfers) {
      final characterId = transfer.destination.characterId;
      final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(transfer.item.itemHash);
      final bucketHash = def?.inventory?.bucketTypeHash;
      if (bucketHash == null) continue;
      if (characterId == null) continue;
      if (def?.inventory?.tierType == TierType.Exotic) continue;

      final currentlyEquipped = _findCurrentlyEquipped(bucketHash, characterId);
      final currentlyEquippedHash = currentlyEquipped?.itemHash;
      final currentlyEquippedDef = await manifest.getDefinition<DestinyInventoryItemDefinition>(currentlyEquippedHash);
      final tierType = currentlyEquippedDef?.inventory?.tierType;
      final uniqueLabel = currentlyEquippedDef?.equippingBlock?.uniqueLabel;
      if (tierType == TierType.Exotic && uniqueLabel != null) {
        equipmentBusyBlocks.add(uniqueLabel);
      }
    }

    for (final transfer in waiting) {
      final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(transfer.item.itemHash);
      final defaultBucketHash = def?.inventory?.bucketTypeHash;
      final currentBucket = transfer.item.bucketHash;
      final isFromPostmaster = currentBucket == InventoryBucket.lostItems;
      if (isFromPostmaster) {
        final isBusy = busySlots.any((b) =>
            b.characterId == transfer.item.characterId && //
            defaultBucketHash == b.bucketHash);
        if (isBusy) continue;
      }
      final isFromVaultToCharacter = currentBucket == InventoryBucket.general;
      if (isFromVaultToCharacter) {
        final isBusy = busySlots.any((b) =>
            transfer is QueuedTransfer &&
            b.characterId == transfer.destination.characterId && //
            defaultBucketHash == b.bucketHash);
        if (isBusy) continue;
      }
      final isEquipTransfer = transfer is QueuedEquip;

      final uniqueLabel = def?.equippingBlock?.uniqueLabel;
      if (isEquipTransfer && uniqueLabel != null) {
        final isBusy = equipmentBusyBlocks.contains(uniqueLabel);
        if (isBusy) continue;
      }
      return transfer;
    }
    return null;
  }

  Future<void> equipMultiple(List<InventoryItemInfo> items, TransferDestination destination) async {
    final actions = <QueuedTransfer>[];
    final busyBuckets = <int>{};
    final busyExoticBlocks = <String>{};
    for (final item in items) {
      final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
      final bucketHash = def?.inventory?.bucketTypeHash;
      final isBucketBusy = busyBuckets.contains(bucketHash);
      final uniqueLabel = def?.equippingBlock?.uniqueLabel;
      final isBlockBusy = busyExoticBlocks.contains(uniqueLabel);
      final isEquippable = def?.equippable ?? false;
      final shouldEquip = !isBucketBusy && !isBlockBusy && isEquippable;
      final action = await _addTransferToQueue(item, destination, equip: shouldEquip);
      if (action != null) actions.add(action);
      if (shouldEquip && bucketHash != null) busyBuckets.add(bucketHash);
      if (shouldEquip && uniqueLabel != null) busyExoticBlocks.add(uniqueLabel);
    }
    _startActionQueue();
    await Future.wait(actions.map((e) => e.future.future));
  }

  Future<void> transferMultiple(List<InventoryItemInfo> items, TransferDestination destination) async {
    final actions = <QueuedTransfer>[];
    for (final item in items) {
      final action = await _addTransferToQueue(item, destination, stackSize: item.quantity);
      if (action != null) actions.add(action);
    }
    _startActionQueue();
    await Future.wait(actions.map((e) => e.future.future));
  }

  Future<void> _transfer(
    InventoryItemInfo item,
    TransferDestination destination, {
    int stackSize = 1,
    TransferNotification? notification,
    QueuedTransfer? transfer,
    bool equip = false,
  }) async {
    final bool isInstanced = item.instanceId != null;
    transfer?.start();
    if (isInstanced) {
      await _transferInstanced(
        item,
        destination,
        notification: notification,
        shouldEquip: equip,
        transfer: transfer,
      );
    } else {
      await _transferUninstanced(
        item,
        destination,
        stackSize: stackSize,
        notification: notification,
        transfer: transfer,
      );
    }
    transfer?.future.complete();
    _actionQueue.remove(transfer);
    _startActionQueue();
  }

  Future<void> _applyPlugs(
    InventoryItemInfo item, {
    ApplyPlugsNotification? notification,
    QueuedApplyPlugs? action,
  }) async {
    if (action == null) return;
    action.start();
    final plugs = <int, int>{};
    for (final p in action.plugs.entries) {
      final canApply = await isPlugAvailableToApplyForFreeViaApi(_context, item, p.key, p.value);
      if (canApply) plugs[p.key] = p.value;
    }
    notification?.setPlugs(plugs);
    bool hadError = false;
    try {
      final futures =
          plugs.entries.map((e) => _applyPlug(item, e.key, e.value, notification: notification, action: action));
      await Future.wait(futures);
    } on BungieApiException catch (e) {
      hadError = true;
      notification?.error(_context.getApplyModsErrorMessage(e));
    } catch (_) {
      hadError = true;
      notification?.error(_context.getApplyModsErrorMessage(null));
    }

    if (!hadError) {
      notification?.success();
    }

    action.future.complete();
    _actionQueue.remove(action);
    _startActionQueue();
    logger.info('done');
  }

  Future<void> _applyPlug(
    InventoryItemInfo item,
    int socketIndex,
    int plugHash, {
    ApplyPlugsNotification? notification,
    QueuedApplyPlugs? action,
  }) async {
    try {
      await _profileBloc.applyPlug(item, socketIndex, plugHash);
      notification?.setPlugStatus(socketIndex, PlugStatus.Success);
    } on BungieApiException catch (e) {
      if (e.errorCode == PlatformErrorCodes.DestinySocketAlreadyHasPlug) {
        notification?.setPlugStatus(socketIndex, PlugStatus.Success);
        return;
      }
      notification?.setPlugStatus(socketIndex, PlugStatus.Fail);
    } catch (_) {
      notification?.setPlugStatus(socketIndex, PlugStatus.Fail);
      rethrow;
    }
  }

  Future<void> _transferInstanced(
    InventoryItemInfo itemInfo,
    TransferDestination destination, {
    TransferNotification? notification,
    QueuedTransfer? transfer,
    bool shouldEquip = false,
  }) async {
    final itemsToPutBack = <_PutBackTransfer>[];

    final itemHash = itemInfo.itemHash;
    final itemInstanceId = itemInfo.instanceId;
    final isOnPostmaster =
        itemInfo.location == ItemLocation.Postmaster || itemInfo.bucketHash == InventoryBucket.lostItems;
    if (itemHash == null) throw ("Missing item Hash");
    if (itemInstanceId == null) throw ("Missing item instance ID");
    final sourceCharacterId = itemInfo.characterId;
    final destinationCharacterId = destination.characterId;
    final isOnVault = itemInfo.location == ItemLocation.Vault;
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

    if (transfer?.cancelled ?? false) {
      return;
    }

    if (isOnPostmaster) {
      if (sourceCharacterId == null) throw ("Missing item owner when pulling from postmaster");
      for (int tries = 0; tries < 4; tries++) {
        try {
          logger.info('moving to vault');
          notification?.currentStep = TransferSteps.PullFromPostmaster;
          await _profileBloc.pullFromPostMaster(itemInfo, 1);
          break;
        } on BungieApiException catch (e) {
          if (e.errorCode == PlatformErrorCodes.DestinyNoRoomInDestination && shouldUseAutoTransfer && tries < 3) {
            logger.info("try number $tries to make room on character for postmaster items");
            final item = await _makeRoomOnCharacter(sourceCharacterId, itemHash, originalNotification: notification);
            if (item != null && destination.characterId != sourceCharacterId) {
              final character = _profileBloc.getCharacterById(sourceCharacterId);
              final transferDestination = TransferDestination(
                TransferDestinationType.character,
                character: character,
              );
              itemsToPutBack.add(_PutBackTransfer(item, transferDestination));
            }
            continue;
          }
          logger.info("giving up after $tries tries");
          notification?.error(_context.getTransferErrorMessage(e));
          return;
        } catch (e) {
          notification?.error(_context.getTransferErrorMessage(null));
          return;
        }
      }
      notifyListeners();
    }

    if (transfer?.cancelled ?? false) {
      return;
    }
    if (isEquipped) {
      try {
        notification?.currentStep = TransferSteps.Unequip;
        final success = await _unequipItem(itemInfo);
        if (!success) throw SubstituteNotFoundException();
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

    if (transfer?.cancelled ?? false) {
      return;
    }
    if (shouldMoveToVault) {
      if (sourceCharacterId == null) throw ("Missing item owner when moving to vault");
      logger.info('moving to vault');
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
    if (transfer?.cancelled ?? false) {
      return;
    }
    if (shouldMoveToOtherCharacter) {
      logger.info('moving to character');
      for (int tries = 0; tries < 4; tries++) {
        try {
          notification?.currentStep = TransferSteps.MoveToCharacter;
          await _profileBloc.transferItem(itemInfo, 1, false, destinationCharacterId);
          break;
        } on BungieApiException catch (e) {
          if (e.errorCode == PlatformErrorCodes.DestinyNoRoomInDestination && shouldUseAutoTransfer && tries < 3) {
            logger.info("try number $tries to make room on character");
            await _makeRoomOnCharacter(
              destinationCharacterId,
              itemHash,
              originalNotification: notification,
            );
            continue;
          }
          logger.info("giving up after $tries tries");
          notification?.error(_context.getTransferErrorMessage(e));
          return;
        } catch (e) {
          notification?.error(_context.getTransferErrorMessage(null));
          return;
        }
      }
      notifyListeners();
    }
    if (transfer?.cancelled ?? false) {
      return;
    }
    if (shouldEquip) {
      if (destinationCharacterId == null) throw ("Missing destination character when equipping");
      logger.info('equipping');
      for (int tries = 0; tries < 2; tries++) {
        try {
          notification?.currentStep = TransferSteps.EquipOnCharacter;
          await _profileBloc.equipItem(itemInfo);
        } on BungieApiException catch (e) {
          if (e.errorCode == PlatformErrorCodes.DestinyItemUniqueEquipRestricted &&
              tries < 1 &&
              shouldUseAutoTransfer) {
            final blocking = await _findBlockingExoticFor(itemInfo, destinationCharacterId);
            if (blocking == null) {
              continue;
            }
            notification?.createSideEffect(
              item: blocking,
              source: destination,
              destination: destination,
              unequip: true,
            );
            final success = await _unequipItem(blocking, forceNonExotic: true);
            if (success) continue;
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
    notification?.success();
    logger.info('done');
    for (final item in itemsToPutBack) {
      await _addTransferToQueue(item.item, item.destination);
    }
  }

  Future<InventoryItemInfo?> _findBlockingExoticFor(InventoryItemInfo item, String characterId) async {
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
    final uniqueLabel = def?.equippingBlock?.uniqueLabel;
    if (uniqueLabel == null) return null;
    final candidates = _profileBloc.allItems.where((element) {
      final isEquipped = element.instanceInfo?.isEquipped ?? false;
      if (!isEquipped) return false;
      final isOnCharacter = element.characterId == characterId;
      if (!isOnCharacter) return false;
      return true;
    });
    for (final candidate in candidates) {
      final candidateDef = await manifest.getDefinition<DestinyInventoryItemDefinition>(candidate.itemHash);
      final candidateUniqueLabel = candidateDef?.equippingBlock?.uniqueLabel;
      if (candidateUniqueLabel == uniqueLabel) return candidate;
    }
    return null;
  }

  Future<bool> _unequipItem(InventoryItemInfo item, {bool forceNonExotic = false}) async {
    try {
      final substitute = await _findSubstitute(item, forceNonExotic: forceNonExotic);
      if (substitute == null) {
        throw Exception("can't find a proper substitute to unequip exotic ${item.itemHash}");
      }
      await _profileBloc.equipItem(substitute);
      return true;
    } catch (e) {
      logger.error("There was an error when trying to unequip an item");
      logger.error(e);
      return false;
    }
  }

  Future<void> _transferUninstanced(
    InventoryItemInfo itemInfo,
    TransferDestination destination, {
    QueuedTransfer? transfer,
    TransferNotification? notification,
    int stackSize = 1,
  }) async {
    final isOnPostmaster = itemInfo.bucketHash == InventoryBucket.lostItems;
    final shouldMoveToVault = destination.type == TransferDestinationType.vault;
    final shouldMoveToCharacter = itemInfo.bucketHash == InventoryBucket.general && !shouldMoveToVault;
    final destinationCharacterId = _profileBloc.characters?.firstOrNull?.characterId;

    notification?.createSteps(
      isOnPostmaster: isOnPostmaster,
      moveToVault: shouldMoveToVault,
      moveToCharacter: shouldMoveToCharacter,
    );
    if (transfer?.cancelled ?? false) {
      return;
    }
    if (isOnPostmaster) {
      try {
        logger.info('pulling from postmaster');
        notification?.currentStep = TransferSteps.PullFromPostmaster;
        await _profileBloc.pullFromPostMaster(itemInfo, stackSize);
      } on BungieApiException catch (e) {
        notification?.error(_context.getTransferErrorMessage(e));
        return;
      } catch (e) {
        notification?.error(_context.getTransferErrorMessage(null));
        return;
      }
    }
    if (transfer?.cancelled ?? false) {
      return;
    }
    if (shouldMoveToVault) {
      try {
        logger.info('moving to vault');
        notification?.currentStep = TransferSteps.MoveToVault;
        if (destinationCharacterId == null) throw ("Missing destination character when equipping");
        await _profileBloc.transferItem(itemInfo, stackSize, true, destinationCharacterId);
      } on BungieApiException catch (e) {
        notification?.error(_context.getTransferErrorMessage(e));
        return;
      } catch (e) {
        notification?.error(_context.getTransferErrorMessage(null));
        return;
      }
    }
    if (transfer?.cancelled ?? false) {
      return;
    }
    if (shouldMoveToCharacter) {
      try {
        logger.info('moving to profile');
        notification?.currentStep = TransferSteps.MoveToCharacter;
        if (destinationCharacterId == null) throw ("Missing destination character when equipping");
        await _profileBloc.transferItem(itemInfo, stackSize, false, destinationCharacterId);
      } on BungieApiException catch (e) {
        notification?.error(_context.getTransferErrorMessage(e));
        return;
      } catch (e) {
        notification?.error(_context.getTransferErrorMessage(null));
        return;
      }
    }
    if (transfer?.cancelled ?? false) {
      return;
    }
    notification?.success();
    logger.info('done');
  }

  InventoryItemInfo? _findCurrentlyEquipped(int bucketHash, String characterId) {
    return _profileBloc.allItems.firstWhereOrNull((element) {
      final isEquipped = element.instanceInfo?.isEquipped ?? false;
      if (!isEquipped) return false;
      final isOnCharacter = element.characterId == characterId;
      if (!isOnCharacter) return false;
      final isOnSameBucket = element.bucketHash == bucketHash;
      if (!isOnSameBucket) return false;
      return true;
    });
  }

  Future<InventoryItemInfo?> _findSubstitute(InventoryItemInfo itemInfo, {bool forceNonExotic = false}) async {
    final characterId = itemInfo.characterId;
    if (characterId == null) return null;
    final candidates = _profileBloc.allItems.where((item) =>
        item.bucketHash == itemInfo.bucketHash && //
        !instanceIdsToAvoid.contains(item.instanceId) &&
        item.characterId == characterId &&
        !(item.instanceInfo?.isEquipped ?? false));
    final character = _profileBloc.getCharacter(characterId);
    final itemDef = await manifest.getDefinition<DestinyInventoryItemDefinition>(itemInfo.itemHash);
    final itemTierType = itemDef?.inventory?.tierType;

    for (final c in candidates) {
      final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(c.itemHash);
      final tierType = def?.inventory?.tierType;
      final classType = def?.classType;
      final acceptableClasses = [character?.classType, DestinyClass.Unknown];
      if (!acceptableClasses.contains(classType)) continue;
      if (tierType == TierType.Exotic && forceNonExotic) continue;
      if (tierType != TierType.Exotic || tierType == itemTierType) return c;
    }

    return null;
  }

  Future<InventoryItemInfo?> _makeRoomOnCharacter(
    String characterId,
    int itemHash, {
    List<int>? hashesToAvoid,
    TransferNotification? originalNotification,
  }) async {
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(itemHash);
    final bucketHash = def?.inventory?.bucketTypeHash;
    if (bucketHash == null) return null;
    final bucketDef = await manifest.getDefinition<DestinyInventoryBucketDefinition>(def?.inventory?.bucketTypeHash);
    final availableSlots = (bucketDef?.itemCount ?? 0) - (bucketDef?.category == BucketCategory.Equippable ? 1 : 0);
    final itemsOnBucket =
        _profileBloc.allItems.where((item) => item.bucketHash == bucketHash && item.characterId == characterId);
    if (itemsOnBucket.length < availableSlots) return null;
    final itemToTransfer = itemsOnBucket.lastWhereOrNull((i) {
      final avoidId = instanceIdsToAvoid.contains(i.instanceId);
      if (avoidId) return false;
      final avoidHash = hashesToAvoid?.contains(i.itemHash) ?? false;
      if (avoidHash) return false;
      return true;
    });
    if (itemToTransfer == null) return null;
    final itemInstanceId = itemToTransfer.instanceId;
    if (itemInstanceId != null) {
      instanceIdsToAvoid.add(itemInstanceId);
    }
    final character = _profileBloc.getCharacterById(itemToTransfer.characterId);
    final source = TransferDestination(TransferDestinationType.character, character: character);
    final notification = originalNotification?.createSideEffect(
      item: itemToTransfer,
      source: source,
      destination: TransferDestination.vault(),
    );
    await _transfer(itemToTransfer, TransferDestination.vault(), notification: notification);
    return itemToTransfer;
  }

  Future<void> transferLoadout(
    LoadoutItemIndex loadout,
    String? characterId, {
    int? freeSlots,
  }) async {
    final character = _profileBloc.getCharacterById(characterId);
    final classType = character?.character.classType;
    final toEquip = loadout.getEquippedItems(classType);
    final allTransferrable = loadout.getNonEquippedItems();

    final hashes = (toEquip + allTransferrable).map((i) => i.itemHash);
    final defs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes);
    final toTransfer = classType == null
        ? allTransferrable
        : allTransferrable.where((item) {
            final def = defs[item.itemHash];
            return [classType, DestinyClass.Unknown].contains(def?.classType);
          }).toList();

    final destination = character != null
        ? TransferDestination(TransferDestinationType.character, character: character)
        : TransferDestination.vault();
    await _transferLoadout(
      loadout,
      destination,
      toEquip: [],
      toTransfer: toEquip + toTransfer,
      freeSlots: freeSlots,
    );
  }

  Future<void> equipLoadout(
    LoadoutItemIndex loadout,
    String? characterId, {
    int? freeSlots,
  }) async {
    if (characterId == null) return;
    final character = _profileBloc.getCharacterById(characterId);
    if (character == null) return;
    final classType = character.character.classType;
    if (classType == null) return;
    final toEquip = loadout.getEquippedItems(classType);
    final allTransferrable = loadout.getNonEquippedItems();

    final hashes = (toEquip + allTransferrable).map((i) => i.itemHash);
    final defs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes);
    final toTransfer = allTransferrable.where((item) {
      final def = defs[item.itemHash];
      return [classType, DestinyClass.Unknown].contains(def?.classType);
    }).toList();
    final sorter = TierTypeSorter(_context, SorterDirection.Ascending, defs);
    toEquip.sort(sorter.sort);

    final destination = TransferDestination(TransferDestinationType.character, character: character);
    await _transferLoadout(
      loadout,
      destination,
      toEquip: toEquip,
      toTransfer: toTransfer,
      freeSlots: freeSlots,
    );
  }

  Future<void> _transferLoadout(
    LoadoutItemIndex loadout,
    TransferDestination destination, {
    int? freeSlots,
    required List<LoadoutItemInfo> toEquip,
    required List<LoadoutItemInfo> toTransfer,
  }) async {
    final actions = <QueuedAction>[];
    final equipMods = toEquip.where((element) => element.itemPlugs.isNotEmpty);
    for (final item in equipMods) {
      final inventoryItem = item.inventoryItem;
      if (inventoryItem == null) continue;
      final action = await _addApplyPlugsToQueue(inventoryItem, item.itemPlugs);
      if (action != null) actions.add(action);
    }

    for (final item in toEquip) {
      final inventoryItem = item.inventoryItem;
      if (inventoryItem == null) continue;
      final action = await _addTransferToQueue(inventoryItem, destination, equip: true);
      if (action != null) actions.add(action);
    }

    final transferMods = toTransfer.where((element) => element.itemPlugs.isNotEmpty);
    for (final item in transferMods) {
      final inventoryItem = item.inventoryItem;
      if (inventoryItem == null) continue;
      final action = await _addApplyPlugsToQueue(inventoryItem, item.itemPlugs);
      if (action != null) actions.add(action);
    }

    for (final item in toTransfer) {
      final inventoryItem = item.inventoryItem;
      if (inventoryItem == null) continue;
      final action = await _addTransferToQueue(inventoryItem, destination, equip: false);
      if (action != null) actions.add(action);
    }
    _startActionQueue();
    await Future.wait(actions.map((e) => e.future.future));
  }
}
