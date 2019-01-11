import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_class_definition.dart';
import 'package:bungie_api/models/destiny_race_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/icon-fonts/destiny_icons_icons.dart';
import 'package:shimmer/shimmer.dart';

class CharacterInfoWidget extends StatefulWidget {
  final ManifestService manifest = new ManifestService();
  final ProfileService profile = new ProfileService();
  final String characterId;
  CharacterInfoWidget({this.characterId});

  @override
  State<StatefulWidget> createState() {
    return CharacterInfoWidgetState();
  }
}

class CharacterInfoWidgetState extends State<CharacterInfoWidget> {
  DestinyClassDefinition classDef;
  DestinyRaceDefinition raceDef;
  DestinyCharacterComponent character;

  @override
  void initState() {
    character = widget.profile.getCharacter(widget.characterId);
    super.initState();
    loadDefinitions();
  }

  loadDefinitions() async {
    classDef = await widget.manifest.getClassDefinition(character.classHash);
    raceDef = await widget.manifest.getRaceDefinition(character.raceHash);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8),
        child: Stack(children: [
          mainCharacterInfo(context, character),
          characterStatsInfo(context, character),
        ]));
  }

  Widget characterStatsInfo(
      BuildContext context, DestinyCharacterComponent character) {
    return Positioned(
        right: 8,
        top: 8,
        bottom: 8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding:EdgeInsets.only(top:8),
                  child:Icon(
                  DestinyIcons.power,
                  color: Colors.amber.shade500,
                  size: 16,
                )),
                Text(
                  "${character.light}",
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 32,
                      color: Colors.amber.shade500),
                )
              ],
            ),
            TranslatedTextWidget("Level {Level}", replace: {'Level':"${character.levelProgression.level}"},)
          ],
        ));
  }

  Widget mainCharacterInfo(
      BuildContext context, DestinyCharacterComponent character) {
    if (classDef == null || raceDef == null) {
      return Container();
    }
    String genderType = character.genderType == 0 ? "Male" : "Female";
    return Positioned(
        left: 8,
        top: 8,
        bottom: 8,
        child: Shimmer.fromColors(
            period: Duration(seconds: 3),
            baseColor: Colors.grey.shade400,
            highlightColor: Colors.white,
            child: Row(
              children: [
                Padding(
                  child: Icon(DestinyData.getClassIcon(character.classType),
                      size: 50),
                  padding: EdgeInsets.all(8),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(classDef.genderedClassNames[genderType].toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 24)),
                    Text(
                      raceDef.genderedRaceNames[genderType],
                      style: TextStyle(fontWeight: FontWeight.w300),
                    )
                  ],
                )
              ],
            )));
  }
}
