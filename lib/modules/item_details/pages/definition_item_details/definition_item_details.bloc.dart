import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_index.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/blocs/profile/sorters.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
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
import 'package:little_light/shared/utils/sorters/items/multi_sorter.dart';
import 'package:little_light/shared/utils/sorters/items/priority_tags_sorter.dart';
import 'package:little_light/shared/widgets/transfer_destinations/transfer_destinations.widget.dart';
import 'package:provider/provider.dart';

class DefinitionItemDetailsBloc extends ItemDetailsBloc {
  final ProfileBloc _profileBloc;

  final ItemNotesBloc _itemNotesBloc;
  final SocketControllerBloc _socketControllerBloc;
  final ManifestService _manifestBloc;
  final WishlistsService _wishlists;
  final UserSettingsBloc _userSettingsBloc;

  int _itemHash;

  @protected
  DefinitionItemInfo? _item;

  List<TransferDestination>? _transferDestinations;
  List<TransferDestination>? _equipDestinations;

  MappedWishlistBuilds? _allWishlistBuilds;
  MappedWishlistNotes? _allWishlistNotes;

  List<InventoryItemInfo>? _duplicates;

  DefinitionItemDetailsBloc(BuildContext context, int itemHash)
      : this._itemHash = itemHash,
        _profileBloc = context.read<ProfileBloc>(),
        _itemNotesBloc = context.read<ItemNotesBloc>(),
        _socketControllerBloc = context.read<SocketControllerBloc>(),
        _manifestBloc = context.read<ManifestService>(),
        _wishlists = getInjectedWishlistsService(),
        _userSettingsBloc = context.read<UserSettingsBloc>(),
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
    final duplicates = this._profileBloc.getItemsByHash(itemHash).toList();
    _duplicates = duplicates;
    if (duplicates.isEmpty) return;

    final sorters = _userSettingsBloc.itemOrdering;
    final priority = _userSettingsBloc.priorityTags;
    if (sorters == null) return;
    final defs = await _manifestBloc.getDefinitions<DestinyInventoryItemDefinition>({itemHash});
    _duplicates = await MultiSorter([
      if (priority != null && priority.isNotEmpty) PriorityTagsSorter(context, priority),
      ...getSortersFromStorage(
        sorters,
        context,
        defs,
        _profileBloc.characters ?? [],
      )
    ]).sort(duplicates);
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
    final def = _manifestBloc.definition<DestinyInventoryItemDefinition>(this.item?.itemHash);
    if ((def?.equippable ?? true) == false) return null;
    return _duplicates;
  }

  @override
  MappedWishlistBuilds? get wishlistBuilds => _allWishlistBuilds;

  @override
  MappedWishlistNotes? get wishlistNotes => _allWishlistNotes;

  @override
  void onTransferAction(TransferActionType actionType, TransferDestination destination, int stackSize) => null;

  @override
  DestinyCharacterInfo? get character => null;

  @override
  List<DestinyObjectiveProgress>? get craftedObjectives => null;

  @override
  void addToLoadout() => null;
  @override
  List<LoadoutItemIndex>? get loadouts => null;
  @override
  void openLoadout(LoadoutItemIndex loadout) => null;
}
