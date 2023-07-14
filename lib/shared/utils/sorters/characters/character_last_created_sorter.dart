import 'package:little_light/core/blocs/profile/destiny_character_info.dart';

int sortCharacterByLastCreated(
    DestinyCharacterInfo charA, DestinyCharacterInfo charB) {
  return charB.character.characterId
          ?.compareTo(charA.character.characterId ?? "") ??
      0;
}
