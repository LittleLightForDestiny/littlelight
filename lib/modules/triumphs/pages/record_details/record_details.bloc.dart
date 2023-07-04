import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/shared/utils/helpers/character_info_helpers.dart';
import 'package:little_light/shared/utils/helpers/presentation_node_helpers.dart';
import 'package:provider/provider.dart';

class RecordDetailsBloc extends ChangeNotifier {
  @protected
  final ProfileBloc profileBloc;
  @protected
  final ManifestService manifestBloc;

  int _recordHash;
  int get recordHash => _recordHash;

  Map<String, DestinyCharacterInfo>? _characters;
  Map<String, DestinyCharacterInfo>? get characters => _characters;

  RecordProgressData? _progress;
  RecordProgressData? get progress => _progress;

  RecordDetailsBloc(BuildContext context, int recordHash)
      : this._recordHash = recordHash,
        profileBloc = context.read<ProfileBloc>(),
        manifestBloc = context.read<ManifestService>(),
        super() {
    _init();
  }

  _init() {
    profileBloc.addListener(_update);
    _update();
  }

  void _update() async {
    final recordData = getRecordData(profileBloc, recordHash);
    this._progress = recordData;

    final characters = profileBloc.characters?.asIdMap;
    this._characters = characters;
    notifyListeners();
  }

  @override
  void dispose() {
    profileBloc.removeListener(_update);
    super.dispose();
  }
}
