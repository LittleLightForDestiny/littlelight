import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:provider/provider.dart';

class InventoryItemDetailsBloc extends ChangeNotifier {
  final ProfileBloc _profileBloc;
  DestinyItemInfo? item;
  List<LoadoutItemIndex>? loadouts;

  InventoryItemDetailsBloc(BuildContext context, {this.item}) : _profileBloc = context.read<ProfileBloc>() {
    _init();
  }
  _init() {
    _profileBloc.addListener(_updateItem);
  }

  int? get itemHash => item?.itemHash;
  String? get instanceId => item?.instanceId;
  int? get stackIndex => item?.stackIndex;

  _updateItem() {
    final allItems = _profileBloc.allItems;
    final item = allItems.firstWhereOrNull((item) =>
        item.itemHash == this.itemHash && //
        item.instanceId == this.instanceId &&
        item.stackIndex == this.stackIndex);
    if (item == null) return;

    this.item = item;
    notifyListeners();
  }
}
