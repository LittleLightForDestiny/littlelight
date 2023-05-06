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

  void changeTrackingStatus(TrackedObjectiveType type, int? hash, {String? instanceId, bool track = true}) {
    final isTracking = this.isTracked(type, hash, instanceId: instanceId);
    if (track == isTracking) return;
    if (track) {
      _trackedObjectives?.add(TrackedObjective(type: type, hash: hash, instanceId: instanceId));
    } else {
      _trackedObjectives
          ?.removeWhere((element) => element.type == type && element.hash == hash && element.instanceId == instanceId);
    }
    notifyListeners();
    final objectives = _trackedObjectives;
    if (objectives != null) currentMembershipStorage.saveTrackedObjectives(objectives);
  }

  bool isTracked(TrackedObjectiveType type, int? hash, {String? instanceId}) {
    final found = _trackedObjectives?.firstWhereOrNull(
      (element) => element.type == type && element.hash == hash && element.instanceId == instanceId,
    );
    return found != null;
  }
}
