import 'package:bungie_api/destiny2.dart';
import 'package:bungie_api/enums/platform_error_codes.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/core/blocs/notifications/notification.dart';
import 'package:little_light/core/blocs/notifications/notifications.bloc.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/bungie_api.exception.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:provider/provider.dart';

class InventoryBloc extends ChangeNotifier with ManifestConsumer {
  final NotificationsBloc _notificationsBloc;
  final ProfileBloc _profileBloc;

  bool _isBusy = false;
  bool get isBusy => _isBusy;
  bool shouldUseAutoTransfer = true;

  Map<String, DestinyItemInfo> itemsById = {};

  InventoryBloc(BuildContext context)
      : _notificationsBloc = context.read<NotificationsBloc>(),
        _profileBloc = context.read<ProfileBloc>();

  _resetCaches() {
    itemsById = {};
  }

  Future<void> updateInventory() async {
    _isBusy = true;
    notifyListeners();
    final notification = _notificationsBloc.createNotification(UpdateAction());
    await _profileBloc.fetchProfileData();
    _resetCaches();
    await Future.delayed(Duration(seconds: 1));
    _isBusy = false;
    notifyListeners();
    notification.finish();
  }

  Future<void> transfer(
    DestinyItemComponent item,
    String? characterId,
  ) async {
    _isBusy = true;
    notifyListeners();
    final notification = _notificationsBloc
        .createNotification(SingleTransferAction(itemHash: item.itemHash, itemInstanceId: item.itemInstanceId));
    await _transfer(item, characterId);
    await Future.delayed(Duration(seconds: 1));
    _isBusy = false;
    notifyListeners();
    notification.finish();
  }

  Future<void> transferMultiple(List<DestinyItemComponent> items, String? characterId) async {
    for (final item in items) {
      await _transfer(item, characterId);
    }
  }

  Future<void> _transfer(
    DestinyItemComponent item,
    String? characterId, {
    int? stackSize,
    List<String> idsToAvoid = const [],
    List<int> hashesToAvoid = const [],
  }) async {
    final bool isInstanced = item.itemInstanceId != null;
    if (isInstanced) {
      _transferInstanced(item, characterId);
    }
  }

  Future<void> _transferInstanced(
    DestinyItemComponent item,
    String? characterId, {
    List<int> idsToAvoid = const <int>[],
  }) async {
    final itemHash = item.itemHash;
    final itemInstanceId = item.itemInstanceId;
    final isOnPostmaster = item.location == ItemLocation.Postmaster;
    if (itemHash == null) throw ("Missing item Hash");
    if (itemInstanceId == null) throw ("Missing item instance ID");
    final sourceCharacterId = _profileBloc.getItemOwner(itemInstanceId);
    final destinationCharacterId = characterId;
    final isOnVault = item.location == ItemLocation.Vault;
    final shouldMoveToVault = sourceCharacterId != destinationCharacterId && !isOnVault;
    final shouldMoveToOtherCharacter = sourceCharacterId != destinationCharacterId && destinationCharacterId != null;
    if (isOnPostmaster) {
      if (sourceCharacterId == null) throw ("Missing item owner when pulling from postmaster");
      print('moving from postmaster');

      try {
        await _profileBloc.pullFromPostMaster(itemHash, 1, itemInstanceId, sourceCharacterId);
      } on BungieApiException catch (e) {
        if (e.errorCode == PlatformErrorCodes.DestinyNoRoomInDestination) {
          await _makeRoomOnCharacter(sourceCharacterId, itemHash);
          await _transferInstanced(item, characterId, idsToAvoid: idsToAvoid);
          return;
        }
        throw (e);
      }
      notifyListeners();
    }

    if (shouldMoveToVault) {
      if (sourceCharacterId == null) throw ("Missing item owner when moving to vault");
      await _profileBloc.transferItem(itemHash, 1, true, itemInstanceId, sourceCharacterId);
      notifyListeners();
    }
    if (shouldMoveToOtherCharacter) {
      if (destinationCharacterId == null) throw ("Missing item owner when moving to character");
      print('moving to character');
      try {
        await _profileBloc.transferItem(itemHash, 1, false, itemInstanceId, destinationCharacterId);
      } on BungieApiException catch (e) {
        if (e.errorCode == PlatformErrorCodes.DestinyNoRoomInDestination) {
          await _makeRoomOnCharacter(destinationCharacterId, itemHash);
          await _transferInstanced(item, characterId, idsToAvoid: idsToAvoid);
          return;
        }
        throw (e);
      }
      notifyListeners();
    }
    print('done');
  }

  Future<DestinyItemComponent?> _makeRoomOnCharacter(
    String characterID,
    int itemHash, {
    List<String>? idsToAvoid,
    List<int>? hashesToAvoid,
  }) async {
    if (!shouldUseAutoTransfer) return null;
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(itemHash);
    final bucketHash = def?.inventory?.bucketTypeHash;
    if (bucketHash == null) return null;
    final bucketDef = await manifest.getDefinition<DestinyInventoryBucketDefinition>(def?.inventory?.bucketTypeHash);
    final availableSlots = (bucketDef?.itemCount ?? 0) - (bucketDef?.category == BucketCategory.Equippable ? 1 : 0);
    final itemsOnBucket =
        _profileBloc.getCharacterInventory(characterID).where((element) => element.bucketHash == bucketHash);
    if (itemsOnBucket.length < availableSlots) return null;
    final itemToTransfer = itemsOnBucket.lastWhereOrNull((i) {
      final avoidId = idsToAvoid?.contains(i.itemInstanceId) ?? false;
      if (avoidId) return false;
      final avoidHash = hashesToAvoid?.contains(i.itemHash) ?? false;
      if (avoidHash) return false;
      return true;
    });
    if (itemToTransfer == null) return null;
    await _transfer(itemToTransfer, null);
    return itemToTransfer;
  }

  Future<void> transferLoadout(LoadoutItemIndex loadout, String? characterId, {int? freeSlots}) async {}

  Future<void> equipLoadout(LoadoutItemIndex loadout, String? characterId, {int? freeSlots}) async {}
}
