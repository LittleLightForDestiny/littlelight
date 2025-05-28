import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/destiny_loadout.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/modules/loadouts/pages/confirm_delete_destiny_loadout/confirm_delete_destiny_loadout.bottomsheet.dart';
import 'package:little_light/modules/loadouts/pages/edit/edit_loadout.page_route.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/shared/utils/helpers/plug_helpers.dart';
import 'package:provider/provider.dart';

class DestinyLoadoutDetailsBloc extends ChangeNotifier {
  final String characterId;
  final int loadoutIndex;

  @protected
  final BuildContext context;

  @protected
  final ProfileBloc profile;

  @protected
  final ManifestService manifest;

  @protected
  final InventoryBloc inventory;

  DestinyLoadoutInfo? _loadout;
  DestinyLoadoutInfo? get loadout => _loadout;

  DestinyCharacterInfo? _character;
  DestinyCharacterInfo? get character => _character;

  DestinyLoadoutConstantsDefinition? _loadoutConstants;
  List<int>? get availableColorHashes => _loadoutConstants?.loadoutColorHashes;
  List<int>? get availableIconHashes => _loadoutConstants?.loadoutIconHashes;
  List<int>? get availableNameHashes => _loadoutConstants?.loadoutNameHashes;

  int? _selectedColorHash;
  int? get selectedColorHash => _selectedColorHash ?? loadout?.loadout.colorHash;
  set selectedColorHash(int? value) {
    _selectedColorHash = value;
    notifyListeners();
  }

  int? _selectedIconHash;
  int? get selectedIconHash => _selectedIconHash ?? loadout?.loadout.iconHash;
  set selectedIconHash(int? value) {
    _selectedIconHash = value;
    notifyListeners();
  }

  int? _selectedNameHash;
  int? get selectedNameHash => _selectedNameHash ?? loadout?.loadout.nameHash;
  set selectedNameHash(int? value) {
    _selectedNameHash = value;
    notifyListeners();
  }

  bool get canSave =>
      selectedNameHash != loadout?.loadout.nameHash || //
      selectedIconHash != loadout?.loadout.iconHash ||
      selectedColorHash != loadout?.loadout.colorHash;

  DestinyLoadoutDetailsBloc(
    BuildContext this.context, {
    required this.characterId,
    required this.loadoutIndex,
  })  : profile = context.read<ProfileBloc>(),
        manifest = context.read<ManifestService>(),
        inventory = context.read<InventoryBloc>() {
    _init();
  }

  _init() {
    _initLoadout();
    _initConstants();
    profile.addListener(_initLoadout);
  }

  dispose() {
    super.dispose();
    profile.removeListener(_initLoadout);
  }

  _initLoadout() async {
    final character = profile.getCharacterById(characterId);
    final loadout = character?.loadouts?[loadoutIndex];
    if (loadout == null) return;
    final loadoutInfo = await DestinyLoadoutInfo.fromInventory(profile, manifest, loadout, characterId, loadoutIndex);
    this._character = character;
    this._loadout = loadoutInfo;
    notifyListeners();
  }

  _initConstants() async {
    final loadoutConstants = await manifest.getDefinition<DestinyLoadoutConstantsDefinition>(1);
    this._loadoutConstants = loadoutConstants;
    notifyListeners();
  }

  void importToLittleLight() async {
    final destinyLoadout = _loadout;
    if (destinyLoadout == null) return;
    final items = destinyLoadout.items;
    if (items == null) return;
    final nameDef = await manifest.getDefinition<DestinyLoadoutNameDefinition>(destinyLoadout.loadout.nameHash);
    final equipped = <LoadoutItem>[];
    for (final item in items.values) {
      final definition = await manifest.getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
      final sockets = item.sockets ?? <DestinyItemSocketState>[];
      final socketPlugs = <int, int>{};
      for (int i = 0; i < sockets.length; i++) {
        final plugHash = sockets[i].plugHash;
        if (plugHash == null) continue;
        final canApply = await isPlugAvailableToApplyForFreeViaApi(manifest, item, i, plugHash);
        if (!canApply) continue;
        socketPlugs[i] = plugHash;
      }
      final loadoutItem = LoadoutItem(
        itemHash: item.itemHash,
        itemInstanceId: item.instanceId,
        socketPlugs: socketPlugs,
        bucketHash: definition?.inventory?.bucketTypeHash,
        classType: definition?.classType,
      );
      equipped.add(loadoutItem);
    }
    final loadout = Loadout(
      name: nameDef?.name ?? "",
      equipped: equipped,
    );
    Navigator.of(context).pushReplacement(EditLoadoutPageRoute.createFromPreset(loadout));
  }

  void equipLoadout() async {
    final loadout = _loadout;
    if (loadout == null) return;
    await inventory.equipDestinyLoadout(loadout);
  }

  void saveChanges() async {
    final loadout = _loadout;
    if (loadout == null) return;
    await profile.updateLoadoutIdentifiers(
      loadout,
      nameHash: selectedNameHash,
      iconHash: selectedIconHash,
      colorHash: selectedColorHash,
    );
  }

  void deleteLoadout() async {
    final loadout = _loadout;
    if (loadout == null) return;
    final confirmed = await ConfirmDeleteDestinyLoadoutBottomSheet(loadout).show(context);
    if (confirmed ?? false) Navigator.of(context).pop();
  }
}
