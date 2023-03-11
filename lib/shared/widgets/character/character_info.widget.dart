import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/profile/destiny_settings.consumer.dart';
import 'package:little_light/shared/widgets/stats/small_armor_stats.widget.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/icon_fonts/littlelight_icons.dart';

const _wellRestedProgression = 2352765282;

class CharacterInfoWidget extends StatelessWidget with DestinySettingsConsumer {
  final DestinyCharacterInfo character;
  final List<DestinyItemComponent>? currencies;

  const CharacterInfoWidget(
    this.character, {
    this.currencies,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      buildSeasonalRankRow(context),
      SizedBox(height: 4),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildCharacterDetails(context),
          buildPowerLevel(context),
        ],
      ),
      Expanded(child: SizedBox()),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          buildStats(context),
          Expanded(child: buildCurrencies(context)),
        ],
      ),
      SizedBox(height: 4),
    ]);
  }

  Widget buildCurrencies(BuildContext context) {
    final currencies = this.currencies;
    if (currencies == null) return Container();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: currencies.reversed
          .map((e) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: ManifestImageWidget<DestinyInventoryItemDefinition>(e.itemHash),
                    width: 16,
                    height: 16,
                  ),
                  Container(
                    width: 4,
                  ),
                  Text("${e.quantity}"),
                  Container(width: 8),
                ].reversed.toList(),
              ))
          .toList(),
    );
  }

  Widget buildCharacterDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildClassName(context),
        SizedBox(height: 2),
        buildRaceName(context),
      ].whereType<Widget>().toList(),
    );
  }

  Widget buildClassName(BuildContext context) {
    return ManifestText<DestinyClassDefinition>(
      character.character.classHash,
      textExtractor: (def) => def.genderedClassNamesByGenderHash?["${character.character.genderHash}"],
      style: context.textTheme.largeTitle,
    );
  }

  Widget buildRaceName(BuildContext context) {
    return ManifestText<DestinyRaceDefinition>(
      character.character.raceHash,
      textExtractor: (def) => def.genderedRaceNamesByGenderHash?["${character.character.genderHash}"],
      style: context.textTheme.body,
    );
  }

  Widget buildStats(BuildContext context) {
    final stats = character.stats;
    if (stats == null) return SizedBox();
    return SmallArmorStatsWidget(
      stats,
      textWidth: 22,
    );
  }

  Widget buildSeasonalRankRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          buildWellRested(context),
          SizedBox(width: 4),
          buildSeasonalRank(context),
          SizedBox(width: 4),
          buildSeasonalRankProgress(context),
        ].whereType<Widget>().toList(),
      ),
    );
  }

  Widget buildSeasonalRank(BuildContext context) {
    final progressionHash = destinySettings.seasonalRankProgressionHash;
    final levelProg = character.progression?.progressions?["$progressionHash"];
    final overLevelProg =
        character.progression?.progressions?["${destinySettings.seasonalPrestigeRankProgressionHash}"];
    int level = levelProg?.level ?? 0;
    int overlevel = overLevelProg?.level ?? 0;
    int progress = level + overlevel;
    return Text(
      "Seasonal Rank {rank}".translate(context, replace: {"rank": "$progress"}),
      style: context.textTheme.caption,
    );
  }

  Widget? buildWellRested(BuildContext context) {
    final progressionHash = destinySettings.seasonalRankProgressionHash;
    final levelProg = character.progression?.progressions?["$progressionHash"];
    final overLevelProg =
        character.progression?.progressions?["${destinySettings.seasonalPrestigeRankProgressionHash}"];
    final currentProg = (levelProg?.level ?? 0) < (levelProg?.levelCap ?? 0) ? levelProg : overLevelProg;
    final hash = currentProg?.progressionHash;
    if (hash == null) return null;
    final wellRestedLevels = 5;
    return DefinitionProviderWidget<DestinyProgressionDefinition>(hash, (definition) {
      if (definition == null) return Container();
      final progLevel = currentProg?.level ?? 0;
      final minLevel = 0;
      final maxLevel = (definition.steps?.length ?? 100) - 1;
      final currentLevel = progLevel.clamp(minLevel, maxLevel);
      final weeklyProgress = currentProg?.weeklyProgress ?? 0;
      int levelAtStartOfTheWeek = currentLevel;
      int progressAtStartOfTheWeek = weeklyProgress;
      while (progressAtStartOfTheWeek > 0) {
        final step = definition.steps?[levelAtStartOfTheWeek];
        final requiredXP = step?.progressTotal ?? 0;
        if (requiredXP == 0) break;
        progressAtStartOfTheWeek -= requiredXP;
        if (progressAtStartOfTheWeek > 0) {
          levelAtStartOfTheWeek = (levelAtStartOfTheWeek - 1).clamp(minLevel, maxLevel);
        }
      }
      int levelsGainedWhileWellRested = currentLevel - levelAtStartOfTheWeek;
      int remainingLevels = wellRestedLevels - levelsGainedWhileWellRested;

      if (remainingLevels > 0) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "$remainingLevels",
              style: context.textTheme.caption.copyWith(color: context.theme.upgradeLayers.layer2),
            ),
            SizedBox(
                width: 16,
                height: 16,
                child: ManifestImageWidget<DestinySandboxPerkDefinition>(_wellRestedProgression)),
          ],
        );
      }
      return Container();
    });
  }

  Widget buildSeasonalRankProgress(BuildContext context) {
    final progressionHash = destinySettings.seasonalRankProgressionHash;
    final levelProg = character.progression?.progressions?["$progressionHash"];
    final overLevelProg =
        character.progression?.progressions?["${destinySettings.seasonalPrestigeRankProgressionHash}"];
    final currentProg = (levelProg?.level ?? 0) < (levelProg?.levelCap ?? 0) ? levelProg : overLevelProg;
    int progress = currentProg?.progressToNextLevel ?? 0;
    int total = currentProg?.nextLevelAt ?? 1;
    return Text(
      "$progress/$total",
      style: context.textTheme.caption,
    );
  }

  Widget buildPowerLevel(BuildContext context) {
    final totalPower = character.totalPower ?? 0;
    final artifactPower = character.artifactPower ?? 0;
    final armorPower = character.armorPower ?? 0;

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Icon(
                    LittleLightIcons.power,
                    color: context.theme.achievementLayers,
                    size: 16,
                  )),
              Text(
                "$totalPower",
                style: context.textTheme.largeTitle.copyWith(
                  color: context.theme.achievementLayers,
                ),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                "$armorPower",
                style: context.textTheme.title,
              ),
              artifactPower == 0
                  ? Container()
                  : Text(" +$artifactPower",
                      style: context.textTheme.subtitle.copyWith(color: LittleLightTheme.of(context).upgradeLayers))
            ],
          )
        ]);
  }
}
