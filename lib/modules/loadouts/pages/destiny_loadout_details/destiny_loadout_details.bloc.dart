import 'package:bungie_api/src/models/destiny_loadout_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/destiny_loadout.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:provider/provider.dart';

class DestinyLoadoutDetailsBloc extends ChangeNotifier {
  final String characterId;
  final int loadoutIndex;

  @protected
  final BuildContext context;

  @protected
  final ProfileBloc profile;
  final ManifestService manifest;

  DestinyLoadoutInfo? _loadout;
  DestinyLoadoutInfo? get loadout => _loadout;

  DestinyLoadoutDetailsBloc(
    BuildContext this.context, {
    required this.characterId,
    required this.loadoutIndex,
  })  : profile = context.read<ProfileBloc>(),
        manifest = context.read<ManifestService>() {
    _init();
  }

  _init() async {
    final character = profile.getCharacterById(characterId);
    final loadout = character?.loadouts?[loadoutIndex];
    if (loadout == null) return;
    final loadoutInfo = await DestinyLoadoutInfo.fromInventory(profile, manifest, loadout, characterId, loadoutIndex);
    this._loadout = loadoutInfo;
    notifyListeners();
  }
}
