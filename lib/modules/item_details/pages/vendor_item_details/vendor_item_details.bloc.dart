import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_index.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/blocs/vendors/vendor_item_info.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/modules/item_details/blocs/item_details.bloc.dart';
import 'package:little_light/modules/item_details/pages/edit_item_notes/edit_item_notes.bottomsheet.dart';
import 'package:little_light/modules/item_tags/pages/edit_item_tags/edit_item_tags.bottomsheet.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/models/transfer_destination.dart';
import 'package:little_light/shared/utils/helpers/plug_helpers.dart';
import 'package:little_light/shared/utils/helpers/wishlist_helpers.dart';
import 'package:little_light/shared/widgets/transfer_destinations/transfer_destinations.widget.dart';
import 'package:provider/provider.dart';

class VendorItemDetailsBloc extends ItemDetailsBloc {
  final ItemNotesBloc _itemNotesBloc;
  final ProfileBloc _profileBloc;
  final SocketControllerBloc _socketControllerBloc;
  final ManifestService _manifestBloc;
  final WishlistsService _wishlists;

  @protected
  VendorItemInfo? _item;

  List<TransferDestination>? _transferDestinations;
  List<TransferDestination>? _equipDestinations;

  MappedWishlistBuilds? _allWishlistBuilds;
  MappedWishlistBuilds? _matchedWishlistBuilds;

  MappedWishlistNotes? _allWishlistNotes;
  MappedWishlistNotes? _matchedWishlistNotes;

  @override
  bool get canTrack => false;

  VendorItemDetailsBloc(BuildContext context, {VendorItemInfo? item})
      : _item = item,
        _itemNotesBloc = context.read<ItemNotesBloc>(),
        _socketControllerBloc = context.read<SocketControllerBloc>(),
        _manifestBloc = context.read<ManifestService>(),
        _wishlists = getInjectedWishlistsService(),
        _profileBloc = context.read<ProfileBloc>(),
        super(context) {
    _init();
  }

  _init() {
    _itemNotesBloc.addListener(notifyListeners);
    _socketControllerBloc.init(this._item);
    _updateItem();
  }

  @override
  void dispose() {
    _itemNotesBloc.removeListener(notifyListeners);
    super.dispose();
  }

  void _updateItem() async {
    final item = this._item;
    if (item == null) return;
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
  String? get instanceId => _item?.instanceId;
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
  void editNotes() {
    final hash = this._item?.itemHash;
    final instanceId = this._item?.instanceId;
    if (hash == null) return;
    EditItemNotesBottomSheet(hash, instanceId).show(context);
  }

  @override
  void removeTag(ItemNotesTag tag) {
    final hash = this._item?.itemHash;
    final instanceId = this._item?.instanceId;
    final tagId = tag.tagId;
    if (hash == null || tagId == null) return;
    _itemNotesBloc.removeTag(hash, instanceId, tagId);
  }

  @override
  void editTags() {
    final hash = this._item?.itemHash;
    final instanceId = this._item?.instanceId;
    if (hash == null) return;
    EditItemTagsBottomSheet(hash, instanceId).show(context);
  }

  @override
  bool? get isLocked => null;

  @override
  bool get isLockBusy => false;

  @override
  void changeLockState(bool newState) => null;

  @override
  VendorItemInfo? get item => _item;

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
    final def = _manifestBloc.definition<DestinyInventoryItemDefinition>(this.item?.itemHash);
    if ((def?.equippable ?? true) == false) return null;
    return this._profileBloc.getItemsByHash(this.itemHash);
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
  DestinyCharacterInfo? get character {
    final characterId = item?.characterId;
    if (characterId == null) return null;
    final character = _profileBloc.getCharacterById(characterId);
    return character;
  }

  @override
  void onTransferAction(TransferActionType actionType, TransferDestination destination, int stackSize) => null;

  @override
  List<DestinyObjectiveProgress>? get craftedObjectives => null;

  @override
  void addToLoadout() => null;

  @override
  void openLoadout(LoadoutItemIndex loadout) => null;

  @override
  List<LoadoutItemIndex>? get loadouts => null;
}
