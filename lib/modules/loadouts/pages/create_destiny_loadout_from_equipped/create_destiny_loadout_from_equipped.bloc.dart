import 'dart:math';

import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/destiny_loadout.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:provider/provider.dart';

class CreateDestinyLoadoutFromEquippedBloc extends ChangeNotifier {
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

  DestinyCharacterInfo? _character;
  DestinyCharacterInfo? get character => _character;

  DestinyLoadoutInfo? _loadoutInfo;
  DestinyLoadoutInfo? get loadoutInfo => _loadoutInfo;
  Map<int, DestinyLoadoutItemInfo>? get items => _loadoutInfo?.items;

  DestinyLoadoutConstantsDefinition? _loadoutConstants;
  List<int>? get availableColorHashes => _loadoutConstants?.loadoutColorHashes;
  List<int>? get availableIconHashes => _loadoutConstants?.loadoutIconHashes;
  List<int>? get availableNameHashes => _loadoutConstants?.loadoutNameHashes;

  int? _selectedColorHash;
  int? get selectedColorHash => _selectedColorHash;
  set selectedColorHash(int? value) {
    _selectedColorHash = value;
    notifyListeners();
  }

  int? _selectedIconHash;
  int? get selectedIconHash => _selectedIconHash;
  set selectedIconHash(int? value) {
    _selectedIconHash = value;
    notifyListeners();
  }

  int? _selectedNameHash;
  int? get selectedNameHash => _selectedNameHash;
  set selectedNameHash(int? value) {
    _selectedNameHash = value;
    notifyListeners();
  }

  bool get canSave =>
      selectedNameHash != null && //
      selectedIconHash != null &&
      selectedColorHash != null;

  CreateDestinyLoadoutFromEquippedBloc(
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
    _initOptions();
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
    this._character = character;
    this._loadoutInfo = await DestinyLoadoutInfo.fromEquippedItems(
      profile: profile,
      manifest: manifest,
      characterId: characterId,
      nameHash: selectedNameHash,
      iconHash: selectedIconHash,
      colorHash: selectedColorHash,
      loadoutIndex: loadoutIndex,
    );
    notifyListeners();
  }

  _initOptions() async {
    final loadoutConstants = await manifest.getDefinition<DestinyLoadoutConstantsDefinition>(1);
    this._loadoutConstants = loadoutConstants;
    final availableNameHashes = loadoutConstants?.loadoutNameHashes;
    final availableIconHashes = loadoutConstants?.loadoutIconHashes;
    final availableColorHashes = loadoutConstants?.loadoutColorHashes;
    if (availableNameHashes == null || availableIconHashes == null || availableColorHashes == null) {
      return;
    }
    final nameIndex = Random().nextInt(availableNameHashes.length);
    _selectedNameHash = availableNameHashes[nameIndex];

    final iconIndex = Random().nextInt(availableIconHashes.length);
    _selectedIconHash = availableIconHashes[iconIndex];

    final colorIndex = Random().nextInt(availableColorHashes.length);
    _selectedColorHash = availableColorHashes[colorIndex];

    notifyListeners();
  }

  void saveLoadout() async {
    if (!canSave) return;
    final loadout = await DestinyLoadoutInfo.fromEquippedItems(
        profile: profile,
        manifest: manifest,
        characterId: characterId,
        nameHash: selectedNameHash,
        iconHash: selectedIconHash,
        colorHash: selectedColorHash,
        loadoutIndex: loadoutIndex);
    await profile.snapshotLoadout(
      loadout,
    );
  }
}
