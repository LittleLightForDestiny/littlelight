import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_class_definition.dart';
import 'package:bungie_api/models/destiny_race_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';

class CharacterInfoWidget extends StatelessWidget {
  final ManifestService manifest = new ManifestService();
  final ProfileService profile = new ProfileService();
  final String characterId;
  CharacterInfoWidget({this.characterId});
  
  @override
  Widget build(BuildContext context) {
    DestinyCharacterComponent character = this.profile.getCharacter(characterId);
    DestinyClassDefinition classDef = manifest.getClassDefinition(character.classHash);
    DestinyRaceDefinition raceDef = manifest.getRaceDefinition(character.raceHash);
    String genderType = character.genderType == 0 ? "Male": "Female";
    return Container(
      padding:EdgeInsets.all(8),
      child:Row(
        children:[
          Column(children: <Widget>[
            Text(classDef.genderedClassNames[genderType]),
            Text(raceDef.genderedRaceNames[genderType])
          ],),
          Column(children: <Widget>[
            Text("${character.light}"),
            Text("${character.baseCharacterLevel}")
          ],)
        ]
      )
    );    
  }
}