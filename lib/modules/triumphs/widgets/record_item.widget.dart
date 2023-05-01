import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/triumphs/widgets/record_interval_objectives.widget.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/helpers/presentation_node_helpers.dart';
import 'package:little_light/shared/widgets/objectives/objective.widget.dart';
import 'package:little_light/shared/widgets/objectives/small_objective.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:tinycolor2/tinycolor2.dart';

const _recordIconSize = 56.0;

class RecordItemWidget extends StatelessWidget {
  final int? recordHash;
  final RecordProgressData? progress;
  final VoidCallback? onTap;
  RecordItemWidget(this.recordHash, {Key? key, this.progress, this.onTap}) : super(key: key);

  bool isCompleted(BuildContext context) {
    final definition = context.definition<DestinyRecordDefinition>(this.recordHash);
    final completed = progress?.isCompleted(definition?.scope) ?? false;
    return completed;
  }

  Color foregroundColor(BuildContext context) {
    final completed = isCompleted(context);
    return completed ? context.theme.achievementLayers.layer2 : context.theme.onSurfaceLayers;
  }

  @override
  Widget build(BuildContext context) {
    final foregroundColor = this.foregroundColor(context);
    return LayoutBuilder(
        builder: (context, constraints) => Container(
            decoration: BoxDecoration(
              border: Border.all(color: foregroundColor, width: 1),
            ),
            child: Stack(children: [
              buildContent(context),
              Positioned.fill(child: MaterialButton(child: Container(), onPressed: onTap))
            ])));
  }

  Widget buildContent(BuildContext context) {
    return Column(
        children: [
      Expanded(
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildIcon(context),
          Expanded(child: buildBasicInfo(context)),
        ].whereType<Widget>().toList(),
      )),
      buildFooter(context)
    ].whereType<Widget>().toList());
  }

  Widget buildBasicInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTitleBar(context),
          Container(color: foregroundColor(context), height: 1),
          Expanded(child: buildDescription(context)),
        ],
      ),
    );
  }

  Widget buildTitleBar(BuildContext context) {
    final definition = context.definition<DestinyRecordDefinition>(this.recordHash);
    final foregroundColor = this.foregroundColor(context);
    int? scoreValue = definition?.completionInfo?.scoreValue;
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
          child: Container(
              padding: const EdgeInsets.all(4),
              child: Text(
                definition?.displayProperties?.name ?? "",
                softWrap: true,
                style: context.textTheme.itemNameHighDensity.copyWith(color: foregroundColor),
              ))),
      if (progress?.tracking ?? false) buildTrackingIcon(context),
      Container(
          padding: const EdgeInsets.only(left: 4, right: 4),
          child: Text(
            "${scoreValue}",
            style: context.textTheme.body.copyWith(color: foregroundColor),
          )),
    ]);
  }

  Widget buildDescription(BuildContext context) {
    final definition = context.definition<DestinyRecordDefinition>(recordHash);
    final hasLore = definition?.loreHash != null;
    final foregroundColor = this.foregroundColor(context);
    return Container(
      padding: EdgeInsets.all(4.0),
      child: hasLore
          ? ManifestText<DestinyLoreDefinition>(
              definition?.loreHash,
              textExtractor: (def) => def.displayProperties?.description ?? "",
              overflow: TextOverflow.fade,
              style: context.textTheme.body.copyWith(color: foregroundColor),
            )
          : ManifestText<DestinyRecordDefinition>(recordHash,
              textExtractor: (def) => def.displayProperties?.description ?? "",
              overflow: TextOverflow.fade,
              style: context.textTheme.body.copyWith(
                color: foregroundColor,
              )),
    );
  }

  Widget? buildFooter(BuildContext context) {
    final definition = context.definition<DestinyRecordDefinition>(this.recordHash);
    if (definition?.loreHash != null) return null;
    final intervalObjectives = definition?.intervalInfo?.intervalObjectives;
    if (intervalObjectives != null && intervalObjectives.isNotEmpty) return buildCompletionBars(context);
    final objectiveHashes = definition?.objectiveHashes;
    if (objectiveHashes?.length == 1) return buildSingleObjective(context);
    if (objectiveHashes != null && objectiveHashes.isNotEmpty) return buildObjectives(context);
    return null;
  }

  Widget? buildCompletionBars(BuildContext context) {
    final definition = context.definition<DestinyRecordDefinition>(this.recordHash);
    final objectives = definition?.intervalInfo?.intervalObjectives;
    if (objectives == null || objectives.isEmpty) {
      return Container();
    }
    final progressRecord = progress?.getProgress(definition?.scope);
    return RecordIntervalObjectivesWidget(
      recordHash,
      progressRecord: progressRecord,
      color: foregroundColor(context),
    );
  }

  Widget? buildSingleObjective(BuildContext context) {
    final definition = context.definition<DestinyRecordDefinition>(this.recordHash);
    final objectiveDefinition =
        context.definition<DestinyObjectiveDefinition>(definition?.objectiveHashes?.firstOrNull);
    final hash = objectiveDefinition?.hash;
    if (hash == null) return Container();
    final objective = this.progress?.getProgress(definition?.scope)?.objectives?.firstOrNull;
    return ObjectiveWidget(
      hash,
      placeholder: definition?.displayProperties?.name,
      objective: objective,
      parentCompleted: isCompleted(context),
      color: foregroundColor(context),
    );
  }

  Widget? buildIcon(BuildContext context) {
    final definition = context.definition<DestinyRecordDefinition>(this.recordHash);
    final hasIcon = (definition?.displayProperties?.hasIcon ?? false) && definition?.displayProperties?.icon != null;
    if (!hasIcon) return null;
    return Container(
        margin: EdgeInsets.all(4),
        width: _recordIconSize,
        height: _recordIconSize,
        child: ManifestImageWidget<DestinyRecordDefinition>(recordHash));
  }

  Widget buildTrackingIcon(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: context.theme.successLayers.layer0.mix(context.theme.surfaceLayers, 40),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          FontAwesomeIcons.crosshairs,
          size: 12,
          color: context.theme.successLayers.layer3.mix(context.theme.onSurfaceLayers, 50),
        ));
  }

  Widget? buildObjectives(BuildContext context) {
    final definition = context.definition<DestinyRecordDefinition>(recordHash);
    final objectiveHashes = definition?.objectiveHashes;
    if (objectiveHashes == null) return null;
    final objectives = progress?.getProgress(definition?.scope)?.objectives;
    return Container(
      margin: const EdgeInsets.all(4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: objectiveHashes
            .mapIndexed((index, hash) => Expanded(
                    child: Container(
                  margin: const EdgeInsets.all(2),
                  child: SmallObjectiveWidget(
                    hash,
                    parentCompleted: isCompleted(context),
                    color: foregroundColor(context),
                    objective: objectives?[index],
                  ),
                )))
            .toList(),
      ),
    );
  }
}
