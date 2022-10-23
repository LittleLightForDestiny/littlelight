import 'package:bungie_api/destiny2.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:uuid/uuid.dart';

const _genericBucketHashes = [
  InventoryBucket.kineticWeapons,
  InventoryBucket.energyWeapons,
  InventoryBucket.powerWeapons,
  InventoryBucket.ghost,
  InventoryBucket.vehicle,
  InventoryBucket.ships,
];
const _classBucketHashes = [
  InventoryBucket.subclass,
  InventoryBucket.helmet,
  InventoryBucket.gauntlets,
  InventoryBucket.chestArmor,
  InventoryBucket.legArmor,
  InventoryBucket.classArmor
];

class LoadoutIndexItem {
  DestinyItemComponent? item;
  Map<int, int> itemPlugs;

  LoadoutIndexItem({
    this.item,
    Map<int, int>? itemPlugs,
  }) : this.itemPlugs = itemPlugs ?? {};

  LoadoutIndexItem clone() {
    final result = LoadoutIndexItem();
    result.item = this.item;
    result.itemPlugs = Map<int, int>.from(this.itemPlugs);
    return result;
  }
}

class LoadoutIndexSlot {
  LoadoutIndexItem genericEquipped = LoadoutIndexItem();
  Map<DestinyClass, LoadoutIndexItem> classSpecificEquipped = {};
  List<LoadoutIndexItem> unequipped = [];

  LoadoutIndexSlot();

  LoadoutIndexSlot clone() {
    final result = LoadoutIndexSlot();
    result.genericEquipped = this.genericEquipped.clone();
    result.classSpecificEquipped = this.classSpecificEquipped.map((key, value) => MapEntry(key, value.clone()));
    result.unequipped = this.unequipped.map((e) => e.clone()).toList();
    return result;
  }
}

class LoadoutItemIndex with ProfileConsumer, ManifestConsumer {
  String assignedId;
  String name;
  int? emblemHash;
  DateTime? updatedAt;

  Map<int, LoadoutIndexSlot> slots = Map.fromIterable(
    _genericBucketHashes + _classBucketHashes,
    key: (e) => e,
    value: (_) => LoadoutIndexSlot(),
  );

  LoadoutItemIndex._({
    required this.assignedId,
    required this.name,
    required this.emblemHash,
    this.updatedAt,
  });

  factory LoadoutItemIndex.fromScratch() {
    final assignedId = Uuid().v4();
    return LoadoutItemIndex._(assignedId: assignedId, name: "", emblemHash: null);
  }

  factory LoadoutItemIndex.duplicate(LoadoutItemIndex original) {
    final clone = original.clone();
    clone.assignedId = Uuid().v4();
    return clone;
  }

  static Future<LoadoutItemIndex> buildfromLoadout(Loadout loadout) async {
    final id = loadout.assignedId ?? Uuid().v4();
    final loadoutIndex = LoadoutItemIndex._(
      assignedId: id,
      name: loadout.name,
      emblemHash: loadout.emblemHash,
      updatedAt: loadout.updatedAt,
    );
    await loadoutIndex._buildIndex(loadout);
    return loadoutIndex;
  }

  Future<void> _buildIndex(Loadout loadout) async {
    final items = loadout.equipped + loadout.unequipped;
    final itemIds = items.map((e) => e.itemInstanceId).whereType<String>().toList();
    final itemHashes = items.map((e) => e.itemHash).whereType<int>().toSet();
    Map<String, DestinyItemComponent> inventoryItems = Map.fromEntries(
      profile.getItemsByInstanceId(itemIds).map(
            (i) => MapEntry(i.itemInstanceId!, i),
          ),
    );
    await manifest.getDefinitions<DestinyInventoryItemDefinition>(itemHashes);
    for (final item in loadout.equipped) {
      final inventoryItem = inventoryItems[item.itemInstanceId];
      if (inventoryItem != null) {
        await _addItemToLoadoutIndex(inventoryItem, true, plugHashes: item.socketPlugs);
      }
    }
    for (final item in loadout.unequipped) {
      final inventoryItem = inventoryItems[item.itemInstanceId];
      if (inventoryItem != null) {
        await _addItemToLoadoutIndex(inventoryItem, false, plugHashes: item.socketPlugs);
      }
    }
  }

  List<LoadoutIndexItem> get equippedItems => slots.values
      .map((value) => [value.genericEquipped] + value.classSpecificEquipped.values.toList())
      .fold<List<LoadoutIndexItem>>(<LoadoutIndexItem>[], (previousValue, element) => previousValue + element)
      .whereType<LoadoutIndexItem>()
      .toList();

  List<String> get equippedItemIds => equippedItems //
      .map((item) => item.item?.itemInstanceId)
      .whereType<String>()
      .toList();

