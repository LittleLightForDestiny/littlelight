import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:little_light/modules/loadouts/blocs/loadouts.bloc.dart';
import 'package:little_light/modules/loadouts/dialogs/loadout_slot_options/loadout_slot_options.dialog_route.dart';
import 'package:little_light/modules/loadouts/pages/edit_item_mods/edit_loadout_item_mods.page_route.dart';
import 'package:little_light/modules/loadouts/pages/select_item/select_loadout_item.page_route.dart';
import 'package:little_light/pages/item_details/item_details.page_route.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:provider/provider.dart';

import 'edit_loadout.page_route.dart';

class EditLoadoutBloc extends ChangeNotifier with ManifestConsumer {
  final BuildContext context;

  LoadoutItemIndex? _originalLoadout;
  LoadoutItemIndex? _loadout;

  String get loadoutName => _loadout?.name ?? "";

  DestinyInventoryItemDefinition? _emblemDefinition;
  Map<int, DestinyInventoryBucketDefinition>? _bucketDefinitions;

  DestinyInventoryItemDefinition? get emblemDefinition => _emblemDefinition;

  set emblemHash(int? emblemHash) {
    if (emblemHash == null) return;
    _emblemDefinition = null;
    _loadout?.emblemHash = emblemHash;
    _changed = true;
    notifyListeners();
    _loadEmblemDefinition();
  }

  bool _changed = false;

  bool get changed => _changed;

  bool _creating = false;
  bool get creating => _creating;

  bool get loaded => _loadout != null && _bucketDefinitions != null;

  List<int> get bucketHashes => InventoryBucket.loadoutBucketHashes;

  EditLoadoutBloc(this.context) {
    _asyncInit();
  }

  void _asyncInit() async {
    await _initLoadout();
    _loadEmblemDefinition();
    _loadBucketDefinitions();
  }

  Future<void> _initLoadout() async {
    _originalLoadout = _getOriginalLoadout();
    _loadout = _originalLoadout?.clone() ?? LoadoutItemIndex.fromScratch();
    notifyListeners();
  }

  LoadoutItemIndex? _getOriginalLoadout() {
    final args = context.read<EditLoadoutPageRouteArguments>();
    final loadoutID = args.loadoutID;
    if (loadoutID != null) {
      final originalLoadout = context
          .read<LoadoutsBloc>()
          .loadouts //
          ?.firstWhereOrNull((l) => l.assignedId == loadoutID);
      _creating = false;
      return originalLoadout;
    }
    _creating = true;

    if (args.preset != null) {
      _changed = true;
      return args.preset;
    }

    return null;
  }

  set loadoutName(String loadoutName) {
    _loadout?.name = loadoutName;
    _changed = changed || _loadout?.name != _originalLoadout?.name;
    notifyListeners();
  }

  void _loadEmblemDefinition() async {
    _emblemDefinition = await manifest.getDefinition<DestinyInventoryItemDefinition>(_loadout?.emblemHash);
    notifyListeners();
  }

  void _loadBucketDefinitions() async {
    _bucketDefinitions = await manifest.getDefinitions<DestinyInventoryBucketDefinition>(bucketHashes);
    notifyListeners();
  }

  LoadoutIndexSlot? getLoadoutIndexSlot(int hash) {
    return _loadout?.slots[hash];
  }

  DestinyInventoryBucketDefinition? getBucketDefinition(int hash) {
    return _bucketDefinitions?[hash];
  }

  void selectItemToAdd(DestinyClass? classType, int bucketHash, bool asEquipped) async {
    final loadout = _loadout;
    if (loadout == null) return;
    final idsToAvoid = loadout.equippedItemIds + loadout.unequippedItemIds;
    final item = await Navigator.of(context).push(SelectLoadoutItemPageRoute(
        classType: classType, idsToAvoid: idsToAvoid, bucketHash: bucketHash, emblemHash: loadout.emblemHash));
    if (item == null) return;
    await loadout.addItem(item, asEquipped);
    _changed = true;
    notifyListeners();
  }

  Future<void> openItemOptions(LoadoutIndexItem item, bool equipped) async {
    final option = await Navigator.of(context).push(LoadoutSlotOptionsDialogRoute(context, item: item));
    if (option == null) return;
    final inventoryItem = item.item;
    if (inventoryItem == null) return;
    switch (option) {
      case LoadoutSlotOptionsResponse.Details:
        Navigator.of(context).push(ItemDetailsPageRoute.viewOnly(
          item: inventoryItem,
        ));
        return;
      case LoadoutSlotOptionsResponse.Remove:
        if (equipped) {
          _loadout?.removeEquippedItem(inventoryItem);
        } else {
          _loadout?.removeUnequippedItem(inventoryItem);
        }
        _changed = true;
        notifyListeners();
        break;

      case LoadoutSlotOptionsResponse.EditMods:
        final plugs = await Navigator.of(context).push(EditLoadoutItemModsPageRoute(
          inventoryItem.instanceId!,
          emblemHash: _loadout?.emblemHash,
          plugHashes: item.itemPlugs,
        ));
        if (plugs != null) {
          item.itemPlugs = plugs;
        }
        _changed = true;
        notifyListeners();
        break;
    }
  }

  void save() async {
    final loadout = _loadout;
    if (loadout != null) {
      context.read<LoadoutsBloc>().saveLoadout(loadout);
    }
    Navigator.of(context).pop(loadout);
  }
}
