import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/destiny_settings.consumer.dart';
import 'package:little_light/shared/utils/helpers/bucket_full_helper.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

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
      "Rewards Pass Rank {rank}".translate(context, replace: {"rank": "$progress"}),
      style: context.textTheme.caption,
    );
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
    final isAlmostFull = isBucketAlmostFull(this.totalVaultItems, bucketDef);
    if (maximum == null || totalVaultItems == null) return Container();
    return Text(
      "$totalVaultItems/$maximum",
      style: context.textTheme.largeTitle.copyWith(
        color: isAlmostFull ? context.theme.highlightedObjectiveLayers : context.theme.onSurfaceLayers,
      ),
    );
  }
}
