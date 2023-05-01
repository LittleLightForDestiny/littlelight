import 'package:bungie_api/destiny2.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';

const profileCharacterEmblemHash = 4132147349;

extension DestinyCharacterInfoData on DestinyCharacterInfo {
  String getGenderedClassName(DestinyClassDefinition? classDef) {
    return classDef?.genderedClassNamesByGenderHash?[this.character.genderHash] ??
        classDef?.displayProperties?.name ??
        "";
  }
}
