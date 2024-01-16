import 'dart:math';

import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/destiny_loadout.dart';
import 'package:little_light/modules/loadouts/pages/destiny_loadout_details/destiny_loadout_details.page_route.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:provider/provider.dart';

class SaveDestinyLoadoutQuickmenuBloc extends ChangeNotifier {
  @protected
  final ProfileBloc profileBloc;

  @protected
  final ManifestService manifest;

  @protected
  final InventoryBloc inventory;

  final BuildContext _context;
  final DestinyCharacterInfo character;

  List<DestinyLoadoutInfo>? _destinyLoadouts;
  List<DestinyLoadoutInfo>? get destinyLoadouts => _destinyLoadouts;

  List<int>? _selectedBuckets;
  List<int>? get selectedBuckets => _selectedBuckets;

  int _freeSlots = 0;
  int get freeSlots => _freeSlots;
  set freeSlots(int value) {
    _freeSlots = value;
    notifyListeners();
  }

  SaveDestinyLoadoutQuickmenuBloc(this._context, this.character)
      : profileBloc = _context.read<ProfileBloc>(),
        manifest = _context.read<ManifestService>(),
        inventory = _context.read<InventoryBloc>(),
        super() {
    _init();
  }

  _init() {
    profileBloc.addListener(_updateDestinyLoadouts);
    _updateDestinyLoadouts();
  }

  @override
  void dispose() {
    profileBloc.removeListener(_updateDestinyLoadouts);
    super.dispose();
  }

  void _updateDestinyLoadouts() async {
    this._destinyLoadouts = await _getDestinyLoadouts();
    notifyListeners();
  }

  Future<List<DestinyLoadoutInfo>?> _getDestinyLoadouts() async {
    final characterId = character.characterId;
    if (characterId == null) return null;
    final loadouts = profileBloc.getCharacterById(characterId)?.loadouts;
    if (loadouts == null) {
      return null;
    }
    final mappedLoadouts = <DestinyLoadoutInfo>[];
    for (final (i, l) in loadouts.indexed) {
      final loadout = await DestinyLoadoutInfo.fromInventory(profileBloc, manifest, l, characterId, i);
      mappedLoadouts.add(loadout);
    }
    return mappedLoadouts;
  }

  void saveLoadout(DestinyLoadoutInfo loadout) async {
    final loadoutConstants = await manifest.getDefinition<DestinyLoadoutConstantsDefinition>(1);
    final availableNameHashes = loadoutConstants?.loadoutNameHashes;
    final availableIconHashes = loadoutConstants?.loadoutIconHashes;
    final availableColorHashes = loadoutConstants?.loadoutColorHashes;
    final characterId = loadout.characterId;

    if (availableNameHashes == null || availableIconHashes == null || availableColorHashes == null) {
      return;
    }

    final oldLoadout = loadout.loadout;
    int? nameHash = oldLoadout.nameHash;
    int? iconHash = oldLoadout.iconHash;
    int? colorHash = oldLoadout.colorHash;
    final isNameValid = availableNameHashes.contains(nameHash);
    final isIconValid = availableNameHashes.contains(iconHash);
    final isColorValid = availableColorHashes.contains(colorHash);

    if (!isNameValid) {
      final nameIndex = Random().nextInt(availableNameHashes.length);
      nameHash = availableNameHashes[nameIndex];
    }

    if (!isIconValid) {
      final iconIndex = Random().nextInt(availableIconHashes.length);
      iconHash = availableIconHashes[iconIndex];
    }

    if (!isColorValid) {
      final colorIndex = Random().nextInt(availableColorHashes.length);
      colorHash = availableColorHashes[colorIndex];
    }
    final validBucketHashes = [
      InventoryBucket.subclass,
      ...InventoryBucket.weaponBucketHashes,
      ...InventoryBucket.armorBucketHashes,
    ];
    final equipped = profileBloc.allInstancedItems.where((i) {
      final isEquipped = i.isEquipped ?? false;
      if (!isEquipped) return false;
      if (i.characterId != character.characterId) return false;
      if (!validBucketHashes.contains(i.bucketHash)) return false;
      return true;
    });

    final items = equipped
        .map(
          (e) => DestinyLoadoutItemComponent()
            ..itemInstanceId = e.instanceId
            ..plugItemHashes = e.sockets?.map((e) => e.plugHash ?? 0).toList(),
        )
        .toList();

    final newLoadout = DestinyLoadoutComponent()
      ..nameHash = nameHash
      ..iconHash = iconHash
      ..colorHash = colorHash
      ..items = items;
    final newLoadoutInfo =
        await DestinyLoadoutInfo.fromInventory(profileBloc, manifest, newLoadout, characterId, loadout.index);

    await profileBloc.snapshotLoadout(newLoadoutInfo);
    notifyListeners();
  }

  void editLoadout(DestinyLoadoutInfo loadout) async {
    Navigator.of(_context)
        .pushReplacement(DestinyLoadoutDetailsPageRoute(loadoutIndex: loadout.index, characterId: loadout.characterId));
  }

  void cancel() {
    Navigator.of(_context).pop();
  }
}
