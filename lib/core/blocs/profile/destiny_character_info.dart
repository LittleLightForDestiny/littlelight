import 'package:bungie_api/destiny2.dart';

class DestinyCharacterInfo {
  DestinyCharacterComponent character;
  DestinyCharacterProgressionComponent? progression;

  String? get characterId => character.characterId;

  DestinyCharacterInfo(
    this.character, {
    this.progression,
  });
}
