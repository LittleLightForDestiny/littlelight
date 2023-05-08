import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'package:little_light/services/storage/export.dart';

class ObjectiveTracking extends ChangeNotifier with StorageConsumer {
  final BuildContext context;
  List<TrackedObjective>? _trackedObjectives;

  ObjectiveTracking(this.context) : super() {
    _init();
  }

  _init() async {
    await _loadTrackedObjectivesFromCache();
  }

  Future<void> _loadTrackedObjectivesFromCache() async {
    _trackedObjectives = await currentMembershipStorage.getTrackedObjectives() ?? [];
  }

  void changeTrackingStatus(TrackedObjectiveType type, int? hash,
      {String? instanceId, String? characterId, bool track = true}) {
    final isTracking = this.isTracked(type, hash, instanceId: instanceId, characterId: characterId);
    if (track == isTracking) return;
    if (track) {
      _trackedObjectives?.add(TrackedObjective(
        type: type,
        hash: hash,
        instanceId: instanceId,
        characterId: characterId,
      ));
    } else {
      _trackedObjectives?.removeWhere(
        (element) => //
            element.type == type &&
            element.hash == hash &&
            element.instanceId == instanceId &&
            element.characterId == characterId,
      );
    }
    notifyListeners();
    final objectives = _trackedObjectives;
    if (objectives != null) currentMembershipStorage.saveTrackedObjectives(objectives);
  }

  bool isTracked(TrackedObjectiveType type, int? hash, {String? instanceId, String? characterId}) {
    final found = _trackedObjectives?.firstWhereOrNull(
      (element) => //
          element.type == type &&
          element.hash == hash &&
          element.instanceId == instanceId &&
          characterId == element.characterId,
    );
    return found != null;
  }
}
