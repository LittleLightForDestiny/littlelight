import 'package:little_light/core/blocs/profile/destiny_character_info.dart';

extension DestinyCharacterInfoListHelpers on List<DestinyCharacterInfo> {
  Map<String, DestinyCharacterInfo> get asIdMap {
    final map = <String, DestinyCharacterInfo>{};
    for (final c in this) {
      final id = c.characterId;
      if (id != null) map[id] = c;
    }
    return map;
  }
}