  List<LoadoutIndexItem> get unequippedItems => slots.values
      .map((value) => value.unequipped)
      .fold<List<LoadoutIndexItem>>(<LoadoutIndexItem>[], (previousValue, element) => previousValue + element)
      .whereType<LoadoutIndexItem>()
      .toList();

  List<String> get unequippedItemIds => unequippedItems //
      .map((item) => item.item?.itemInstanceId)
      .whereType<String>()
      .toList();

  int get unequippedItemCount => slots.values.fold<int>(0, (t, e) => t + e.unequipped.length);

  static List<int> get genericBucketHashes => _genericBucketHashes;
  static List<int> get classSpecificBucketHashes => _classBucketHashes;

  bool containsItem(String itemInstanceID) {
    return slots.values.any((s) {
      bool contains = s.genericEquipped.item?.itemInstanceId == itemInstanceID;
      if (contains) return true;

      contains = s.classSpecificEquipped.values.contains(itemInstanceID);
      if (contains) return true;

      contains = s.unequipped.contains(itemInstanceID);
      if (contains) return true;

      return false;
    });
  }

  static bool isClassSpecificSlot(int hash) {
    return _classBucketHashes.contains(hash);
  }

  Future<LoadoutIndexItem?> _addItemToLoadoutIndex(
    DestinyItemComponent item,
    bool equipped, {
    Map<int, int>? plugHashes,
  }) async {
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
    if (def == null) return null;
    final isClassSpecificItem = [DestinyClass.Titan, DestinyClass.Hunter, DestinyClass.Warlock].contains(def.classType);
    final bucketTypeHash = def.inventory?.bucketTypeHash;
    if (bucketTypeHash == null) return null;
    final slot = slots[bucketTypeHash];
    if (slot == null) return null;
    final loadoutItem = LoadoutIndexItem(item: item, itemPlugs: plugHashes);
    if (!equipped) {
      slot.unequipped.add(loadoutItem);
      return loadoutItem;
    }
    if (isClassSpecificItem) {
      final classType = def.classType;
      if (classType == null) return null;
      slot.classSpecificEquipped[classType] = loadoutItem;
      return loadoutItem;
    }
    slot.genericEquipped = loadoutItem;
    return loadoutItem;
  }

  Future<void> _removeItemFromLoadoutIndex(DestinyItemComponent item, bool equipped) async {
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
    if (def == null) return;
    final bucketTypeHash = def.inventory?.bucketTypeHash;
    if (bucketTypeHash == null) return;
    final slot = slots[bucketTypeHash];
    if (slot == null) return;
    if (!equipped) {
      slot.unequipped.removeWhere((e) => item.itemInstanceId == e.item?.itemInstanceId);
      return;
    }
    slot.classSpecificEquipped.removeWhere((key, value) => item.itemInstanceId == value.item?.itemInstanceId);
    if (slot.genericEquipped.item?.itemInstanceId == item.itemInstanceId) {
      slot.genericEquipped.item = null;
      slot.genericEquipped.itemPlugs = {};
    }
  }

  Future<void> addItem(DestinyItemComponent item, bool equipped) async {
    await _addItemToLoadoutIndex(item, equipped);
  }

  Future<void> addEquippedItem(DestinyItemComponent item) async {
    await _addItemToLoadoutIndex(item, true);
  }

  Future<void> addUnequippedItem(DestinyItemComponent item) async {
    await _addItemToLoadoutIndex(item, false);
  }

  Future<void> removeEquippedItem(DestinyItemComponent item) async {
    await _removeItemFromLoadoutIndex(item, true);
  }

  Future<void> removeUnequippedItem(DestinyItemComponent item) async {
    await _removeItemFromLoadoutIndex(item, false);
  }

  bool haveEquippedItem(DestinyInventoryItemDefinition def) {
    return slots.values.any((slot) {
      var equipped = slot.genericEquipped.item?.itemHash == def.hash;
      if (equipped) return true;
      return slot.classSpecificEquipped.values.any((item) => item.item?.itemHash == def.hash);
    });
  }

  Loadout toLoadout() {
    final equipped = equippedItems
        .map((i) =>
            LoadoutItem(itemHash: i.item?.itemHash, itemInstanceId: i.item?.itemInstanceId, socketPlugs: i.itemPlugs))
        .toList();
    final unequipped = unequippedItems
        .map((i) =>
            LoadoutItem(itemHash: i.item?.itemHash, itemInstanceId: i.item?.itemInstanceId, socketPlugs: i.itemPlugs))
        .toList();
    return Loadout(
      assignedId: this.assignedId,
      emblemHash: this.emblemHash,
      name: name,
      equipped: equipped,
      unequipped: unequipped,
      updatedAt: updatedAt,
    );
  }

  LoadoutItemIndex clone() {
    final result = LoadoutItemIndex._(
      assignedId: this.assignedId,
      emblemHash: this.emblemHash,
      name: this.name,
    );
    result.slots = this.slots.map((key, value) => MapEntry(key, value.clone()));
    return result;
  }
}
