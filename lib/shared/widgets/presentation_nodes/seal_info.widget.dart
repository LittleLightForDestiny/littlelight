import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/helpers/presentation_node_helpers.dart';

class SealInfoWidget extends StatelessWidget {
  final int? completionRecordHash;
  final PresentationNodeProgressData? progress;

  SealInfoWidget(int? this.completionRecordHash, {this.progress});
  @override
  Widget build(BuildContext context) {
    final definition = context.definition<DestinyRecordDefinition>(completionRecordHash);
    final objectiveHash = definition?.objectiveHashes?.firstOrNull;
    final objectiveDefinition = context.definition<DestinyObjectiveDefinition>(objectiveHash);
    if (objectiveDefinition == null) return Container();
    return Container(
        width: 180,
        child: Column(
          children: [
            buildProgressBar(
              context,
              objectiveDefinition: objectiveDefinition,
            ),
            buildSealTitle(context, objectiveDefinition),
          ],
        ));
  }

  Widget buildProgressBar(BuildContext context, {DestinyObjectiveDefinition? objectiveDefinition}) {
    //TODO: finish this after record evaluation is more defined
    final useGildingObjective = false; //isComplete && gildingRecord != null;
    final bgColor = context.theme.tierLayers.superior; // isGilded
    // ? theme.achievementLayers
    // : isComplete
    //     ? theme.tierLayers.superior
    //     : theme.surfaceLayers.layer2;
    final color = useGildingObjective ? context.theme.achievementLayers.layer1 : context.theme.tierLayers.superior;
    final progress = 0.0; // (objective?.progress ?? 0) / (objectiveDef?.completionValue ?? 1);
    return Container(
        alignment: Alignment.centerLeft,
        height: 8.0,
        color: bgColor.withOpacity(.5),
        child: FractionallySizedBox(widthFactor: progress.clamp(0, 1), child: Container(color: color)));
  }

  Widget buildSealTitle(BuildContext context, DestinyObjectiveDefinition? objectiveDef) {
    final definition = context.definition<DestinyRecordDefinition>(completionRecordHash);
    final genderHash = null; //lastCharacter?.character.genderHash;
    final genderedTitle = definition?.titleInfo?.titlesByGenderHash?[genderHash];
    final nonGenderedTitle = definition?.titleInfo?.titlesByGender?.values.firstOrNull;
    final title = genderedTitle ?? nonGenderedTitle;

    final isComplete = false; //this.isComplete;
    final color = context.theme.tierLayers.superior; // isGilded
    // ? theme.achievementLayers
    // : isComplete
    //     ? theme.tierLayers.superior
    //     : theme.surfaceLayers.layer2;

    return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          color: color.withOpacity(.5),
        ),
        child: Row(
            children: [Expanded(child: Text(title ?? "")), buildSealProgress(context, objectiveDef: objectiveDef)]));
  }

  Widget buildSealProgress(BuildContext context, {DestinyObjectiveDefinition? objectiveDef}) {
    final progress = 0; //completionRecord?.objectives?.firstOrNull;
    if (objectiveDef == null) return Container();
    return Text(
      "$progress/${objectiveDef.completionValue}",
      style: context.textTheme.subtitle.copyWith(
        color: context.theme.onSurfaceLayers.layer2,
      ),
    );
  }
}
