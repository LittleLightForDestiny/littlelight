import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/notifications/loadout_change_result_notification.dart';
import 'package:little_light/core/blocs/notifications/notifications.bloc.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/modules/item_details/pages/loadout_item_details/loadout_item_details.page_route.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_info.dart';
import 'package:little_light/modules/loadouts/blocs/loadouts.bloc.dart';
import 'package:little_light/modules/loadouts/pages/edit/edit_loadout.page_route.dart';
import 'package:little_light/modules/loadouts/pages/loadout_item_options/loadout_item_options.bottomsheet.dart';
import 'package:little_light/modules/search/pages/select_loadout_item/select_loadout_item.page_route.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/helpers/loadout_helpers.dart';
import 'package:provider/provider.dart';

class EditLoadoutBloc extends ChangeNotifier with ManifestConsumer {
  @protected
  final BuildContext context;

  @protected
  final LoadoutsBloc loadoutsBloc;

  @protected
  final ProfileBloc profileBloc;

  @protected
  final NotificationsBloc notificationBloc;

  LoadoutItemIndex? _itemIndex;

  String? _loadoutName;

  String get loadoutName => _loadoutName ?? "";

  int? _emblemHash;
  int? get emblemHash => _emblemHash;

  bool _changed = false;
  bool get changed => _changed;

  bool _creating = false;
  bool get creating => _creating;

  List<int> get bucketHashes => InventoryBucket.loadoutBucketHashes;

  Set<DestinyClass>? _availableClasses;
  Set<DestinyClass>? get availableClasses => _availableClasses;

  EditLoadoutBloc(this.context, EditLoadoutPageRouteArguments args)
      : loadoutsBloc = context.read<LoadoutsBloc>(),
        profileBloc = context.read<ProfileBloc>(),
        notificationBloc = context.read<NotificationsBloc>() {
    _init(args);
  }

  void _init(EditLoadoutPageRouteArguments args) async {
    _initLoadout(args);
    profileBloc.addListener(_update);
    _update();
  }

  void _initLoadout(EditLoadoutPageRouteArguments args) async {
    LoadoutItemIndex? loadout;
    final id = args.loadoutID;
    if (id != null) {
      loadout = await loadoutsBloc.getLoadout(id)?.generateIndex(profile: profileBloc, manifest: manifest);
    }
    this._creating = loadout == null;

    loadout ??= LoadoutItemIndex("");
    _loadoutName = loadout.name;
    _emblemHash = loadout.emblemHash;
    this._itemIndex = loadout;
    notifyListeners();
  }

  _update() {
    _availableClasses = profileBloc.characters?.map((e) => e.character.classType).whereType<DestinyClass>().toSet();
    notifyListeners();
  }

  void dispose() {
    profileBloc.removeListener(_update);
    super.dispose();
  }

  set loadoutName(String loadoutName) {
    _loadoutName = loadoutName;
    _changed = true;
    notifyListeners();
  }

  LoadoutIndexSlot? getLoadoutIndexSlot(int bucketHash) {
    return _itemIndex?.slots[bucketHash];
  }

  void onSlotAction(int bucketHash, {bool equipped = false, DestinyClass? classType, LoadoutItemInfo? loadoutItem}) {
    final item = loadoutItem?.inventoryItem;
    if (item == null) {
      return selectItem(bucketHash, equipped: equipped, classType: classType);
    }

    if (loadoutItem != null) {
      return openOptions(loadoutItem, equipped: equipped);
    }
  }

  void selectItem(int bucketHash, {bool equipped = false, DestinyClass? classType}) async {
    final slot = _itemIndex?.slots[bucketHash];
    final classSpecific = slot?.classSpecificEquipped.values.map((e) => e.inventoryItem?.instanceId).toList() ?? [];
    final unequipped = slot?.unequipped.map((e) => e.inventoryItem?.instanceId).toList() ?? [];
    final idsToAvoid = [
      ...classSpecific,
      slot?.genericEquipped.inventoryItem?.instanceId,
      ...unequipped,
    ].whereType<String>().toList();
    final item = await Navigator.of(context).push(SelectLoadoutItemPageRoute(
      bucketHash: bucketHash,
      classType: classType,
      idsToAvoid: idsToAvoid,
      emblemHash: emblemHash,
    ));
    if (item == null) return;
    final result = await _itemIndex?.addItem(manifest, item, equipped: equipped);
    notifyUser(result);
    notifyListeners();
  }

  void openOptions(LoadoutItemInfo loadoutItem, {bool equipped = false}) async {
    final option = await LoadoutItemOptionsBottomSheet(
      loadoutItem,
    ).show(context);
    if (option == LoadoutItemOption.Remove) {
      await _itemIndex?.removeItem(manifest, loadoutItem.inventoryItem, equipped: equipped);
      notifyListeners();
      return;
    }
    if (option == LoadoutItemOption.EditMods) {
      final mods = await Navigator.of(context).push(LoadoutItemDetailsPageRoute(loadoutItem));
      if (mods != null) {
        loadoutItem.itemPlugs = mods;
        notifyListeners();
      }
    }
  }

  void notifyUser(LoadoutChangeResults? result) {
    if (result == null) return;
    if (result.cause == null) return;
    this.notificationBloc.createPersistentNotification(LoadoutChangeResultNotification(result));
  }

  void save() async {
    final loadout = this._itemIndex?.toLoadout();
    if (loadout != null) {
      context.read<LoadoutsBloc>().saveLoadout(loadout);
    }
    Navigator.of(context).pop(loadout);
  }
}
