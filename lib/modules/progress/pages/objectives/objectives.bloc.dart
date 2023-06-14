import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/objective_tracking/objective_tracking.bloc.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:provider/provider.dart';

class ObjectivesBloc extends ChangeNotifier {
  final ObjectiveTrackingBloc _tracking;
  final ProfileBloc _profile;
  final ManifestService _manifest;

  List<TrackedObjective>? _objectives;
  List<TrackedObjective>? get objectives => _objectives;

  ObjectivesBloc(BuildContext context)
      : this._tracking = context.read<ObjectiveTrackingBloc>(),
        _profile = context.read<ProfileBloc>(),
        _manifest = context.read<ManifestService>() {
    _init();
  }

  void _init() {
    _tracking.addListener(_update);
    _profile.addListener(_update);
    _update();
  }

  void _update() async {
    final objectives = <TrackedObjective>[];
    final tracked = _tracking.trackedObjectives;
    final allItems = _profile.allItems;
    if (tracked == null) return;
    for (final objective in tracked) {
      final hash = objective.hash;
      switch (objective.type) {
        case TrackedObjectiveType.Triumph:
          final def = await _manifest.getDefinition<DestinyRecordDefinition>(hash);
          if (def != null) objectives.add(objective);
          break;
        case TrackedObjectiveType.Item:
          final item = allItems.firstWhereOrNull((element) {
            if (objective.instanceId != null) return element.instanceId == objective.instanceId;
            return element.itemHash == objective.hash && element.characterId == objective.characterId;
          });
          if (item != null) objectives.add(objective);
          break;
        case TrackedObjectiveType.Plug:
          break;
        case TrackedObjectiveType.Questline:
          final def = await _manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
          final hashes = def?.setData?.itemList?.map((e) => e.itemHash);
          final item = allItems.firstWhereOrNull(
            (element) => element.characterId == objective.characterId && (hashes?.contains(element.itemHash) ?? false),
          );
          if (item != null) objectives.add(objective);
          break;
      }
      this._objectives = objectives;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _tracking.removeListener(_update);
    _profile.removeListener(_update);
    super.dispose();
  }
}
