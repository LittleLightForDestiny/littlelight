import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/modules/item_details/pages/definition_item_details/definition_item_details.page_route.dart';
import 'package:little_light/modules/item_details/pages/inventory_item_details/inventory_item_details.page_route.dart';
import 'package:little_light/shared/models/transfer_destination.dart';
import 'package:little_light/shared/utils/helpers/wishlist_helpers.dart';
import 'package:little_light/shared/widgets/transfer_destinations/transfer_destinations.widget.dart';
import 'package:provider/provider.dart';

const _allWishlistsBuildsVisibilityKey = 'all wishlists builds';
const _allWishlistsNotesVisibilityKey = 'all wishlists notes';

abstract class ItemDetailsBloc extends ChangeNotifier {
  @protected
  final BuildContext context;

  @protected
  final UserSettingsBloc userSettingsBloc;

  @protected
  final SelectionBloc selectionBloc;

  bool get canTrack => true;

  ItemDetailsBloc(this.context)
      : this.userSettingsBloc = context.read<UserSettingsBloc>(),
        this.selectionBloc = context.read<SelectionBloc>(),
        super();

  int? get itemHash;
  int? get styleHash;

  List<TransferDestination>? get transferDestinations;
  List<TransferDestination>? get equipDestinations;

  String? get customName;
  String? get itemNotes;
  List<ItemNotesTag>? get tags;

  DestinyObjectiveProgress? get killTracker;
  List<DestinyObjectiveProgress>? get craftedObjectives;

  void editNotes();
  void removeTag(ItemNotesTag tag);
  void editTags();

  Set<WishlistTag>? get wishlistTags;
  MappedWishlistBuilds? get wishlistBuilds;
  MappedWishlistNotes? get wishlistNotes;

  DestinyCharacterInfo? get character;

  bool? get isLocked;
  bool get isLockBusy;
  void changeLockState(bool newState);

  DestinyItemInfo? get item;
  List<DestinyItemInfo>? get duplicates;

  void onDuplicateItemTap(InventoryItemInfo item) {
    final hash = item.itemHash;
    final instanceId = item.instanceId;
    final stackIndex = item.stackIndex;

    if (hash == null) return;

    if (selectionBloc.hasSelection || userSettingsBloc.tapToSelect) {
      return selectionBloc.toggleSelected(
        hash,
        instanceId: instanceId,
        stackIndex: stackIndex,
      );
    }

    Navigator.of(context).pushReplacement(InventoryItemDetailsPageRoute(item));
  }

  void onDuplicateItemHold(InventoryItemInfo item) {
    final hash = item.itemHash;
    final instanceId = item.instanceId;
    final stackIndex = item.stackIndex;
    if (hash == null) return;
    if (userSettingsBloc.tapToSelect) {
      Navigator.of(context).push(InventoryItemDetailsPageRoute(item));
      return;
    }
    return selectionBloc.toggleSelected(
      hash,
      instanceId: instanceId,
      stackIndex: stackIndex,
    );
  }

  bool get showAllWishlistBuilds => userSettingsBloc.getSectionVisibleState(
        _allWishlistsBuildsVisibilityKey,
        defaultValue: false,
      );
  set showAllWishlistBuilds(bool value) {
    userSettingsBloc.setSectionVisibleState(_allWishlistsBuildsVisibilityKey, value);
    notifyListeners();
  }

  bool get showAllWishlistNotes => userSettingsBloc.getSectionVisibleState(
        _allWishlistsNotesVisibilityKey,
        defaultValue: false,
      );
  set showAllWishlistNotes(bool value) {
    userSettingsBloc.setSectionVisibleState(_allWishlistsNotesVisibilityKey, value);
    notifyListeners();
  }

  void onTransferAction(TransferActionType actionType, TransferDestination destination, int stackSize);

  void addToLoadout() {}

  void viewInCollections() {
    final hash = itemHash;
    if (hash == null) return;
    Navigator.of(context).pushReplacement(DefinitionItemDetailsPageRoute(hash));
  }
}
