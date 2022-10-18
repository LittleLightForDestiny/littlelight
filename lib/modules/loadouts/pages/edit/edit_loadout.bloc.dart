import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:little_light/modules/loadouts/dialogs/loadout_slot_options/loadout_slot_options.dialog_route.dart';
import 'package:little_light/modules/loadouts/pages/edit/edit_loadout.page_route.dart';
import 'package:little_light/modules/loadouts/pages/edit_item_mods/edit_loadout_item_mods.page_route.dart';
import 'package:little_light/modules/loadouts/pages/select_item/select_loadout_item.page_route.dart';
import 'package:little_light/pages/item_details/item_details.page_route.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/littlelight/loadouts.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:provider/provider.dart';

extension on Loadout {
  Loadout clone() => Loadout.copy(this);
}

class EditLoadoutBloc extends ChangeNotifier with LoadoutsConsumer, ManifestConsumer {
  final BuildContext context;

  Loadout? _originalLoadout;
  late Loadout _loadout;
  LoadoutItemIndex? _itemIndex;

  set loadoutName(String loadoutName) {
    _loadout.name = loadoutName;
    this._changed = this.changed || _loadout.name != _originalLoadout?.name;
    notifyListeners();
  }

  String get loadoutName => _loadout.name;

  DestinyInventoryItemDefinition? _emblemDefinition;
  Map<int, DestinyInventoryBucketDefinition>? _bucketDefinitions;

  DestinyInventoryItemDefinition? get emblemDefinition => _emblemDefinition;

  set emblemHash(int? emblemHash) {
    if (emblemHash == null) return;
    _emblemDefinition = null;
    _loadout.emblemHash = emblemHash;
    _changed = true;
    notifyListeners();
    _loadEmblemDefinition();
  }

  bool _changed = false;

  bool get changed => _changed;

  bool get creating => _originalLoadout == null;

  bool get loaded => _itemIndex != null && _bucketDefinitions != null;

  List<int> get bucketHashes => InventoryBucket.loadoutBucketHashes;

  EditLoadoutBloc(this.context) {
    _asyncInit();
  }

  void _asyncInit() async {
    await _initLoadout();
    _loadEmblemDefinition();
    _initItemIndex();
    _loadBucketDefinitions();
  }

  Future<void> _initLoadout() async {
    _originalLoadout = _getOriginalLoadout();
    _loadout = _originalLoadout?.clone() ?? Loadout.fromScratch();
    notifyListeners();
  }

  Loadout? _getOriginalLoadout() {
    final args = context.read<EditLoadoutPageRouteArguments>();
    final loadoutID = args.loadoutID;
    if (loadoutID == null) return null;
    final originalLoadout = loadoutService.getLoadoutById(loadoutID);
    return originalLoadout;
  }

  void _loadEmblemDefinition() async {
    _emblemDefinition = await manifest.getDefinition<DestinyInventoryItemDefinition>(_loadout.emblemHash);
    notifyListeners();
  }

  void _initItemIndex() async {
    _itemIndex = await LoadoutItemIndex.buildfromLoadout(_loadout);
    notifyListeners();
  }

  void _loadBucketDefinitions() async {
    _bucketDefinitions = await manifest.getDefinitions<DestinyInventoryBucketDefinition>(bucketHashes);
    notifyListeners();
  }

  LoadoutIndexSlot? getLoadoutIndexSlot(int hash) {
    return _itemIndex?.slots[hash];
  }

  DestinyInventoryBucketDefinition? getBucketDefinition(int hash) {
    return _bucketDefinitions?[hash];
  }

  void selectItemToAdd(DestinyClass classType, int bucketHash, bool asEquipped) async {
    final idsToAvoid = (_loadout.equipped + _loadout.unequipped) //
        .map((e) => e.itemInstanceId)
        .whereType<String>()
        .toList();
    final item = await Navigator.of(context).push(SelectLoadoutItemPageRoute(
        classType: classType, idsToAvoid: idsToAvoid, bucketHash: bucketHash, emblemHash: _loadout.emblemHash));
    if (item == null) return;
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(item.item.itemHash);
    if (def == null) return;
    if (asEquipped) {
      await _itemIndex?.addEquippedItem(item.item);
    } else {
      await _itemIndex?.addUnequippedItem(item.item);
    }
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
          item: ItemWithOwner(
            inventoryItem,
            null,
          ),
        ));
        return;
      case LoadoutSlotOptionsResponse.Remove:
        if (equipped) {
          _itemIndex?.removeEquippedItem(inventoryItem);
        } else {
          _itemIndex?.removeUnequippedItem(inventoryItem);
        }
        notifyListeners();
        break;

      case LoadoutSlotOptionsResponse.EditMods:
        final plugs = await Navigator.of(context).push(EditLoadoutItemModsPageRoute(
          inventoryItem.itemInstanceId!,
          emblemHash: this._loadout.emblemHash,
          plugHashes: item.itemPlugs,
        ));
        if (plugs != null) {
          item.itemPlugs = plugs;
        }
        break;

      default:
        return;
    }
  }

  void save() {}
}
