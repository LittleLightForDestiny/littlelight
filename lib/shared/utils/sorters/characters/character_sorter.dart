import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/models/character_sort_parameter.dart';

import 'character_first_created_sorter.dart';
import 'character_last_created_sorter.dart';
import 'character_last_played_sorter.dart';

typedef CharacterSorter = int Function(DestinyCharacterInfo charA, DestinyCharacterInfo charB);

List<DestinyCharacterInfo> sortCharacters(CharacterSortParameterType sortType, List<DestinyCharacterInfo> original) {
  final result = List<DestinyCharacterInfo>.from(original);
  final sortFunction = _getCharacterSortFunction(sortType);
  result.sort(sortFunction);
  return result;
}

CharacterSorter _getCharacterSortFunction(CharacterSortParameterType sortType) {
  switch (sortType) {
    case CharacterSortParameterType.LastPlayed:
      return sortCharacterByLastPlayed;
    case CharacterSortParameterType.FirstCreated:
      return sortCharacterByFirstCreated;
    case CharacterSortParameterType.LastCreated:
      return sortCharacterByLastCreated;
    case CharacterSortParameterType.Custom:
      throw ("Not implemented yet");
  }
}
