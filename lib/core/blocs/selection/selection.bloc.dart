import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/models/transfer_destination.dart';
import 'package:little_light/shared/utils/extensions/inventory_item_data.dart';
import 'package:provider/provider.dart';

class _SelectedItemIdentifier {
  int hash;
  String? instanceId;
  int? stackIndex;

  _SelectedItemIdentifier(this.hash, {this.instanceId, this.stackIndex});

  String get id {
    if (instanceId != null) {
      return "$hash-$instanceId";
    }
    if (stackIndex != null) {
      return "$hash-$stackIndex";
    }
    return "$hash";
  }

  @override
  bool operator ==(Object other) =>
      other is _SelectedItemIdentifier && other.runtimeType == runtimeType && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class SelectionBloc extends ChangeNotifier with ManifestConsumer {
  final ProfileBloc _profile;

  factory SelectionBloc(BuildContext context) => SelectionBloc._(context.read<ProfileBloc>());

  SelectionBloc._(this._profile) {
    _profile.addListener(_internalUpdate);
  }

  @override
  dispose() {
    _profile.removeListener(_internalUpdate);
    super.dispose();
  }

  List<_SelectedItemIdentifier> _selectedIdentifers = [];
  List<DestinyItemInfo> _selectedItems = [];
  List<TransferDestination> _transferDestinations = [];
  List<TransferDestination> _equipDestinations = [];

  void selectItem(int hash, {String? instanceId, int? stackIndex}) {
    if (isSelected(hash, instanceId: instanceId, stackIndex: stackIndex)) return;
    final id = _SelectedItemIdentifier(hash, instanceId: instanceId, stackIndex: stackIndex);
    _selectedIdentifers.add(id);
    _internalUpdate();
  }

  void unselectItem(int hash, {String? instanceId, int? stackIndex}) {
    final id = _SelectedItemIdentifier(hash, instanceId: instanceId, stackIndex: stackIndex);
    _selectedIdentifers.remove(id);
    _internalUpdate();
  }

  void toggleSelected(int hash, {String? instanceId, int? stackIndex}) {
    final isSelected = this.isSelected(hash, instanceId: instanceId, stackIndex: stackIndex);
    if (isSelected) {
      unselectItem(hash, instanceId: instanceId, stackIndex: stackIndex);
      return;
    }
    selectItem(hash, instanceId: instanceId, stackIndex: stackIndex);
  }

  void clear() {
    _selectedIdentifers = [];
    _internalUpdate();
  }

  void _internalUpdate() async {
    _updateSelectedItems();
    await _updateTransferDestinations();
    notifyListeners();
  }

  void _updateSelectedItems() {
    _selectedItems = _selectedIdentifers
        .map((id) {
          final instanceId = id.instanceId;
          final stackIndex = id.stackIndex ?? 0;
          if (instanceId != null) return _profile.getItemByInstanceId(instanceId);
          final items = _profile.getItemsByHash(id.hash);
          if (items.length > stackIndex) {
            return items[stackIndex];
          }
          return null;
        })
        .whereType<DestinyItemInfo>()
        .toList();
  }

  Future<void> _updateTransferDestinations() async {
    final characters = _profile.characters;
    bool canTransferToVault = false;
    bool areAllItemsProfileScoped = true;
    bool canTransferToProfile = false;
    final transferCharacters = <DestinyCharacterInfo>[];
    final equipCharacters = <DestinyCharacterInfo>[];
    final items = _selectedItems;
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
        bool isOnPostmaster = item.item.bucketHash == InventoryBucket.lostItems;

        canTransferToProfile |= isOnVault || isOnPostmaster;
        canTransferToVault |= item.canTransfer(null, def) && !isOnVault;

        if (bucketDef?.scope == BucketScope.Account) {
          canTransfer |= isOnVault && item.canTransfer(char, def);
          continue;
        }
        areAllItemsProfileScoped = false;
        canTransfer |= item.canTransfer(char, def);
        canEquip |= item.canEquip(char, def);
        if (canTransfer && canEquip) break;
      }
      if (canTransfer) transferCharacters.add(char);
      if (canEquip) equipCharacters.add(char);
    }

    final transferDestinations = <TransferDestination>[];
    final equipDestinations = <TransferDestination>[];

    if (areAllItemsProfileScoped) {
      if (canTransferToProfile) transferDestinations.add(TransferDestination(TransferDestinationType.profile));
    } else {
      transferDestinations.addAll(transferCharacters.map((c) => TransferDestination(
            TransferDestinationType.character,
            character: c,
          )));
      equipDestinations.addAll(equipCharacters.map((c) => TransferDestination(
            TransferDestinationType.character,
            character: c,
          )));
    }

    if (canTransferToVault) {
      transferDestinations.add(TransferDestination(TransferDestinationType.vault));
    }

    _transferDestinations = transferDestinations;
    _equipDestinations = equipDestinations;
  }

  bool isSelected(int hash, {String? instanceId, int? stackIndex}) {
    final id = _SelectedItemIdentifier(hash, instanceId: instanceId, stackIndex: stackIndex);
    return _selectedIdentifers.contains(id);
  }

  bool get hasSelection => _selectedItems.isNotEmpty;
  List<DestinyItemInfo> get selectedItems => _selectedItems;
  List<TransferDestination> get transferDestinations => _transferDestinations;
  List<TransferDestination> get equipDestinations => _equipDestinations;
}
