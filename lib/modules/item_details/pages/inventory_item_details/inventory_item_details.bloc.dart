import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/core/blocs/littlelight_data/littlelight_data.bloc.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_index.dart';
import 'package:little_light/core/blocs/loadouts/loadouts.bloc.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/sorters.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/modules/item_details/blocs/item_details.bloc.dart';
import 'package:little_light/modules/item_details/pages/edit_item_notes/edit_item_notes.bottomsheet.dart';
import 'package:little_light/modules/item_tags/pages/edit_item_tags/edit_item_tags.bottomsheet.dart';
import 'package:little_light/modules/loadouts/pages/add_to_loadout_quickmenu/add_to_loadout_quickmenu.bottomsheet.dart';
import 'package:little_light/modules/loadouts/pages/equip/equip_loadout.page_route.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/models/transfer_destination.dart';
import 'package:little_light/shared/utils/helpers/get_transfer_destinations.dart';
import 'package:little_light/shared/utils/helpers/loadout_helpers.dart';
import 'package:little_light/shared/utils/helpers/plug_helpers.dart';
import 'package:little_light/shared/utils/helpers/wishlist_helpers.dart';
import 'package:little_light/shared/utils/sorters/items/export.dart';
import 'package:little_light/shared/widgets/transfer_destinations/transfer_destinations.widget.dart';
import 'package:provider/provider.dart';

class InventoryItemDetailsBloc extends ItemDetailsBloc {
  final ProfileBloc _profileBloc;
  final InventoryBloc _inventoryBloc;
  final ItemNotesBloc _itemNotesBloc;
  final SocketControllerBloc _socketControllerBloc;
  final ManifestService _manifestBloc;
  final WishlistsService _wishlists;
  final LoadoutsBloc _loadoutsBloc;
  final UserSettingsBloc _userSettingsBloc;

  @protected
  InventoryItemInfo? _item;

  List<TransferDestination>? _transferDestinations;
  List<TransferDestination>? _equipDestinations;

  MappedWishlistBuilds? _allWishlistBuilds;
  MappedWishlistBuilds? _matchedWishlistBuilds;

  MappedWishlistNotes? _allWishlistNotes;
  MappedWishlistNotes? _matchedWishlistNotes;

  LittleLightDataBloc _littleLightDataBloc;

  List<LoadoutItemIndex>? _loadouts;

  bool _lockBusy = false;

  List<InventoryItemInfo>? _duplicates;

  InventoryItemDetailsBloc(BuildContext context, {InventoryItemInfo? item})
      : _item = item,
        _profileBloc = context.read<ProfileBloc>(),
        _inventoryBloc = context.read<InventoryBloc>(),
        _itemNotesBloc = context.read<ItemNotesBloc>(),
        _socketControllerBloc = context.read<SocketControllerBloc>(),
        _manifestBloc = context.read<ManifestService>(),
        _littleLightDataBloc = context.read<LittleLightDataBloc>(),
        _wishlists = getInjectedWishlistsService(),
        _loadoutsBloc = context.read<LoadoutsBloc>(),
        _userSettingsBloc = context.read<UserSettingsBloc>(),
        super(context) {
    _init();
  }

  _init() {
    _profileBloc.addListener(_updateItem);
    _itemNotesBloc.addListener(notifyListeners);
    _loadoutsBloc.addListener(_updateLoadouts);
    _socketControllerBloc.init(this._item);
    _updateItem();
    _updateLoadouts();
  }

  @override
  void dispose() {
    _profileBloc.removeListener(_updateItem);
    _itemNotesBloc.removeListener(notifyListeners);
    _loadoutsBloc.removeListener(_updateLoadouts);
    super.dispose();
  }

  void _updateItem() async {
    final allItems = _profileBloc.allItems;
    final item = allItems.firstWhereOrNull((item) =>
        item.itemHash == this.itemHash && //
        item.instanceId == this.instanceId &&
        item.stackIndex == this.stackIndex);
    if (item == null) return;

    this._item = item;
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
    _updateCraftedProgress();
    _updateDuplicates();

    notifyListeners();
  }

  void _updateLoadouts() async {
    final loadouts = _loadoutsBloc.loadouts;
    final instanceId = this.item?.instanceId;
    if (instanceId == null) return null;
    if (loadouts == null || loadouts.isEmpty) return;
    final filteredLoadouts = <LoadoutItemIndex>[];
    for (final l in loadouts) {
      if (!l.containsItem(instanceId)) continue;
      final loadoutIndex = await l.generateIndex(profile: _profileBloc, manifest: _manifestBloc);
      filteredLoadouts.add(loadoutIndex);
    }
    this._loadouts = filteredLoadouts;
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

  void _updateCraftedProgress() async {
    final gameData = _littleLightDataBloc.gameData;
    if (gameData == null) return;
    final isCrafted = item?.state?.contains(ItemState.Crafted) ?? false;
    if (!isCrafted) return;
    final plugHashes = this.item?.sockets?.map((s) => s.plugHash);
    if (plugHashes == null) return;
    final defs = await _manifestBloc.getDefinitions<DestinyInventoryItemDefinition>(plugHashes);
    final craftedDef = defs.values.firstWhereOrNull((def) => isCraftedProgressPlug(gameData, def));
    final objectives = this.item?.plugObjectives?["${craftedDef?.hash}"];
    _craftedObjectives = objectives;
    notifyListeners();
  }

  void _updateDuplicates() async {
    final duplicates = this.item?.duplicates?.where((element) => element != this.item).toList();
    _duplicates = duplicates;
    if (duplicates == null || duplicates.isEmpty) return;

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
  bool? get isLocked {
    final lockable = _item?.lockable ?? false;
    if (!lockable) return null;
    return _item?.state?.contains(ItemState.Locked);
  }

  @override
  bool get isLockBusy => _lockBusy;

  @override
  void changeLockState(bool newState) async {
    final item = this._item;
    if (item == null) return;
    _lockBusy = true;
    notifyListeners();
    await _inventoryBloc.changeItemLockState(item, newState);
    _lockBusy = false;
    notifyListeners();
  }

  @override
  InventoryItemInfo? get item => _item;

  DestinyObjectiveProgress? _killTracker;

  List<DestinyObjectiveProgress>? _craftedObjectives;

  @override
  List<DestinyObjectiveProgress>? get craftedObjectives => _craftedObjectives;

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
    return _duplicates;
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
  void onTransferAction(TransferActionType actionType, TransferDestination destination, int stackSize) async {
    final item = this.item;
    if (item == null) return;
    if (actionType == TransferActionType.Transfer) {
      _inventoryBloc.transfer(item, destination, stackSize: stackSize);
    } else {
      _inventoryBloc.equip(item, destination);
    }
    Navigator.of(context).pop();
  }

  @override
  DestinyCharacterInfo? get character {
    final characterId = item?.characterId;
    if (characterId == null) return null;
    final character = _profileBloc.getCharacterById(characterId);
    return character;
  }

  @override
  List<LoadoutItemIndex>? get loadouts => _loadouts;

  void openLoadout(LoadoutItemIndex loadout) {
    final id = loadout.loadoutId;
    if (id == null) return;
    Navigator.of(context).push(EquipLoadoutPageRoute(id));
  }

  @override
  void addToLoadout() {
    final item = this.item;
    if (item == null) return;
    AddToLoadoutBottomsheet(item).show(context);
  }
}
