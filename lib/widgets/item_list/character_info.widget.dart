import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_class_definition.dart';
import 'package:bungie_api/models/destiny_progression.dart';
import 'package:bungie_api/models/destiny_race_definition.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/icon_fonts/destiny_icons_icons.dart';
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
    return Stack(children: [
      mainCharacterInfo(context, character),
      characterStatsInfo(context, character),
      ghostIcon(context),
      expInfo(context, character),
      Positioned.fill(
          child: FlatButton(
        child: Container(),
        onPressed: () {
          Scaffold.of(context).showBottomSheet((context) {
            return Container(
                child: RaisedButton(
              child: TranslatedTextWidget("Max Light"),
              onPressed: () {},
            ));
          });
        },
      ))
    ]);
  }

  Widget ghostIcon(BuildContext context) {
    return Positioned.fill(
        child: Container(
            width: 50,
            height: 50,
            child: Shimmer.fromColors(
                baseColor: Colors.grey.shade400,
                highlightColor: Colors.grey.shade100,
                period: Duration(seconds: 5),
                child: Icon(DestinyIcons.ghost,
                    size: 50, color: Colors.grey.shade300))));
  }

  Widget characterStatsInfo(
      BuildContext context, DestinyCharacterComponent character) {
    return Positioned(
        right: 8,
        top: 24,
        bottom: 8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Icon(
                      DestinyIcons.power,
                      color: Colors.amber.shade500,
                      size: 16,
                    )),
                Text(
                  "${character.light}",
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 34,
                      color: Colors.amber.shade500),
                )
              ],
            ),
            TranslatedTextWidget("Level {Level}",
                replace: {
                  'Level': "${character.levelProgression.level}",
                },
                style: TextStyle(fontSize: 12))
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
        top: 24,
        left: 8,
        bottom: 16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(classDef.genderedClassNames[genderType].toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
            Text(
              raceDef.genderedRaceNames[genderType],
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
            ),
            characterStats(context, character)
          ],
        ));
  }

  Widget characterStats(
      BuildContext context, DestinyCharacterComponent character) {
    List<Widget> stats = [];
    character.stats.forEach((hash, stat) {
      print(hash);
      if (hash == "${ProgressionHash.Power}") return;
      stats.add(Container(
          width: 16,
          height: 16,
          child: ManifestImageWidget<DestinyStatDefinition>(
            int.parse(hash),
            placeholder: Container(),
          )));
      stats.add(Text(
        "$stat",
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ));
      stats.add(Container(width: 4));
    });
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: stats);
  }

  Widget expInfo(BuildContext context, DestinyCharacterComponent character) {
    DestinyProgression levelProg = character.levelProgression;
    bool isMaxLevel = levelProg.level >= levelProg.levelCap;
    if (isMaxLevel) {
      levelProg = widget.profile
          .getCharacterProgression(character.characterId)
          .progressions[ProgressionHash.Overlevel];
    }

    return Positioned(
        right: 8,
        top: 4,
        child: Text(
          "${levelProg.progressToNextLevel}/${levelProg.nextLevelAt}",
          style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 11,
              fontWeight: FontWeight.bold),
        ));
  }
}
