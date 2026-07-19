import 'package:little_light/core/blocs/profile/destiny_character_info.dart';

int sortCharacterByLastPlayed(DestinyCharacterInfo charA, DestinyCharacterInfo charB) {
  DateTime dateA = DateTime.tryParse(charA.character.dateLastPlayed ?? "") ?? DateTime.fromMillisecondsSinceEpoch(0);
  DateTime dateB = DateTime.tryParse(charB.character.dateLastPlayed ?? "") ?? DateTime.fromMillisecondsSinceEpoch(0);
  return dateB.compareTo(dateA);
}
