import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/shared/utils/helpers/plug_helpers.dart';

import 'item_info/inventory_item_info.dart';

class DestinyLoadoutItemInfo extends DestinyItemInfo {
  InventoryItemInfo _originalItem;
  int? overrideStyleItemHash;
  List<DestinyItemSocketState>? sockets;

  DestinyLoadoutItemInfo._(
    this._originalItem, {
    this.overrideStyleItemHash,
    this.sockets,
  });

  @override
  int? get bucketHash => _originalItem.bucketHash;

  @override
  DamageType? get damageType => _originalItem.damageType;

  @override
  int? get damageTypeHash => _originalItem.damageTypeHash;

  @override
  int? get energyCapacity => _originalItem.energyCapacity;

  @override
  String? get expirationDate => _originalItem.expirationDate;

  @override
  String? get instanceId => _originalItem.instanceId;

  @override
  bool? get isEquipped => _originalItem.isEquipped;

  @override
  int? get itemHash => _originalItem.itemHash;

  @override
  int? get itemLevel => _originalItem.itemLevel;

  @override
  ItemLocation? get location => _originalItem.location;

  @override
  bool? get lockable => _originalItem.lockable;

  @override
  int? get primaryStatValue => _originalItem.primaryStatValue;

  @override
  int? get quality => _originalItem.quality;

  @override
  int get quantity => _originalItem.quantity;

  @override
  ItemState? get state => _originalItem.state;

  @override
  List<int>? get tooltipNotificationIndexes => _originalItem.tooltipNotificationIndexes;

  @override
  int? get versionNumber => _originalItem.versionNumber;

  static Future<DestinyLoadoutItemInfo> fromInventoryItem(
    ManifestService manifest,
    InventoryItemInfo item,
    DestinyLoadoutItemComponent loadoutItem,
  ) async {
    List<DestinyItemSocketState>? sockets;
    int? overrideStyleItemHash;
    final plugItemHashes = loadoutItem.plugItemHashes;
    if (plugItemHashes != null && plugItemHashes.isNotEmpty) {
      final plugDefs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(plugItemHashes);
      final overrideStyleItem = plugDefs.values.firstWhereOrNull((def) => shouldPlugOverrideStyleItemHash(def));
      overrideStyleItemHash = overrideStyleItem?.hash;
      sockets = plugItemHashes.map((i) => DestinyItemSocketState()..plugHash = i).toList();
    }
    return DestinyLoadoutItemInfo._(item, overrideStyleItemHash: overrideStyleItemHash, sockets: sockets);
  }
}

class DestinyLoadoutInfo {
  final String characterId;
  final int index;
  final DestinyLoadoutComponent loadout;
  final Map<int, DestinyLoadoutItemInfo>? items;

  DestinyLoadoutInfo({
    required this.characterId,
    required this.index,
    required this.loadout,
    required this.items,
  });

  static Future<DestinyLoadoutInfo> fromInventory(
    ProfileBloc profile,
    ManifestService manifest,
    DestinyLoadoutComponent loadout,
    String characterId,
    int index,
  ) async {
    final items = await _mapLoadoutItems(profile, manifest, loadout);
    final loadoutInfo = DestinyLoadoutInfo(
      items: items,
      index: index,
      loadout: loadout,
      characterId: characterId,
    );
    return loadoutInfo;
  }

  static Future<DestinyLoadoutInfo> fromEquippedItems({
    required ProfileBloc profile,
    required ManifestService manifest,
    required String characterId,
    required int? nameHash,
    required int? iconHash,
    required int? colorHash,
    required int loadoutIndex,
  }) async {
    final validBucketHashes = [
      InventoryBucket.subclass,
      ...InventoryBucket.weaponBucketHashes,
      ...InventoryBucket.armorBucketHashes,
    ];
    final equipped = profile.allInstancedItems.where((i) {
      final isEquipped = i.isEquipped ?? false;
      if (!isEquipped) return false;
      if (i.characterId != characterId) return false;
      if (!validBucketHashes.contains(i.bucketHash)) return false;
      return true;
    });

    final constants = await manifest.getDefinition<DestinyLoadoutConstantsDefinition>(1);

    final items = <DestinyLoadoutItemComponent>[];

    for (final e in equipped) {
      final sockets = e.sockets ?? <DestinyItemSocketState>[];
      final plugHashes = <int>[];
      final itemDef = await manifest.getDefinition<DestinyInventoryItemDefinition>(e.itemHash);
      final socketCategories = itemDef?.sockets?.socketCategories ?? [];
      final invalidCategoryHashes = constants?.loadoutPreviewFilterOutSocketCategoryHashes;
      final invalidTypeHashes = constants?.loadoutPreviewFilterOutSocketTypeHashes;
      final validCategories = socketCategories.where((element) {
        final categoryHash = element.socketCategoryHash;
        final filterOutCategoryHash = invalidCategoryHashes?.contains(categoryHash) ?? false;
        return !filterOutCategoryHash;
      });
      final socketIndexes = [
        for (final c in validCategories) ...(c.socketIndexes ?? <int>[]),
      ];
      for (final (i, s) in sockets.indexed) {
        final plugHash = s.plugHash;
        final isInAcceptedCategory = socketIndexes.contains(i);
        final socketDef = itemDef?.sockets?.socketEntries?[i];
        final socketTypeHash = socketDef?.socketTypeHash;
        final plugDef = await manifest.definition<DestinyInventoryItemDefinition>(plugHash);
        final plugId = plugDef?.plug?.plugCategoryIdentifier;
        final invalidPlugId = ["intrinsic", "catalyst", "masterwork"].any((id) => plugId?.contains(id) ?? false);
        final isAcceptedType = !(invalidTypeHashes?.contains(socketTypeHash) ?? false);
        final visible = socketDef?.defaultVisible ?? false;
        final available = visible && isInAcceptedCategory && isAcceptedType && !invalidPlugId;

        plugHashes.add(plugHash != null && available ? plugHash : 0);
      }
      final loadoutItem = DestinyLoadoutItemComponent()
        ..itemInstanceId = e.instanceId
        ..plugItemHashes = plugHashes;
      items.add(loadoutItem);
    }

    final newLoadout = DestinyLoadoutComponent()
      ..nameHash = nameHash
      ..iconHash = iconHash
      ..colorHash = colorHash
      ..items = items;
    final newLoadoutInfo = await fromInventory(profile, manifest, newLoadout, characterId, loadoutIndex);
    return newLoadoutInfo;
  }
}

Future<Map<int, DestinyLoadoutItemInfo>?> _mapLoadoutItems(
  ProfileBloc profile,
  ManifestService manifest,
  DestinyLoadoutComponent loadout,
) async {
  final loadoutItems = loadout.items;
  if (loadoutItems == null) return null;
  if (loadoutItems.isEmpty) return null;
  final Map<int, DestinyLoadoutItemInfo> items = {};
  for (final loadoutItem in loadoutItems) {
    final instanceId = loadoutItem.itemInstanceId;
    if (instanceId == null) continue;
    final item = profile.getItemByInstanceId(instanceId);
    if (item == null) continue;
    final definition = await manifest.getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
    final bucketHash = definition?.inventory?.bucketTypeHash;
    if (bucketHash == null) continue;
    items[bucketHash] = await DestinyLoadoutItemInfo.fromInventoryItem(manifest, item, loadoutItem);
  }
  return items;
}
