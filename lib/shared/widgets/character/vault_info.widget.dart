import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/destiny_settings.consumer.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

const _wellRestedProgression = 2352765282;

class VaultInfoWidget extends StatelessWidget with DestinySettingsConsumer {
  final List<DestinyItemComponent>? currencies;
  final Map<String, DestinyProgression>? progressions;
  final int? totalVaultItems;

  const VaultInfoWidget({
    this.currencies,
    this.progressions,
    this.totalVaultItems,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        buildSeasonalRankRow(context),
        SizedBox(height: 4),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildCharacterDetails(context),
              buildItemCount(context),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: buildCurrencies(context)),
          ],
        ),
        SizedBox(height: 4),
      ]),
    ]);
  }

  Widget buildCurrencies(BuildContext context) {
    final currencies = this.currencies;
    if (currencies == null) return Container();
    final numberFormatter = NumberFormat.decimalPattern(context.currentLanguage);
    return Wrap(
      alignment: WrapAlignment.end,
      children: currencies
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
                  Text(numberFormatter.format(e.quantity)),
                  Container(width: 8),
                ].toList(),
              ))
          .toList(),
    );
  }

  Widget buildCharacterDetails(BuildContext context) {
    return buildName(context);
  }

  Widget buildName(BuildContext context) {
    return Text(
      "Vault".translate(context),
      style: context.textTheme.largeTitle,
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
    final levelProg = progressions?["$progressionHash"];
    final overLevelProg = progressions?["${destinySettings.seasonalPrestigeRankProgressionHash}"];
    int level = levelProg?.level ?? 0;
    int overlevel = overLevelProg?.level ?? 0;
    int progress = level + overlevel;
    return Text(
      "Season Rank {rank}".translate(context, replace: {"rank": "$progress"}),
      style: context.textTheme.caption,
    );
  }

  Widget? buildWellRested(BuildContext context) {
    final progressionHash = destinySettings.seasonalRankProgressionHash;
    final levelProg = progressions?["$progressionHash"];
    final overLevelProg = progressions?["${destinySettings.seasonalPrestigeRankProgressionHash}"];
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
    final levelProg = progressions?["$progressionHash"];
    final overLevelProg = progressions?["${destinySettings.seasonalPrestigeRankProgressionHash}"];
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

  Widget buildItemCount(BuildContext context) {
    final bucketDef = context.definition<DestinyInventoryBucketDefinition>(InventoryBucket.general);
    final maximum = bucketDef?.itemCount;
    final count = totalVaultItems;
    if (count == null || maximum == null) return Container();
    final limit = maximum * .95;
    return Text(
      "$totalVaultItems/$maximum",
      style: context.textTheme.largeTitle.copyWith(
        color: count > limit ? context.theme.highlightedObjectiveLayers : context.theme.onSurfaceLayers,
      ),
    );
  }
}
