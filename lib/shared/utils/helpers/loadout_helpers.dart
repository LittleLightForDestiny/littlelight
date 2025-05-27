import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_index.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_info.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/shared/utils/helpers/plug_helpers.dart';
import 'package:uuid/uuid.dart';

const loadoutEmptySlotItemHash = 1219897208;

const loadoutGenericBucketHashes = [
  InventoryBucket.kineticWeapons,
  InventoryBucket.energyWeapons,
  InventoryBucket.powerWeapons,
  InventoryBucket.ghost,
  InventoryBucket.vehicle,
  InventoryBucket.ships,
];
const loadoutClassSpecificBucketHashes = [
  InventoryBucket.subclass,
  InventoryBucket.helmet,
  InventoryBucket.gauntlets,
  InventoryBucket.chestArmor,
  InventoryBucket.legArmor,
  InventoryBucket.classArmor,
];

bool isLoadoutClassSpecificSlot(int hash) {
  return loadoutClassSpecificBucketHashes.contains(hash);
}

LoadoutItemInfo? _addItemToLoadoutIndex(
  LoadoutItemIndex itemIndex,
  bool equipped, {
  required InventoryItemInfo? item,
  required int bucketHash,
  required DestinyClass? classType,
  required Map<int, int>? plugHashes,
  int? overridePlugHash,
}) {
  final isClassSpecificItem = [DestinyClass.Titan, DestinyClass.Hunter, DestinyClass.Warlock].contains(classType);
  final slot = itemIndex.slots[bucketHash] ??= LoadoutIndexSlot();
  final loadoutItem = LoadoutItemInfo(inventoryItem: item, itemPlugs: plugHashes);
  loadoutItem.overrideStyleItemHash = overridePlugHash;
  if (!equipped) {
    slot.unequipped.add(loadoutItem);
    return loadoutItem;
  }
  if (isClassSpecificItem) {
    if (classType == null) return null;
    slot.classSpecificEquipped[classType] = loadoutItem;
    return loadoutItem;
  }
  slot.genericEquipped = loadoutItem;
  return loadoutItem;
}

void _removeItemFromLoadoutIndex(
  LoadoutItemIndex itemIndex,
  InventoryItemInfo item, {
  required int bucketHash,
  required DestinyClass? classType,
}) {
  final slot = itemIndex.slots[bucketHash];
  if (slot == null) return;

  slot.unequipped.removeWhere((e) => item.instanceId == e.inventoryItem?.instanceId);
  slot.classSpecificEquipped.removeWhere((key, value) => item.instanceId == value.inventoryItem?.instanceId);
  if (slot.genericEquipped.inventoryItem?.instanceId == item.instanceId) {
    slot.genericEquipped = LoadoutItemInfo();
  }
}

extension LoadoutHelpers on Loadout {
  bool containsItem(String instanceId) {
    return [...equipped, ...unequipped].any((element) => element.itemInstanceId == instanceId);
  }

  Future<LoadoutItemIndex> generateIndex({required ProfileBloc profile, required ManifestService manifest}) async {
    final items = this.equipped + this.unequipped;
    final itemHashes = items.map((e) => e.itemHash).whereType<int>().toSet();
    await manifest.getDefinitions<DestinyInventoryItemDefinition>(itemHashes);
    final index = LoadoutItemIndex(this.name, loadoutId: assignedId, emblemHash: emblemHash);
    for (final item in items) {
      final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
      final bucketHash = item.bucketHash ?? def?.inventory?.bucketTypeHash;
      final classType = item.classType ?? def?.classType;
      if (bucketHash == null) continue;
      bool asEquipped = this.equipped.contains(item);
      final instanceId = item.itemInstanceId;
      final inventoryItem = profile.getItemByInstanceId(instanceId);
      final plugDefs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(
        item.socketPlugs?.values ?? <int>[],
      );
      final overridePlug = plugDefs.values.firstWhereOrNull((p) => shouldPlugOverrideStyleItemHash(p));
      _addItemToLoadoutIndex(
        index,
        asEquipped,
        item: inventoryItem,
        bucketHash: bucketHash,
        classType: classType,
        plugHashes: item.socketPlugs,
        overridePlugHash: overridePlug?.hash,
      );
    }
    return index;
  }
}

enum LoadoutChangeResultsCause { BlockingExotic }

