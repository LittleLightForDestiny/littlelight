import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/item_info/definition_item_info.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/modules/item_details/blocs/item_details.bloc.dart';
import 'package:little_light/modules/item_tags/pages/edit_item_tags/edit_item_tags.bottomsheet.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/models/transfer_destination.dart';
import 'package:little_light/shared/utils/helpers/wishlist_helpers.dart';
import 'package:little_light/shared/widgets/transfer_destinations/transfer_destinations.widget.dart';
import 'package:provider/provider.dart';

class DefinitionItemDetailsBloc extends ItemDetailsBloc {
  final ProfileBloc _profileBloc;

  final ItemNotesBloc _itemNotesBloc;
  final SocketControllerBloc _socketControllerBloc;
  final ManifestService _manifestBloc;
  final WishlistsService _wishlists;

  int _itemHash;

  @protected
  DefinitionItemInfo? _item;

  List<TransferDestination>? _transferDestinations;
  List<TransferDestination>? _equipDestinations;

  MappedWishlistBuilds? _allWishlistBuilds;
  MappedWishlistBuilds? _matchedWishlistBuilds;

  MappedWishlistNotes? _allWishlistNotes;
  MappedWishlistNotes? _matchedWishlistNotes;

  bool _lockBusy = false;

  DefinitionItemDetailsBloc(BuildContext context, int itemHash)
      : this._itemHash = itemHash,
        _profileBloc = context.read<ProfileBloc>(),
        _itemNotesBloc = context.read<ItemNotesBloc>(),
        _socketControllerBloc = context.read<SocketControllerBloc>(),
        _manifestBloc = context.read<ManifestService>(),
        _wishlists = getInjectedWishlistsService(),
        super(context) {
    _init();
  }

  _init() {
    _profileBloc.addListener(_updateDuplicates);
    _itemNotesBloc.addListener(notifyListeners);

    _initData();
    _updateDuplicates();
  }

  void _initData() async {
    final allWishlists = _wishlists.getWishlistBuilds(itemHash: itemHash);
    final definition = await _manifestBloc.getDefinition<DestinyInventoryItemDefinition>(itemHash);
    if (definition != null) {
      final item = DefinitionItemInfo(definition);
      this._item = item;
      _socketControllerBloc.init(this._item);
    }
    _allWishlistBuilds = allWishlists.isNotEmpty ? organizeWishlistBuilds(allWishlists) : null;
    _allWishlistNotes = allWishlists.isNotEmpty ? organizeWishlistNotes(allWishlists) : null;
  }

  @override
  void dispose() {
    _profileBloc.removeListener(_updateDuplicates);
    _itemNotesBloc.removeListener(notifyListeners);
    super.dispose();
  }

  void _updateDuplicates() async {
    notifyListeners();
  }

  @override
  int? get itemHash => _itemHash;

  @protected
  String? get instanceId => null;

  @protected
  int? get stackIndex => null;

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
  String? get itemNotes => null;

  @override
  List<ItemNotesTag>? get tags {
    final hash = itemHash;
    return _itemNotesBloc.tagsFor(hash, instanceId);
  }

  @override
  void editNotes() => null;

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
  bool? get isLocked => false;

  @override
  bool get isLockBusy => false;

  @override
  void changeLockState(bool newState) => null;

  DefinitionItemInfo? get item => _item;

  @override
  DestinyObjectiveProgress? get killTracker => null;

  @override
  Set<WishlistTag>? get wishlistTags => null;

  List<InventoryItemInfo>? get duplicates {
    return _profileBloc.getItemsByHash(_itemHash);
  }

  @override
  MappedWishlistBuilds? get wishlistBuilds => _allWishlistBuilds;

  @override
  MappedWishlistNotes? get wishlistNotes => _allWishlistNotes;

  @override
  void onTransferAction(TransferActionType actionType, TransferDestination destination, int stackSize) => null;
}
