import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/profile/destiny_settings.consumer.dart';
import 'package:little_light/shared/widgets/character/grind_optimizer.bottomsheet.dart';
import 'package:little_light/shared/widgets/stats/small_armor_stats.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/icon_fonts/littlelight_icons.dart';
import 'package:intl/intl.dart';

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
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
          ],
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              child: Container(),
              onTap: () {
                showGrindOptimizer(context);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCurrencies(BuildContext context) {
    final currencies = this.currencies;
    if (currencies == null) return Container();
    final numberFormatter = NumberFormat.decimalPattern(context.currentLanguage);
    return Wrap(
      alignment: WrapAlignment.end,
      children:
          currencies
              .map(
                (e) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      [
                        Container(
                          child: ManifestImageWidget<DestinyInventoryItemDefinition>(e.itemHash),
                          width: 16,
                          height: 16,
                        ),
                        Container(
                          width: 4,
                        ),
                        Text(numberFormatter.format(e.quantity)),
                        Container(width: 8),
                      ].toList(),
                ),
              )
              .toList(),
    );
  }

  Widget buildCharacterDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          [
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
    );
  }

  Widget buildSeasonalRankRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children:
            [
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
      "Rewards Pass Rank {rank}".translate(context, replace: {"rank": "$progress"}),
      style: context.textTheme.caption,
    );
  }

  Widget buildSeasonalRankProgress(BuildContext context) {
    final progressionHash = destinySettings.seasonalRankProgressionHash;
    final levelProg = character.progression?.progressions?["$progressionHash"];
    final overLevelProg =
        character.progression?.progressions?["${destinySettings.seasonalPrestigeRankProgressionHash}"];
    final currentProg = (levelProg?.level ?? 0) < (levelProg?.levelCap ?? 0) ? levelProg : overLevelProg;
    int progress = currentProg?.progressToNextLevel ?? 0;
    int total = currentProg?.nextLevelAt ?? 1;
    final numberFormatter = NumberFormat.decimalPattern(context.currentLanguage);
    String formattedProgress = numberFormatter.format(progress);
    String formattedTotal = numberFormatter.format(total);
    return Text(
      "$formattedProgress/$formattedTotal",
      style: context.textTheme.caption,
    );
  }

  Widget buildPowerLevel(BuildContext context) {
    final totalPower = character.totalPower ?? 0;
    return Container(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Icon(
              LittleLightIcons.power,
              color: context.theme.achievementLayers,
              size: 16,
            ),
          ),
          Text(
            "$totalPower",
            style: context.textTheme.largeTitle.copyWith(
              color: context.theme.achievementLayers,
            ),
          ),
        ],
      ),
    );
  }

  void showGrindOptimizer(BuildContext context) {
    GrindOptimizerBottomsheet(character).show(context);
  }
}
