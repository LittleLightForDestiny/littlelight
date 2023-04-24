import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/modules/item_details/pages/inventory_item_details/inventory_item_details.page_route.dart';
import 'package:little_light/shared/models/transfer_destination.dart';
import 'package:provider/provider.dart';

abstract class ItemDetailsBloc extends ChangeNotifier {
  @protected
  final BuildContext context;

  @protected
  final UserSettingsBloc userSettingsBloc;

  @protected
  final SelectionBloc selectionBloc;

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

  void editNotes();
  void removeTag(ItemNotesTag tag);
  void editTags();

  Set<WishlistTag>? get wishlistTags;

  bool? get isLocked;
  bool get isLockBusy;
  void changeLockState(bool newState);

  DestinyItemInfo? get item;
  List<DestinyItemInfo>? get duplicates;

  void onDuplicateItemTap(DestinyItemInfo item) {
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

  void onDuplicateItemHold(DestinyItemInfo item) {
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
}
