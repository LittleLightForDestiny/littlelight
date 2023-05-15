import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/modules/item_details/blocs/item_details.bloc.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_info.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/models/transfer_destination.dart';
import 'package:little_light/shared/utils/helpers/get_transfer_destinations.dart';
import 'package:little_light/shared/utils/helpers/plug_helpers.dart';
import 'package:little_light/shared/utils/helpers/wishlist_helpers.dart';
import 'package:little_light/shared/widgets/transfer_destinations/transfer_destinations.widget.dart';
import 'package:provider/provider.dart';

class LoadoutItemDetailsBloc extends ItemDetailsBloc {
  final ProfileBloc _profileBloc;
  final ItemNotesBloc _itemNotesBloc;
  final SocketControllerBloc _socketControllerBloc;
  final ManifestService _manifestBloc;
  final WishlistsService _wishlists;

  LoadoutItemInfo? _item;

  InventoryItemInfo? get inventoryItem => _item?.inventoryItem;

  List<TransferDestination>? _transferDestinations;
  List<TransferDestination>? _equipDestinations;

  MappedWishlistBuilds? _allWishlistBuilds;
  MappedWishlistBuilds? _matchedWishlistBuilds;

  MappedWishlistNotes? _allWishlistNotes;
  MappedWishlistNotes? _matchedWishlistNotes;

  bool _lockBusy = false;

  LoadoutItemDetailsBloc(BuildContext context, {LoadoutItemInfo? item})
      : _item = item,
        _profileBloc = context.read<ProfileBloc>(),
        _itemNotesBloc = context.read<ItemNotesBloc>(),
        _socketControllerBloc = context.read<SocketControllerBloc>(),
        _manifestBloc = context.read<ManifestService>(),
        _wishlists = getInjectedWishlistsService(),
        super(context) {
    _init();
  }

  _init() {
    _profileBloc.addListener(_updateItem);
    _itemNotesBloc.addListener(notifyListeners);
    _socketControllerBloc.init(this._item);
    _updateItem();
  }

  @override
  void dispose() {
    _profileBloc.removeListener(_updateItem);
    _itemNotesBloc.removeListener(notifyListeners);
    super.dispose();
  }

  void _updateItem() async {
    final allItems = _profileBloc.allItems;
    final item = allItems.firstWhereOrNull((item) =>
        item.itemHash == this.itemHash && //
        item.instanceId == this.instanceId &&
        item.stackIndex == this.stackIndex);
    if (item == null) return;

    this._item?.inventoryItem = item;
    final characters = _profileBloc.characters;
    final items = [item];
    final destinations = await getTransferDestinations(context, characters, items);
    this._transferDestinations = destinations?.transfer;
    this._equipDestinations = destinations?.equip;

    _socketControllerBloc.update(item);

    final allWishlists = _wishlists.getWishlistBuilds(itemHash: item.itemHash);
    final matchedWishlists = _wishlists.getWishlistBuilds(itemHash: item.itemHash, reusablePlugs: item.reusablePlugs);

    _allWishlistBuilds = allWishlists.isNotEmpty ? organizeWishlistBuilds(allWishlists) : null;
    _matchedWishlistBuilds = matchedWishlists.isNotEmpty ? organizeWishlistBuilds(matchedWishlists) : null;

    _allWishlistNotes = allWishlists.isNotEmpty ? organizeWishlistNotes(allWishlists) : null;
    _matchedWishlistNotes = matchedWishlists.isNotEmpty ? organizeWishlistNotes(matchedWishlists) : null;

    _updateKillTracker();

    notifyListeners();
  }

  void _updateKillTracker() async {
    final plugHashes = this.item?.sockets?.map((s) => s.plugHash);
    if (plugHashes == null) return;
    final defs = await _manifestBloc.getDefinitions<DestinyInventoryItemDefinition>(plugHashes);
    final trackerDef = defs.values.firstWhereOrNull((def) => isTrackerPlug(context, def));
    final objective = this.item?.plugObjectives?["${trackerDef?.hash}"]?.firstOrNull;
    _killTracker = objective;
    notifyListeners();
  }

  @override
  int? get itemHash => _item?.itemHash;

  @protected
  String? get instanceId => inventoryItem?.instanceId;

  @protected
  int? get stackIndex => _item?.stackIndex;

  @override
  int? get styleHash => _item?.overrideStyleItemHash ?? itemHash;

  @override
  List<TransferDestination>? get transferDestinations => _transferDestinations;

  @override
  List<TransferDestination>? get equipDestinations => _equipDestinations;

  @override
  String? get customName {
    final hash = itemHash;
    return _itemNotesBloc.customNameFor(hash, instanceId);
  }

  @override
  String? get itemNotes {
    final hash = itemHash;
    return _itemNotesBloc.notesFor(hash, instanceId);
  }

  @override
  List<ItemNotesTag>? get tags {
    final hash = itemHash;
    return _itemNotesBloc.tagsFor(hash, instanceId);
  }

  @override
  void editNotes() => null;

  @override
  void removeTag(ItemNotesTag tag) => null;

  @override
  void editTags() => null;

  @override
  bool? get isLocked => null;

  @override
  bool get isLockBusy => false;

  @override
  void changeLockState(bool newState) => null;

  @override
  LoadoutItemInfo? get item => _item;

  DestinyObjectiveProgress? _killTracker;

  @override
  DestinyObjectiveProgress? get killTracker => _killTracker;

  @override
  Set<WishlistTag>? get wishlistTags {
    final hash = item?.itemHash;
    final plugs = item?.reusablePlugs;
    if (hash == null || plugs == null) return null;
    return _wishlists.getWishlistBuildTags(itemHash: hash, reusablePlugs: plugs);
  }

  List<InventoryItemInfo>? get duplicates {
    return this.item?.duplicates?.where((element) => element != this.item).toList();
  }

  @override
  MappedWishlistBuilds? get wishlistBuilds {
    if (_allWishlistBuilds?.isEmpty ?? true) return null;
    if (showAllWishlistBuilds) return _allWishlistBuilds;
    return _matchedWishlistBuilds ?? {};
  }

  @override
  MappedWishlistNotes? get wishlistNotes {
    if (_allWishlistNotes?.isEmpty ?? true) return null;
    if (showAllWishlistNotes) return _allWishlistNotes;
    return _matchedWishlistNotes ?? {};
  }

  @override
  void onTransferAction(TransferActionType actionType, TransferDestination destination, int stackSize) => null;

  void saveMods() {
    final plugHashes = <int, int>{};
    final socketCount = _socketControllerBloc.socketCount;
    if (socketCount == null) {
      return;
    }
    for (int index = 0; index < socketCount; index++) {
      final selected = _socketControllerBloc.selectedPlugHashForSocket(index);
      if (selected != null) {
        plugHashes[index] = selected;
      }
    }

    Navigator.pop(context, plugHashes);
  }
}
