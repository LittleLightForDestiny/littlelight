import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/objective_tracking/objective_tracking.bloc.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/shared/utils/helpers/presentation_node_helpers.dart';
import 'package:provider/provider.dart';

class ObjectivesBloc extends ChangeNotifier {
  final UserSettingsBloc _userSettings;
  final ObjectiveTrackingBloc _tracking;
  final ProfileBloc _profile;
  final ManifestService _manifest;

  List<TrackedObjective>? _objectives;
  List<TrackedObjective>? get objectives => _objectives;

  Map<TrackedObjective, InventoryItemInfo>? _itemsForObjectives;
  Map<TrackedObjective, RecordProgressData>? _recordsForObjectives;

  bool _reordering = false;
  bool get reordering => _reordering;

  ObjectiveViewMode? _viewMode;
  ObjectiveViewMode get viewMode => _viewMode ?? ObjectiveViewMode.Large;

  set viewMode(ObjectiveViewMode value) {
    _viewMode = value;
    _userSettings.objectiveViewMode = value;
    notifyListeners();
  }

  ObjectivesBloc(BuildContext context)
      : this._tracking = context.read<ObjectiveTrackingBloc>(),
        _profile = context.read<ProfileBloc>(),
        _manifest = context.read<ManifestService>(),
        _userSettings = context.read<UserSettingsBloc>() {
    _init();
  }

  void _init() {
    _tracking.addListener(_update);
    _profile.addListener(_update);
    _userSettings.addListener(_settingsUpdate);
    _settingsUpdate();
    _update();
  }

  @override
  void dispose() {
    _tracking.removeListener(_update);
    _profile.removeListener(_update);
    _userSettings.removeListener(_settingsUpdate);
    super.dispose();
  }

  void _settingsUpdate() {
    _viewMode = _userSettings.objectiveViewMode;
    notifyListeners();
  }

  void _update() async {
    final objectives = <TrackedObjective>[];
    final tracked = _tracking.trackedObjectives;
    final allItems = _profile.allItems;
    final itemsForObjectives = <TrackedObjective, InventoryItemInfo>{};
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
          if (item != null) {
            objectives.add(objective);
            itemsForObjectives[objective] = item;
          }
          break;
        case TrackedObjectiveType.Plug:
          break;
        case TrackedObjectiveType.Questline:
          final def = await _manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
          final hashes = def?.setData?.itemList?.map((e) => e.itemHash);
          final item = allItems.firstWhereOrNull(
            (element) => (hashes?.contains(element.itemHash) ?? false) && element.characterId == objective.characterId,
          );
          if (item != null) {
            objectives.add(objective);
            itemsForObjectives[objective] = item;
          }
          break;
      }
    }
    this._objectives = objectives;
    this._itemsForObjectives = itemsForObjectives;
    notifyListeners();
  }

  InventoryItemInfo? getItem(TrackedObjective objective) {
    final key = _itemsForObjectives?.keys.firstWhereOrNull(
      (element) =>
          element.characterId == objective.characterId && //
          element.hash == objective.hash &&
          element.instanceId == objective.instanceId &&
          element.parentHash == objective.parentHash,
    );
    if (key == null) return null;
    return _itemsForObjectives?[key];
  }

  RecordProgressData? getRecord(TrackedObjective objective) {
    final key = _itemsForObjectives?.keys.firstWhereOrNull(
      (element) =>
          element.characterId == objective.characterId && //
          element.hash == objective.hash &&
          element.instanceId == objective.instanceId &&
          element.parentHash == objective.parentHash,
    );
    if (key == null) return null;
    return _recordsForObjectives?[key];
  }

  void toggleReordering() {
    _reordering = !_reordering;
    notifyListeners();
  }

  void reorderObjectives(int oldIndex, int newIndex) async {
    final order = _objectives;
    if (order == null) return;
    final removed = order.removeAt(oldIndex);
    if (newIndex > oldIndex) newIndex = newIndex - 1;
    order.insert(newIndex, removed);
    this._objectives = order;
    notifyListeners();
    await _tracking.updateOrder(order);
  }
}
