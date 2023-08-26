import 'package:bungie_api/destiny2.dart';
import 'package:little_light/utils/destiny_data.dart';

class DestinyCharacterInfo {
  DestinyCharacterComponent character;
  DestinyCharacterProgressionComponent? progression;
  int? armorPower;
  int? artifactPower;
  int? totalPower;
  DestinyCharacterActivitiesComponent? activities;

  String? get characterId => character.characterId;

  DestinyCharacterInfo(
    this.character, {
    this.progression,
    this.activities,
  });

  Map<String, DestinyStat>? get stats {
    final stats = character.stats;
    if (stats == null) return null;
    final result = stats.map((key, value) {
      final stat = DestinyStat()
        ..statHash = int.parse(key)
        ..value = value;
      return MapEntry(key, stat);
    });
    result.remove("${ProgressionHash.Power}");
    return result;
  }
}
