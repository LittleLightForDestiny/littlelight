import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

typedef OnPressed = void Function();

class SealItemWidget extends StatefulWidget {
  final int? presentationNodeHash;
  final OnPressed? onPressed;

  const SealItemWidget({Key? key, this.presentationNodeHash, this.onPressed}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PresentationNodeWidgetState();
  }
}

class PresentationNodeWidgetState extends State<SealItemWidget>
    with AuthConsumer, UserSettingsConsumer, ProfileConsumer, ManifestConsumer {
  DestinyPresentationNodeDefinition? definition;
  DestinyRecordDefinition? completionRecordDefinition;
  DestinyRecordDefinition? gildingRecordDefinition;

  DestinyObjectiveDefinition? objectiveDefinition;
  DestinyObjectiveDefinition? gildingObjectiveDefinition;

  DestinyCharacterInfo? lastCharacter;

  DestinyRecordComponent? get completionRecord {
    final recordHash = completionRecordDefinition?.hash;
    final scope = completionRecordDefinition?.scope;
    if (recordHash == null || scope == null) return null;
    final DestinyRecordComponent? record = profile.getRecord(recordHash, scope);
    return record;
  }

  bool get isComplete =>
      (completionRecord?.state?.contains(DestinyRecordState.ObjectiveNotCompleted) ?? true) == false ||
      (completionRecord?.state?.contains(DestinyRecordState.RecordRedeemed) ?? false);

  bool get isGilded =>
      (gildingRecord?.state?.contains(DestinyRecordState.ObjectiveNotCompleted) ?? true) == false ||
      (gildingRecord?.state?.contains(DestinyRecordState.RecordRedeemed) ?? false);

  DestinyRecordComponent? get gildingRecord {
    final recordHash = gildingRecordDefinition?.hash;
    final scope = gildingRecordDefinition?.scope;
    if (recordHash == null || scope == null) return null;
    final DestinyRecordComponent? record = profile.getRecord(recordHash, scope);
    return record;
  }

  @override
  void initState() {
    super.initState();
    loadDefinitions();
  }

  loadDefinitions() async {
    definition = await manifest.getDefinition<DestinyPresentationNodeDefinition>(widget.presentationNodeHash);
    final completionRecordHash = definition?.completionRecordHash;
    if (completionRecordHash != null) {
      completionRecordDefinition = await manifest.getDefinition<DestinyRecordDefinition>(completionRecordHash);
    }
    final objectiveHash = completionRecordDefinition?.objectiveHashes?.firstOrNull;
    if (objectiveHash != null) {
      objectiveDefinition = await manifest.getDefinition<DestinyObjectiveDefinition>(objectiveHash);
    }
    final gildingRecordHash = completionRecordDefinition?.titleInfo?.gildingTrackingRecordHash;
    if (gildingRecordHash != null) {
      gildingRecordDefinition = await manifest.getDefinition<DestinyRecordDefinition>(gildingRecordHash);
    }
    final gildingObjectiveHash = gildingRecordDefinition?.objectiveHashes?.firstOrNull;
    if (gildingObjectiveHash != null) {
      gildingObjectiveDefinition = await manifest.getDefinition<DestinyObjectiveDefinition>(gildingObjectiveHash);
    }

    lastCharacter = profile.characters?.firstOrNull;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = LittleLightTheme.of(context);
    final color = theme.onSurfaceLayers.layer2;
    return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(.6), width: 1),
            gradient: LinearGradient(begin: const Alignment(0, 0), end: const Alignment(1, 2), colors: [
              color.withOpacity(.05),
              color.withOpacity(.1),
              color.withOpacity(.03),
              color.withOpacity(.1)
            ])),
        child: Stack(children: [
          Row(children: [
            buildIcon(),
            Expanded(child: buildSealInfo()),
          ]),
          Material(
            color: Colors.transparent,
            child: InkWell(onTap: widget.onPressed, child: Container()),
          )
        ]));
  }

  Widget buildIcon() {
    final iconUrl = definition?.originalIcon;
    if (iconUrl == null) {
      return Container();
    }
    return AspectRatio(
        aspectRatio: 1,
        child: Padding(padding: const EdgeInsets.all(8), child: QueuedNetworkImage.fromBungie(iconUrl)));
  }

  Widget buildSealInfo() {
    final theme = LittleLightTheme.of(context);
    final useGildingObjective = isComplete && gildingRecord != null;
    final objectiveDef = useGildingObjective ? gildingObjectiveDefinition : objectiveDefinition;
    return DefaultTextStyle(
        style: TextStyle(color: theme.onSurfaceLayers.layer2),
        child: Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildSealName(),
                Expanded(child: Container()),
                buildSealProgressBar(objectiveDef),
                Container(height: 2),
                buildSealTitle(objectiveDef),
              ],
            )));
  }

  Widget buildSealName() {
    final theme = LittleLightTheme.of(context);
    return Container(
      child: Text(
        definition?.displayProperties?.name ?? "",
        style: theme.textTheme.subtitle.copyWith(color: theme.onSurfaceLayers.layer2),
      ),
    );
  }

  Widget buildSealTitle(DestinyObjectiveDefinition? objectiveDef) {
    final genderHash = lastCharacter?.character.genderHash;
    final titlesByGenderHash = completionRecordDefinition?.titleInfo?.titlesByGenderHash;
    final title = genderHash != null ? (titlesByGenderHash?["$genderHash"]) : titlesByGenderHash?.values.firstOrNull;
    final theme = LittleLightTheme.of(context);
    final isComplete = this.isComplete;
    final color = isGilded
        ? theme.achievementLayers
        : isComplete
            ? theme.tierLayers.superior
            : theme.surfaceLayers.layer2;

    return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          color: color.withOpacity(.5),
        ),
        child: Row(children: [Expanded(child: Text(title ?? "")), buildSealProgress(objectiveDef)]));
  }

  Widget buildSealProgress(DestinyObjectiveDefinition? objectiveDef) {
    final theme = LittleLightTheme.of(context);
    final objective = completionRecord?.objectives?.firstOrNull;
    if (objective == null || objectiveDef == null) return Container();
    return Text(
      "${objective.progress}/${objectiveDef.completionValue}",
      style: theme.textTheme.subtitle.copyWith(color: theme.onSurfaceLayers.layer2),
    );
  }

  Widget buildSealProgressBar(DestinyObjectiveDefinition? objectiveDef) {
    final theme = LittleLightTheme.of(context);
    final useGildingObjective = isComplete && gildingRecord != null;
    final bgColor = isGilded
        ? theme.achievementLayers
        : isComplete
            ? theme.tierLayers.superior
            : theme.surfaceLayers.layer2;
    final color = useGildingObjective ? theme.achievementLayers.layer1 : theme.tierLayers.superior;
    final objective = completionRecord?.objectives?.firstOrNull;
    final progress = (objective?.progress ?? 0) / (objectiveDef?.completionValue ?? 1);
    return Container(
        alignment: Alignment.centerLeft,
        height: 8,
        color: bgColor.withOpacity(.5),
        child: FractionallySizedBox(widthFactor: progress.clamp(0, 1), child: Container(color: color)));
  }
}
