import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/inventory_item_data.dart';
import 'package:provider/provider.dart';

class SelectionBloc extends ChangeNotifier with ManifestConsumer {
  final ProfileBloc _profile;

  factory SelectionBloc(BuildContext context) => SelectionBloc._(context.read<ProfileBloc>());

  SelectionBloc._(this._profile) {
    this._profile.addListener(_internalUpdate);
  }

  @override
  dispose() {
    this._profile.removeListener(_internalUpdate);
    super.dispose();
  }

  Map<int, Set<String?>> _selectionMap = {};
  List<DestinyItemInfo> _selectedItems = [];
  List<DestinyCharacterInfo?> _transferDestinations = [];
  List<DestinyCharacterInfo> _equipDestinations = [];

  void selectItem(int hash, String? instanceId) {
    final instances = _selectionMap[hash] ??= Set();
    instances.add(instanceId);
    _internalUpdate();
  }

  void unselectItem(int hash, String? instanceId) {
    _selectionMap[hash]?.remove(instanceId);
    _internalUpdate();
  }

  void clear() {
    _selectionMap = {};
    _internalUpdate();
  }

  void _internalUpdate() async {
    _updateSelectedItems();
    await _updateTransferDestinations();
    notifyListeners();
  }

  void _updateSelectedItems() {
    this._selectedItems = _selectionMap.entries.map((entry) {
      final hash = entry.key;
      final instanceIds = entry.value;
      return instanceIds
          .map((id) {
            if (id != null) {
              return _profile.getItemByInstanceId(id);
            }
            return _profile.getItemsByHash(hash).firstOrNull;
          })
          .whereType<DestinyItemInfo>()
          .toList();
    }).fold<List<DestinyItemInfo>>(
      <DestinyItemInfo>[],
      (value, element) => value + element,
    ).toList();
  }

  Future<void> _updateTransferDestinations() async {
    final characters = _profile.characters;
    bool canTransferToVault = false;
    final transferDestinations = <DestinyCharacterInfo?>[];
    final equipDestinations = <DestinyCharacterInfo>[];
    final items = _selectedItems.fold<List<DestinyItemInfo>>([], (previousValue, element) {
      if (element.item.itemInstanceId != null) {
        return previousValue + [element];
      }
      return previousValue + (element.duplicates ?? [element]);
    });
    if (characters == null) return;
    for (final char in characters) {
      bool canTransfer = false;
      bool canEquip = false;
      for (final item in items) {
        final hash = item.item.itemHash;
        final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
        if (def == null) continue;
        final bucketDef = await manifest.getDefinition<DestinyInventoryBucketDefinition>(def.inventory?.bucketTypeHash);
        bool isOnVault = item.item.bucketHash == InventoryBucket.general;
        canTransferToVault |= item.canTransfer(null, def) && !isOnVault;

        if (bucketDef?.scope == BucketScope.Account) {
          canTransfer |= isOnVault && item.canTransfer(char, def);
          continue;
        }
        canTransfer |= item.canTransfer(char, def);
        canEquip |= item.canEquip(char, def);
        if (canTransfer && canEquip) break;
      }
      if (canTransfer) transferDestinations.add(char);
      if (canEquip) equipDestinations.add(char);
    }

    if (canTransferToVault) {
      transferDestinations.add(null);
    }

    this._transferDestinations = transferDestinations;
    this._equipDestinations = equipDestinations;
  }

  bool isSelected(int hash, String? instanceId) {
    return _selectionMap[hash]?.contains(instanceId) ?? false;
  }

  bool get hasSelection => _selectedItems.length > 0;
  List<DestinyItemInfo> get selectedItems => _selectedItems;
  List<DestinyCharacterInfo?> get transferDestinations => _transferDestinations;
  List<DestinyCharacterInfo> get equipDestinations => _equipDestinations;
}
