import 'package:bungie_api/destiny2.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:collection/collection.dart';

/// TODO: implement this properly without relying on hardcoded hashes
const _deepsightResonanceHashes = [213377779, 2400712188, 3632593563];
const _shapedWeaponHashes = [659359923, 1922808508, 4029346515];

mixin DeepSightHelper {
  int? getDeepSightHash(String itemInstanceID) {
    final profile = getInjectedProfileService();
    final plugObjectives = profile.getPlugObjectives(itemInstanceID);
    if (plugObjectives == null) return null;
    final availableHashes = plugObjectives.keys;
    const itemHashes = _deepsightResonanceHashes;
    return itemHashes.firstWhereOrNull(
        (element) => availableHashes.contains(element.toString()));
  }

  int? getShapedWeaponHash(String itemInstanceID) {
    final profile = getInjectedProfileService();
    final plugObjectives = profile.getPlugObjectives(itemInstanceID);
    if (plugObjectives == null) return null;
    final availableHashes = plugObjectives.keys;
    const itemHashes = _shapedWeaponHashes;
    return itemHashes.firstWhereOrNull(
        (element) => availableHashes.contains(element.toString()));
  }

  bool isShapedWeaponOrDeepsight(String itemInstanceID) {
    final profile = getInjectedProfileService();
    final plugObjectives = profile.getPlugObjectives(itemInstanceID);
    if (plugObjectives == null) return false;
    final availableHashes = plugObjectives.keys;
    final itemHashes = _deepsightResonanceHashes + _shapedWeaponHashes;
    return itemHashes
        .any((element) => availableHashes.contains(element.toString()));
  }

  List<DestinyObjectiveProgress>? getShapedWeaponObjectives(
      String itemInstanceID) {
    final profile = getInjectedProfileService();
    final plugObjectives = profile.getPlugObjectives(itemInstanceID);
    if (plugObjectives == null) return null;
    final availableHashes = plugObjectives.keys;
    final hash = _shapedWeaponHashes
        .firstWhereOrNull((h) => availableHashes.contains(h.toString()));
    if (hash != null) return plugObjectives["$hash"];
    return null;
  }

  List<DestinyObjectiveProgress>? getDeepSightObjectives(
      String itemInstanceID) {
    final profile = getInjectedProfileService();
    final plugObjectives = profile.getPlugObjectives(itemInstanceID);
    if (plugObjectives == null) return null;
    final availableHashes = plugObjectives.keys;
    final hash = _deepsightResonanceHashes
        .firstWhereOrNull((h) => availableHashes.contains(h.toString()));
    if (hash != null) return plugObjectives["$hash"];
    return null;
  }

  bool isDeepSightObjectiveCompleted(String itemInstanceID) {
    final objectives = getDeepSightObjectives(itemInstanceID);
    if (objectives == null) return false;
    final attunementHashes = [3240093512, 1162857131, 3574180408];
    return objectives
            .firstWhereOrNull((o) => attunementHashes.contains(o.objectiveHash))
            ?.complete ??
        false;
  }
}
