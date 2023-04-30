import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'package:little_light/services/storage/export.dart';

class TrackingBloc extends ChangeNotifier with StorageConsumer {
  final BuildContext context;
  List<TrackedObjective>? _trackedObjectives;

  TrackingBloc(this.context) : super() {
    _init();
  }

  _init() async {
    await _loadTrackedObjectivesFromCache();
  }

  Future<void> _loadTrackedObjectivesFromCache() async {
    _trackedObjectives = await currentMembershipStorage.getTrackedObjectives() ?? [];
  }

  bool isTracked(TrackedObjectiveType type, int? hash) {
    final found = _trackedObjectives?.firstWhereOrNull((element) => element.type == type && element.hash == hash);
    return found != null;
  }
}
