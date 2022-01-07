

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/services/storage/export.dart';

class ObjectivesService with StorageConsumer, ProfileConsumer, ManifestConsumer {
  static final ObjectivesService _singleton = new ObjectivesService._internal();
  factory ObjectivesService() {
    return _singleton;
  }
  ObjectivesService._internal();

  List<TrackedObjective> _trackedObjectives;

  reset() {
    _trackedObjectives = null;
  }

  Future<List<TrackedObjective>> getTrackedObjectives() async {
    if (_trackedObjectives == null) {
      await _loadTrackedObjectivesFromCache();
    }
    var dirty = false;
    var itemObjectives = _trackedObjectives
        .where((o) => o.type == TrackedObjectiveType.Item)
        .toList();
    var plugObjectives = _trackedObjectives
        .where((o) => o.type == TrackedObjectiveType.Plug)
        .toList();
    for (var o in itemObjectives) {
      DestinyItemComponent item = await findObjectiveItem(o);
      if (item == null) {
        _trackedObjectives.remove(o);
        dirty = true;
      } else if (item?.itemHash != o.hash ||
          item?.itemInstanceId != o.instanceId) {
        o.hash = item.itemHash;
        o.instanceId = item.itemInstanceId;
        dirty = true;
      }
    }
    for (var o in plugObjectives) {
      DestinyItemComponent item = await findObjectivePlugItem(o);
      if (item == null) {
        _trackedObjectives.remove(o);
        dirty = true;
      }
    }
    if (dirty) {
      _saveTrackedObjectives();
    }
    return _trackedObjectives;
  }

  Future<DestinyItemComponent> findObjectiveItem(
      TrackedObjective objective) async {

    DestinyItemComponent item;
    if (objective.instanceId != null) {
      item = profile.getCharacterInventory(objective.characterId).firstWhere(
          (i) => i.itemInstanceId == objective.instanceId,
          orElse: () => null);
    } else {
      item = profile
          .getCharacterInventory(objective.characterId)
          .firstWhere((i) => i.itemHash == objective.hash, orElse: () => null);
    }

    if (item != null) return item;
    var items = profile.getItemsByInstanceId([objective.instanceId]);
    if (items.length > 0) return items.first;
    var def = await manifest
        .getDefinition<DestinyInventoryItemDefinition>(objective.hash);
    if (def?.objectives?.questlineItemHash != null) {
      var questline =
          await manifest.getDefinition<DestinyInventoryItemDefinition>(
              def.objectives.questlineItemHash);
      var questStepHashes =
          questline?.setData?.itemList?.map((i) => i.itemHash)?.toList() ?? [];
      var item = profile
          .getCharacterInventory(objective.characterId)
          .firstWhere((i) => questStepHashes.contains(i.itemHash),
              orElse: () => null);
      if (item != null) return item;
    }
    return null;
  }

  Future<DestinyItemComponent> findObjectivePlugItem(
      TrackedObjective objective) async {

    var items = profile.getAllItems();
    var item = items.firstWhere((i) => i.itemHash == objective.parentHash,
        orElse: () => null);
    if (item == null) return null;
    var plugObjective = profile.getPlugObjectives(item?.itemInstanceId);
    if(plugObjective?.containsKey("${objective.hash}") ?? false){
      return item;
    }
    return null;
  }

  Future<List<TrackedObjective>> _loadTrackedObjectivesFromCache() async {
    List<dynamic> json = await currentMembershipStorage.getTrackedObjectives();

    if (json != null) {
      List<TrackedObjective> objectives =
          json.map((j) => TrackedObjective.fromJson(j)).toList();
      this._trackedObjectives = objectives;
      return this._trackedObjectives;
    }

    this._trackedObjectives = [];
    return this._trackedObjectives;
  }

  Future<void> addTrackedObjective(TrackedObjectiveType type, int hash,
      {String instanceId, String characterId, int parentHash}) async {
    var found = _trackedObjectives.firstWhere(
        (o) =>
            o.type == type &&
            o.hash == hash &&
            o.instanceId == instanceId &&
            characterId == o.characterId,
        orElse: () => null);
    if (found == null) {
      _trackedObjectives.add(TrackedObjective(
          type: type,
          hash: hash,
          instanceId: instanceId,
          characterId: characterId,
          parentHash: parentHash));
    }
    await _saveTrackedObjectives();
  }

  Future<void> removeTrackedObjective(TrackedObjectiveType type, int hash,
      {String instanceId, String characterId}) async {
    _trackedObjectives.removeWhere((o) =>
        o.type == type &&
        o.hash == hash &&
        o.instanceId == instanceId &&
        o.characterId == characterId);
    await _saveTrackedObjectives();
  }

  Future<void> _saveTrackedObjectives() async {
    await currentMembershipStorage.saveTrackedObjectives(_trackedObjectives);
  }
}