class LoadoutChangeResults {
  final List<LoadoutItemInfo>? removedItems;
  final LoadoutItemInfo? addedItem;
  final LoadoutChangeResultsCause? cause;

  LoadoutChangeResults({this.removedItems, this.addedItem, this.cause});
}

extension LoadoutIndexHelpers on LoadoutItemIndex {
  Future<LoadoutChangeResults?> addItem(
    ManifestService manifest,
    InventoryItemInfo? item, {
    bool equipped = false,
    bool includeMods = false,
  }) async {
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(item?.itemHash);
    final bucketHash = def?.inventory?.bucketTypeHash;
    final classType = [
      DestinyClass.Titan,
      DestinyClass.Hunter,
      DestinyClass.Warlock,
    ].firstWhereOrNull((element) => element == def?.classType);
    if (bucketHash == null) return null;
    final instanceId = item?.instanceId;
    if (instanceId == null) return null;
    if (this.containsItem(instanceId)) {
      await this.removeItem(manifest, item);
    }

    Map<int, int> plugHashes = {};
    if (includeMods && item != null) {
      final sockets = item.sockets ?? [];
      for (int i = 0; i < sockets.length; i++) {
        final plugHash = sockets[i].plugHash;
        final canApply = await isPlugAvailableToApplyForFreeViaApi(manifest, item, i, plugHash);
        if (canApply && plugHash != null) plugHashes[i] = plugHash;
      }
    }

    final added = _addItemToLoadoutIndex(
      this,
      equipped,
      item: item,
      bucketHash: bucketHash,
      classType: def?.classType,
      plugHashes: plugHashes,
    );
    final equippingBlockLabel = def?.equippingBlock?.uniqueLabel;
    if (equipped && equippingBlockLabel != null) {
      final competingItems =
          slots.values
              .map((value) => classType == null ? value.genericEquipped : value.classSpecificEquipped[classType])
              .whereType<LoadoutItemInfo>();
      final hashes = competingItems.map((e) => e.inventoryItem?.itemHash);
      final definitions = await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes);
      final blockingHashes =
          definitions.values
              .where((d) => d.equippingBlock?.uniqueLabel == equippingBlockLabel)
              .map((d) => d.hash)
              .whereType<int>();
      final blockingItems =
          competingItems
              .where(
                (i) =>
                    i.inventoryItem?.itemHash != added?.inventoryItem?.itemHash &&
                    blockingHashes.contains(i.inventoryItem?.itemHash),
              )
              .toList();
      if (blockingItems.isNotEmpty) {
        for (final blocking in blockingItems) await removeItem(manifest, blocking.inventoryItem);
        return LoadoutChangeResults(
          addedItem: added,
          removedItems: blockingItems,
          cause: LoadoutChangeResultsCause.BlockingExotic,
        );
      }
    }
    return LoadoutChangeResults(addedItem: added);
  }

  Future<LoadoutChangeResults?> removeItem(ManifestService manifest, InventoryItemInfo? item) async {
    if (item == null) return null;
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
    final bucketHash = def?.inventory?.bucketTypeHash;
    if (bucketHash == null) return null;
    final removed = _removeItemFromLoadoutIndex(this, item, bucketHash: bucketHash, classType: def?.classType);
    return LoadoutChangeResults(removedItems: [removed].whereType<LoadoutItemInfo>().toList());
  }

  bool containsItem(String itemInstanceID) {
    return slots.values.any((s) {
      bool contains = s.genericEquipped.inventoryItem?.instanceId == itemInstanceID;
      if (contains) return true;

      contains = s.classSpecificEquipped.values.any((i) => i.instanceId == itemInstanceID);
      if (contains) return true;

      contains = s.unequipped.any((i) => i.instanceId == itemInstanceID);
      if (contains) return true;

      return false;
    });
  }

  Loadout toLoadout() {
    final id = this.loadoutId ?? Uuid().v4();
    final name = this.name;
    final emblemHash = this.emblemHash;
    final equippedItems = <LoadoutItem>[];
    final unequippedItems = <LoadoutItem>[];
    for (final slot in this.slots.entries) {
      final bucketHash = slot.key;
      final classEquipped = slot.value.classSpecificEquipped.entries.map(
        (entry) => LoadoutItem(
          bucketHash: bucketHash,
          itemHash: entry.value.itemHash,
          itemInstanceId: entry.value.instanceId,
          classType: entry.key,
          socketPlugs: entry.value.itemPlugs,
        ),
      );
      bool hasGenericEquipped =
          slot.value.genericEquipped.itemHash != null || slot.value.genericEquipped.itemPlugs.isNotEmpty;
      final genericEquipped =
          hasGenericEquipped
              ? LoadoutItem(
                bucketHash: bucketHash,
                itemHash: slot.value.genericEquipped.itemHash,
                itemInstanceId: slot.value.genericEquipped.instanceId,
                socketPlugs: slot.value.genericEquipped.itemPlugs,
              )
              : null;
      final unequipped = slot.value.unequipped.map(
        (item) => LoadoutItem(
          bucketHash: bucketHash,
          itemHash: item.itemHash,
          itemInstanceId: item.instanceId,
          socketPlugs: item.itemPlugs,
        ),
      );
      equippedItems.addAll([...classEquipped, if (genericEquipped != null) genericEquipped]);

      unequippedItems.addAll(unequipped);
    }
    final loadout = Loadout(
      assignedId: id,
      name: name,
      emblemHash: emblemHash,
      updatedAt: DateTime.now(),
      equipped: equippedItems,
      unequipped: unequippedItems,
    );
    return loadout;
  }

  List<LoadoutItemInfo> getEquippedItems(DestinyClass? classType) {
    return InventoryBucket.loadoutBucketHashes
        .map((bucketHash) {
          final slot = this.slots[bucketHash];
          if (slot == null) return [];
          if (classType == null) {
            return [...slot.classSpecificEquipped.values, slot.genericEquipped];
          }
          return [slot.classSpecificEquipped[classType], slot.genericEquipped];
        })
        .fold<List<LoadoutItemInfo?>>([], (previousValue, element) => [...previousValue, ...element])
        .whereType<LoadoutItemInfo>()
        .toList();
  }

  List<LoadoutItemInfo> getNonEquippedItems() {
    return InventoryBucket.loadoutBucketHashes
        .map((bucketHash) {
          final slot = this.slots[bucketHash];
          if (slot == null) return [];
          return slot.unequipped;
        })
        .fold<List<LoadoutItemInfo?>>([], (previousValue, element) => [...previousValue, ...element])
        .whereType<LoadoutItemInfo>()
        .toList();
  }

  Future<LoadoutItemIndex> duplicateWithFilters(
    ManifestService manifest, {
    DestinyClass? classFilter,
    List<int>? bucketFilter,
    bool includeMods = false,
  }) async {
    final result = LoadoutItemIndex(name, emblemHash: emblemHash);
    final equipped = this.getEquippedItems(classFilter);
    final nonEquipped = this.getNonEquippedItems();
    for (final e in equipped) {
      if (e.inventoryItem == null) continue;
      final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(e.itemHash);

      final bucketHash = def?.inventory?.bucketTypeHash;
      final classType = def?.classType;

      if (bucketHash == null || classType == null) continue;

      if (classFilter != null) {
        if (classType != classFilter && classType != DestinyClass.Unknown) continue;
      }

      if (bucketFilter != null) {
        if (!bucketFilter.contains(bucketHash)) continue;
      }

      final plugs = includeMods ? e.itemPlugs : null;

      await _addItemToLoadoutIndex(
        result,
        true,
        item: e.inventoryItem,
        bucketHash: bucketHash,
        classType: classType,
        plugHashes: plugs,
      );
    }
    for (final e in nonEquipped) {
      if (e.inventoryItem == null) continue;
      final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(e.itemHash);
      final bucketHash = def?.inventory?.bucketTypeHash;
      final classType = def?.classType;

      if (bucketHash == null || classType == null) continue;

      if (classFilter != null) {
        if (classType != classFilter && classType != DestinyClass.Unknown) continue;
      }

      if (bucketFilter != null) {
        if (!bucketFilter.contains(bucketHash)) continue;
      }

      final plugs = includeMods ? e.itemPlugs : null;

      await _addItemToLoadoutIndex(
        result,
        false,
        item: e.inventoryItem,
        bucketHash: bucketHash,
        classType: classType,
        plugHashes: plugs,
      );
    }
    return result;
  }
}
