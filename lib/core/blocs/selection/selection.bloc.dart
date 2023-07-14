import 'package:flutter/material.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/models/transfer_destination.dart';
import 'package:little_light/shared/utils/helpers/get_transfer_destinations.dart';
import 'package:provider/provider.dart';

class _SelectedItemIdentifier {
  int itemHash;
  String? instanceId;
  int? stackIndex;

  _SelectedItemIdentifier(this.itemHash, {this.instanceId, this.stackIndex});

  String get id {
    if (instanceId != null) {
      return "$itemHash-$instanceId";
    }
    if (stackIndex != null) {
      return "$itemHash-$stackIndex";
    }
    return "$itemHash";
  }

  @override
  bool operator ==(Object other) =>
      other is _SelectedItemIdentifier && other.runtimeType == runtimeType && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class SelectionBloc extends ChangeNotifier with ManifestConsumer {
  final ProfileBloc _profile;
  final BuildContext _context;

  factory SelectionBloc(BuildContext context) => SelectionBloc._(context, context.read<ProfileBloc>());

  SelectionBloc._(this._context, this._profile) {
    _profile.addListener(_internalUpdate);
  }

  @override
  dispose() {
    _profile.removeListener(_internalUpdate);
    super.dispose();
  }

  List<_SelectedItemIdentifier> _selectedIdentifers = [];
  List<InventoryItemInfo> _selectedItems = [];
  List<TransferDestination> _transferDestinations = [];
  List<TransferDestination> _equipDestinations = [];

  void selectItem(int hash, {String? instanceId, int? stackIndex}) {
    if (isSelected(hash, instanceId: instanceId, stackIndex: stackIndex)) return;
    final id = _SelectedItemIdentifier(hash, instanceId: instanceId, stackIndex: stackIndex);
    _selectedIdentifers.add(id);
    _internalUpdate();
  }

  void selectItems(List<DestinyItemInfo> items) {
    final identifiers = items.map((item) {
      final hash = item.itemHash;
      if (hash == null) return null;
      if (isSelected(hash, instanceId: item.instanceId, stackIndex: item.stackIndex)) return null;
      return _SelectedItemIdentifier(hash, instanceId: item.instanceId, stackIndex: item.stackIndex);
    }).whereType<_SelectedItemIdentifier>();
    _selectedIdentifers.addAll(identifiers);
    _internalUpdate();
  }

  void unselectItems(List<DestinyItemInfo> items) {
    for (final i in items) {
      _selectedIdentifers.removeWhere((element) =>
          element.instanceId == i.instanceId && element.stackIndex == i.stackIndex && element.itemHash == i.itemHash);
    }
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
          final items = _profile.getItemsByHash(id.itemHash);
          if (items.length > stackIndex) {
            return items[stackIndex];
          }
          return null;
        })
        .whereType<InventoryItemInfo>()
        .toList();
  }

  Future<void> _updateTransferDestinations() async {
    final characters = _profile.characters;
    final items = _selectedItems;
    final destinations = await getTransferDestinations(_context, characters, items);
    _transferDestinations = destinations?.transfer ?? [];
    _equipDestinations = destinations?.equip ?? [];
  }

  bool isSelected(int hash, {String? instanceId, int? stackIndex}) {
    final id = _SelectedItemIdentifier(hash, instanceId: instanceId, stackIndex: stackIndex);
    return _selectedIdentifers.contains(id);
  }

  bool isItemSelected(DestinyItemInfo item) {
    final hash = item.itemHash;
    if (hash == null) return false;
    final id = _SelectedItemIdentifier(hash, instanceId: item.instanceId, stackIndex: item.stackIndex);
    return _selectedIdentifers.contains(id);
  }

  bool get hasSelection => _selectedItems.isNotEmpty;
  List<InventoryItemInfo> get selectedItems => _selectedItems;
  List<TransferDestination> get transferDestinations => _transferDestinations;
  List<TransferDestination> get equipDestinations => _equipDestinations;
}
