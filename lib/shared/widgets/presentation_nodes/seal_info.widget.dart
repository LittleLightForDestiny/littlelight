import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/helpers/presentation_node_helpers.dart';
import 'package:provider/provider.dart';

class SealInfoWidget extends StatelessWidget {
  final int? completionRecordHash;

  SealInfoWidget(int? this.completionRecordHash);
  @override
  Widget build(BuildContext context) {
    final definition = context.definition<DestinyRecordDefinition>(completionRecordHash);
    final objectiveHash = definition?.objectiveHashes?.firstOrNull;
    final objectiveDefinition = context.definition<DestinyObjectiveDefinition>(objectiveHash);
    if (objectiveDefinition == null) return Container();
    final profile = context.watch<ProfileBloc>();
    final record = profile.getProfileRecord(completionRecordHash);
    final gildingRecord = profile.getProfileRecord(definition?.titleInfo?.gildingTrackingRecordHash);
    final isInitialComplete = record?.isCompleted ?? false;
    final isGilded = gildingRecord?.isCompleted ?? false;
    final useGildingObjective = isInitialComplete && definition?.titleInfo?.gildingTrackingRecordHash != null;
    final objective = useGildingObjective ? gildingRecord?.objectives?.firstOrNull : record?.objectives?.firstOrNull;
    final objectiveDef = context.definition<DestinyObjectiveDefinition>(objective?.objectiveHash);
    final genderHash = profile.lastPlayedCharacter?.character.genderHash;
    return Container(
        margin: EdgeInsets.only(top: 8),
        width: 180,
        child: Column(
          children: [
            buildProgressBar(
              context,
              objectiveDefinition: objectiveDefinition,
              isGilded: isGilded,
              isInitialComplete: isInitialComplete,
              currentProgress: objective?.progress ?? 0,
              completionValue: objectiveDef?.completionValue ?? 1,
            ),
            buildSealTitle(
              context,
              genderHash: genderHash,
              isInitialComplete: isInitialComplete,
              isGilded: isGilded,
              currentProgress: objective?.progress ?? 0,
              completionValue: objectiveDef?.completionValue,
            ),
          ],
        ));
  }

  Widget buildProgressBar(
    BuildContext context, {
    DestinyObjectiveDefinition? objectiveDefinition,
    bool isGilded = false,
    bool isInitialComplete = false,
    int currentProgress = 0,
    int completionValue = 1,
  }) {
    final theme = context.theme;
    final definition = context.definition<DestinyRecordDefinition>(completionRecordHash);
    final useGildingObjective = isInitialComplete && definition?.titleInfo?.gildingTrackingRecordHash != null;
    final bgColor = isGilded
        ? theme.achievementLayers
        : isInitialComplete
            ? theme.tierLayers.superior
            : theme.surfaceLayers.layer2;
    final color = useGildingObjective ? context.theme.achievementLayers.layer1 : context.theme.tierLayers.superior;
    final progress = currentProgress / completionValue;
    return Container(
        alignment: Alignment.centerLeft,
        height: 8.0,
        margin: EdgeInsets.only(bottom: 2),
        color: bgColor.withValues(alpha: .5),
        child: FractionallySizedBox(widthFactor: progress.clamp(0, 1), child: Container(color: color)));
  }

  Widget buildSealTitle(
    BuildContext context, {
    int? genderHash,
    bool isGilded = false,
    bool isInitialComplete = false,
    int currentProgress = 0,
    int? completionValue,
  }) {
    final theme = context.theme;
    final definition = context.definition<DestinyRecordDefinition>(completionRecordHash);
    final genderedTitle = definition?.titleInfo?.titlesByGenderHash?[genderHash];
    final nonGenderedTitle = definition?.titleInfo?.titlesByGender?.values.firstOrNull;
    final title = genderedTitle ?? nonGenderedTitle;

    final color = isGilded
        ? theme.achievementLayers
        : isInitialComplete
            ? theme.tierLayers.superior
            : theme.surfaceLayers.layer2;

    return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          color: color.withValues(alpha: .5),
        ),
        child: Row(children: [
          Expanded(
              child: Text(
            title ?? "",
            softWrap: false,
            overflow: TextOverflow.fade,
          )),
          buildSealProgress(
            context,
            currentProgress: currentProgress,
            completionValue: completionValue,
          ),
        ]));
  }

  Widget buildSealProgress(BuildContext context, {int currentProgress = 0, int? completionValue}) {
    if (completionValue == null) return Container();
    return Text(
      "$currentProgress/$completionValue",
      style: context.textTheme.subtitle.copyWith(
        color: context.theme.onSurfaceLayers.layer2,
      ),
    );
  }
}
