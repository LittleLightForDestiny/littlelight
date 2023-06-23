import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/models/character_sort_parameter.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/models/wishlist_index.dart';
import 'package:little_light/modules/settings/pages/add_wishlist/add_wishlist.page_route.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/utils/platform_capabilities.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

class SettingsBloc extends ChangeNotifier with WishlistsConsumer {
  final UserSettingsBloc _userSetttingsBloc;
  final ItemNotesBloc _itemNotesBloc;

  final BuildContext context;
  List<ItemSortParameter>? _itemOrdering;
  List<ItemSortParameter>? get itemOrdering => _itemOrdering;
  List<ItemSortParameter>? _pursuitOrdering;
  List<ItemSortParameter>? get pursuitOrdering => _pursuitOrdering;
  Set<String>? _priorityTags;
  List<WishlistFile>? wishlists;

  SettingsBloc(BuildContext this.context)
      : this._userSetttingsBloc = context.read<UserSettingsBloc>(),
        this._itemNotesBloc = context.read<ItemNotesBloc>() {
    _init();
  }

  _init() async {
    _itemOrdering = _userSetttingsBloc.itemOrdering;
    _pursuitOrdering = _userSetttingsBloc.pursuitOrdering;
    _priorityTags = _userSetttingsBloc.priorityTags?.whereType<String>().toSet();
    wishlists = await wishlistsService.getWishlists();
    notifyListeners();
  }

  bool get tapToSelect => _userSetttingsBloc.tapToSelect;
  set tapToSelect(bool value) {
    _userSetttingsBloc.tapToSelect = value;
    notifyListeners();
  }

  bool get canKeepAwake => PlatformCapabilities.keepScreenOnAvailable;

  bool get keepAwake => _userSetttingsBloc.keepAwake;
  set keepAwake(bool value) {
    _userSetttingsBloc.keepAwake = value;
    notifyListeners();
    Wakelock.toggle(enable: value);
  }

  bool get autoOpenKeyboard => _userSetttingsBloc.autoOpenKeyboard;
  set autoOpenKeyboard(bool value) {
    _userSetttingsBloc.autoOpenKeyboard = value;
    notifyListeners();
  }

  bool get enabledAutoTransfers => _userSetttingsBloc.enableAutoTransfers;

  set enabledAutoTransfers(bool value) {
    _userSetttingsBloc.enableAutoTransfers = value;
    notifyListeners();
  }

  int get defaultFreeSlots => _userSetttingsBloc.defaultFreeSlots;
  set defaultFreeSlots(int value) {
    _userSetttingsBloc.defaultFreeSlots = value;
    notifyListeners();
  }

  void addWishlist() async {
    await Navigator.push(context, AddWishlistPageRoute());
    wishlists = await wishlistsService.getWishlists();
    notifyListeners();
  }

  void removeWishlist(WishlistFile w) async {
    await wishlistsService.removeWishlist(w);
    wishlists = await wishlistsService.getWishlists();
    notifyListeners();
  }

  List<ItemNotesTag>? get priorityTags {
    final tags = _priorityTags;
    if (tags == null) return null;
    return _itemNotesBloc.tagsByIds(tags);
  }

  CharacterSortParameterType? get characterOrderingType => _userSetttingsBloc.characterOrdering?.type;
  set characterOrderingType(CharacterSortParameterType? type) {
    if (type == null) return;
    _userSetttingsBloc.characterOrdering = CharacterSortParameter(type: type);
    notifyListeners();
  }

  void updateItemOrderingDirection(ItemSortParameter parameter, SorterDirection direction) {
    final item = this._itemOrdering?.firstWhereOrNull((element) => element.type == parameter.type);
    if (item == null) return;
    item.direction = direction;
    this._userSetttingsBloc.itemOrdering = this._itemOrdering;
    notifyListeners();
  }

  void updateItemOrderingActive(ItemSortParameter parameter, bool active) {
    final item = this._itemOrdering?.firstWhereOrNull((element) => element.type == parameter.type);
    if (item == null) return;
    item.active = active;
    this._userSetttingsBloc.itemOrdering = this._itemOrdering;
    notifyListeners();
  }

  void reorderItemOrdering(int oldIndex, int newIndex) {
    final order = this._itemOrdering?.toList();
    if (order == null) return;
    final removed = order.removeAt(oldIndex);
    if (newIndex > oldIndex) newIndex = newIndex - 1;
    order.insert(newIndex, removed);
    this._itemOrdering = order;
    this._userSetttingsBloc.itemOrdering = this._itemOrdering;
    notifyListeners();
  }

  void updatePursuitOrderingDirection(ItemSortParameter parameter, SorterDirection direction) {
    final item = this._pursuitOrdering?.firstWhereOrNull((element) => element.type == parameter.type);
    if (item == null) return;
    item.direction = direction;
    this._userSetttingsBloc.pursuitOrdering = this._pursuitOrdering;
    notifyListeners();
  }

  void updatePursuitOrderingActive(ItemSortParameter parameter, bool active) {
    final item = this._pursuitOrdering?.firstWhereOrNull((element) => element.type == parameter.type);
    if (item == null) return;
    item.active = active;
    this._userSetttingsBloc.pursuitOrdering = this._pursuitOrdering;
    notifyListeners();
  }

  void reorderPursuitOrdering(int oldIndex, int newIndex) {
    final order = this._pursuitOrdering?.toList();
    if (order == null) return;
    final removed = order.removeAt(oldIndex);
    if (newIndex > oldIndex) newIndex = newIndex - 1;
    order.insert(newIndex, removed);
    this._pursuitOrdering = order;
    this._userSetttingsBloc.pursuitOrdering = this._pursuitOrdering;
    notifyListeners();
  }

  void saveDefaultFreeSlots() {
    this._userSetttingsBloc.saveDefaultFreeSlots(this.defaultFreeSlots);
  }
}
