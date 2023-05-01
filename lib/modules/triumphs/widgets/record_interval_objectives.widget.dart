import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

class RecordIntervalObjectivesWidget extends StatelessWidget {
  final int? recordHash;
  final Color? color;
  final DestinyRecordComponent? progressRecord;

  const RecordIntervalObjectivesWidget(
    this.recordHash, {
    Key? key,
    this.color,
    this.progressRecord,
  }) : super(key: key);

  Color foregroundColor(BuildContext context) => color ?? context.theme.onSurfaceLayers;

  @override
  Widget build(BuildContext context) {
    final definition = context.definition<DestinyRecordDefinition>(this.recordHash);
    final objectives = definition?.intervalInfo?.intervalObjectives;
    if (objectives == null || objectives.isEmpty) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.all(2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: objectives.mapIndexed((i, e) => buildCompletionBar(context, i)).toList(),
      ),
    );
  }

  Widget buildCompletionBar(BuildContext context, int index) {
    final definition = context.definition<DestinyRecordDefinition>(this.recordHash);
    final defObjectives = definition?.intervalInfo?.intervalObjectives;
    final objectiveHash = defObjectives?[index].intervalObjectiveHash;
    final previousObjectiveHash = index > 0 ? (defObjectives?[index - 1].intervalObjectiveHash) : null;

    final objectiveDef = context.definition<DestinyObjectiveDefinition>(objectiveHash);
    final previousObjectiveDef = context.definition<DestinyObjectiveDefinition>(previousObjectiveHash);

    final recordObjectives = this.progressRecord?.intervalObjectives;
    final recordObjective = recordObjectives?[index];
    final previousRecordObjective = index > 0 ? (recordObjectives?[index - 1]) : null;

    final isComplete = recordObjective?.complete == true || //
        (progressRecord?.intervalsRedeemedCount ?? 0) > index;
    final isPreviousComplete = previousRecordObjective?.complete == true || //
        (progressRecord?.intervalsRedeemedCount ?? 0) > index - 1;

    final stepCount = recordObjectives?.length ?? defObjectives?.length ?? 0;
    final isFirst = index == 0;
    final isLast = index == stepCount - 1;

    final start = previousRecordObjective?.completionValue ?? previousObjectiveDef?.completionValue ?? 0;
    final end = recordObjective?.completionValue ?? objectiveDef?.completionValue ?? 1;

    final objectiveProgress = recordObjective?.progress ?? 0;
    final isCurrent = (isPreviousComplete && !isComplete) || (!isComplete && isFirst) || (isComplete && isLast);
    final color = foregroundColor(context);
    final currentProgress = objectiveProgress - start;
    final currentTotal = end - start;
    final progressPercent = isComplete ? 1.0 : (currentProgress / currentTotal).clamp(0.0, 1.0);
    final shouldShowNumber = currentTotal > 1;
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (shouldShowNumber)
              Text(
                isCurrent ? "$objectiveProgress/$end" : "$end",
                style: context.textTheme.caption.copyWith(color: color),
              ),
            Container(
              margin: EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 1),
              ),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progressPercent,
                child: Container(color: color),
              ),
              height: 8.0,
            ),
          ],
        ),
      ),
    );
  }
}
