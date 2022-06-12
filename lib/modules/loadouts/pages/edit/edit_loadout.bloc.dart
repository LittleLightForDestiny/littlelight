import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/modules/loadouts/pages/edit/edit_loadout.page_route.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/littlelight/loadouts.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

extension on Loadout {
  Loadout clone() => Loadout.copy(this);
}

class EditLoadoutBloc extends ChangeNotifier with LoadoutsConsumer, ManifestConsumer {
  final BuildContext context;

  Loadout? _originalLoadout;
  late Loadout _loadout;
  LoadoutItemIndex? _itemIndex;

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
    await Future.delayed(Duration.zero);
    _originalLoadout = _getOriginalLoadout();
    _loadout = _originalLoadout?.clone() ?? Loadout.fromScratch();
    notifyListeners();
  }

  Loadout? _getOriginalLoadout() {
    final route = ModalRoute.of(context);
    EditLoadoutPageRouteArguments? args = route?.settings.arguments as EditLoadoutPageRouteArguments?;
    final loadoutID = args?.loadoutID;
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

  void save() {}
}
