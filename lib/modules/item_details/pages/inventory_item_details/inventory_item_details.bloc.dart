import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/modules/item_details/blocs/socket_controller.bloc.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:little_light/shared/models/transfer_destination.dart';
import 'package:little_light/shared/utils/helpers/get_transfer_destinations.dart';
import 'package:provider/provider.dart';

class InventoryItemDetailsBloc extends ChangeNotifier {
  final ProfileBloc _profileBloc;
  final InventoryBloc _inventoryBloc;
  final SocketControllerBloc _socketControllerBloc;
  DestinyItemInfo? item;
  List<LoadoutItemIndex>? loadouts;
  final BuildContext _context;
  bool _lockBusy = false;

  List<TransferDestination>? _transferDestinations;

  List<TransferDestination>? get transferDestinations => _transferDestinations;
  List<TransferDestination>? _equipDestinations;
  List<TransferDestination>? get equipDestinations => _equipDestinations;

  InventoryItemDetailsBloc(this._context, {this.item})
      : _profileBloc = _context.read<ProfileBloc>(),
        _inventoryBloc = _context.read<InventoryBloc>(),
        _socketControllerBloc = _context.read<SocketControllerBloc>() {
    _init();
  }
  _init() {
    _profileBloc.addListener(_updateItem);
    _socketControllerBloc.init(this.item);
    _updateItem();
  }

  @override
  void dispose() {
    _profileBloc.removeListener(_updateItem);
    super.dispose();
  }

  int? get itemHash => item?.itemHash;
  String? get instanceId => item?.instanceId;
  int? get stackIndex => item?.stackIndex;

  void _updateItem() async {
    final allItems = _profileBloc.allItems;
    final item = allItems.firstWhereOrNull((item) =>
        item.itemHash == this.itemHash && //
        item.instanceId == this.instanceId &&
        item.stackIndex == this.stackIndex);
    if (item == null) return;

    this.item = item;
    final characters = _profileBloc.characters;
    final items = [item];
    final destinations = await getTransferDestinations(_context, characters, items);
    this._transferDestinations = destinations?.transfer;
    this._equipDestinations = destinations?.equip;

    _socketControllerBloc.update(item);
    notifyListeners();
  }

  bool? get isLocked {
    final lockable = item?.item.lockable ?? false;
    if (!lockable) return null;
    return item?.item.state?.contains(ItemState.Locked);
  }

  bool get isLockBusy => _lockBusy;

  void changeLockState(bool newState) async {
    final item = this.item;
    if (item == null) return;
    _lockBusy = true;
    notifyListeners();
    await _inventoryBloc.changeItemLockState(item, newState);
    _lockBusy = false;
    notifyListeners();
  }
}
