import 'package:little_light/core/blocs/profile/destiny_character_info.dart';

int sortCharacterByFirstCreated(
    DestinyCharacterInfo charA, DestinyCharacterInfo charB) {
  return charA.character.characterId
          ?.compareTo(charB.character.characterId ?? "") ??
      0;
}
