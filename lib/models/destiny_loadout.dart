import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
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
