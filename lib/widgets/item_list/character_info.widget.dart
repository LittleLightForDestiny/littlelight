import 'dart:async';

import 'dart:math' as math;

import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_class_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_progression.dart';
import 'package:bungie_api/models/destiny_progression_definition.dart';
import 'package:bungie_api/models/destiny_race_definition.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/icon_fonts/destiny_icons_icons.dart';
import 'package:little_light/widgets/option_sheets/character_options_sheet.widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:speech_bubble/speech_bubble.dart';

class CharacterInfoWidget extends StatefulWidget {
  final ManifestService manifest = new ManifestService();
  final ProfileService profile = new ProfileService();
  final String characterId;
  final NotificationService broadcaster = NotificationService();

  CharacterInfoWidget({this.characterId, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CharacterInfoWidgetState();
  }
}

class CharacterInfoWidgetState<T extends CharacterInfoWidget> extends State<T> {
  DestinyClassDefinition classDef;
  DestinyRaceDefinition raceDef;
  DestinyCharacterComponent character;
  StreamSubscription<NotificationEvent> subscription;

  DestinyProgressionDefinition legendProgressionDefinition;

  @override
  void initState() {
    character = widget.profile.getCharacter(widget.characterId);
    super.initState();
    loadDefinitions();
    subscription = widget.broadcaster.listen((event) {
      if (event.type == NotificationType.receivedUpdate && mounted) {
        character = widget.profile.getCharacter(widget.characterId);
        setState(() {});
      }
    });
  }

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }

  loadDefinitions() async {
    classDef = await widget.manifest
        .getDefinition<DestinyClassDefinition>(character.classHash);
    raceDef = await widget.manifest
        .getDefinition<DestinyRaceDefinition>(character.raceHash);
    legendProgressionDefinition = await widget.manifest
        .getDefinition<DestinyProgressionDefinition>(ProgressionHash.Legend);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      mainCharacterInfo(context, character),
      characterStatsInfo(context, character),
      expInfo(context, character),
      currencyInfo(context),
      Positioned.fill(child: ghostIcon(context)),
      Positioned.fill(
          child: FlatButton(
              child: Container(),
              onPressed: () {
                UserSettingsService().hasTappedGhost = true;
                setState(() {});
                showOptionsSheet(context);
              }))
    ]);
  }

  showOptionsSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return CharacterOptionsSheet(
            character: character,
          );
        });
  }

  Widget currencyInfo(BuildContext context) {
    var currencies = widget.profile.getProfileCurrencies();
    if (currencies == null) {
      return Container();
    }
    return Positioned(
        left: 8,
        bottom: 0,
        right: 8,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: currencies.map((c) => buildCurrency(context, c)).toList(),
        ));
  }

  Widget buildCurrency(BuildContext context, DestinyItemComponent currency) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 16, right: 4),
          width: 16,
          height: 16,
          child: ManifestImageWidget<DestinyInventoryItemDefinition>(
              currency.itemHash),
        ),
        Text(
          "${currency.quantity}",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  Widget ghostIcon(BuildContext context) {
    var ghost = Container(
        width: 50,
        height: 50,
        child: Shimmer.fromColors(
            baseColor: Colors.grey.shade400,
            highlightColor: Colors.grey.shade100,
            period: Duration(seconds: 5),
            child: Icon(DestinyIcons.ghost,
                size: 50, color: Colors.grey.shade300)));
    if (UserSettingsService().hasTappedGhost) {
      return ghost;
    }
    return Stack(children: [
      Center(
        child: ghost,
      ),
      Container(
          margin: EdgeInsets.only(top: 60),
          child: SpeechBubble(
            nipLocation: NipLocation.TOP,
            color: Colors.lightBlue,
            child: TranslatedTextWidget("Hey, tap me!"),
          ))
    ]);
  }

  Widget characterStatsInfo(
      BuildContext context, DestinyCharacterComponent character) {
    var artifactLevel =
        widget.profile.getArtifactProgression()?.powerBonus ?? 0;
    var armorLevel = character.light - artifactLevel;
    return Positioned(
        right: 8,
        top: 0,
        bottom: 0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                  key: Key("${character.light}"),
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 34,
                      color: Colors.amber.shade500),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Text(
                  "$armorLevel",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                artifactLevel == 0
                    ? Container()
                    : Text(" +$artifactLevel",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.cyanAccent))
              ],
            )
          ],
        ));
  }

  Widget mainCharacterInfo(
      BuildContext context, DestinyCharacterComponent character) {
    if (classDef == null || raceDef == null) {
      return Container();
    }
    return Positioned(
        top: 0,
        left: 8,
        bottom: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
                classDef
                    .genderedClassNamesByGenderHash["${character.genderHash}"]
                    .toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
            Container(height: 2),
            Text(
              raceDef.genderedRaceNamesByGenderHash["${character.genderHash}"],
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
            ),
            Container(height: 2),
            characterStats(context, character)
          ],
        ));
  }

  Widget characterStats(
      BuildContext context, DestinyCharacterComponent character) {
    List<Widget> stats = [];
    character.stats.forEach((hash, stat) {
      if (hash == "${ProgressionHash.Power}") return;
      stats.add(
        Container(
          margin: EdgeInsets.only(right:4, bottom:2),
          child: Row(children: [
        Container(
          margin: EdgeInsets.only(right:2),
            width: 16,
            height: 16,
            child: ManifestImageWidget<DestinyStatDefinition>(
              int.parse(hash),
              placeholder: Container(),
            )),
        Text(
          "$stat",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        )
      ])));
    });
    return Column(children: [
      Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: stats.take(3).toList()),
      Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: stats.skip(3).toList())
    ]);
  }

  Widget expInfo(BuildContext context, DestinyCharacterComponent character) {
    DestinyProgression levelProg = character.levelProgression;
    bool isMaxLevel = levelProg.level >= levelProg.levelCap;
    if (isMaxLevel) {
      levelProg = widget.profile
          .getCharacterProgression(character.characterId)
          .progressions["${ProgressionHash.Legend}"];
    }

    return Positioned(
        right: 8,
        top: 4,
        child: Row(children: [
          isWellRested
              ? Container(
                  // width: 16,
                  // height: 16,
                  // child: ManifestImageWidget<DestinySandboxPerkDefinition>(
                  //     1519921522),
                  )
              : Container(),
          Container(
            width: 4,
          ),
          Text(
            "${levelProg.progressToNextLevel}/${levelProg.nextLevelAt}",
            style: TextStyle(
                color: Colors.grey.shade300,
                fontSize: 11,
                fontWeight: FontWeight.bold),
          )
        ]));
  }

  DestinyProgression get legendProgression => widget.profile
      .getCharacterProgression(character.characterId)
      .progressions["${ProgressionHash.Legend}"];

  bool get isWellRested =>
      character.levelProgression.level >= character.levelProgression.levelCap &&
      legendProgression.level > 3 &&
      legendProgression.weeklyProgress < wellRestedTotal;

  int get wellRestedTotal {
    if (legendProgressionDefinition == null) {
      return 0;
    }
    return [0, 1, 2].fold<int>(0, (total, levelOffset) {
      var step = math.min(math.max(legendProgression.level - levelOffset, 0),
          legendProgressionDefinition.steps.length - 1);
      return total + legendProgressionDefinition.steps[step].progressTotal;
    });
  }
}
