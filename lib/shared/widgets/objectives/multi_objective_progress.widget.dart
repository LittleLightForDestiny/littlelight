import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

class _ObjectiveProgress {
  final int completionValue;
  final int currentProgress;
  final double percentComplete;

  _ObjectiveProgress(this.completionValue, this.currentProgress, this.percentComplete);
}

class MultiObjectiveProgressWidget extends StatelessWidget {
  final List<int> objectiveHashes;
  final List<DestinyObjectiveProgress>? objectives;
  final bool forceComplete;
  final Color? color;

  final bool parentCompleted;

  const MultiObjectiveProgressWidget(
    this.objectiveHashes, {
    Key? key,
    Color? this.color,
    bool this.forceComplete = false,
    this.objectives,
    bool this.parentCompleted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final completionValues = <int, _ObjectiveProgress>{};
    double totalProgress = 0;
    for (final objectiveHash in objectiveHashes) {
      final def = context.definition<DestinyObjectiveDefinition>(objectiveHash);
      final objective = objectives?.firstWhereOrNull((element) => element.objectiveHash == objectiveHash);
      final completionValue = objective?.completionValue ?? def?.completionValue ?? 1;
      final currentProgress = forceComplete ? completionValue : objective?.progress ?? 0;
      final percentComplete = (currentProgress / completionValue).clamp(0.0, 1.0);
      totalProgress += percentComplete / objectiveHashes.length;
      final value = _ObjectiveProgress(
        completionValue,
        currentProgress,
        percentComplete,
      );
      completionValues[objectiveHash] = value;
    }
    return Column(
        children: [
      buildProgressValue(context, totalProgress),
      buildProgressBars(context, completionValues),
    ].whereType<Widget>().toList());
  }

  Widget? buildProgressValue(BuildContext context, double progress) {
    final percent = (progress * 100).round();
    return Text(
      "$percent%",
      softWrap: false,
      overflow: TextOverflow.clip,
      style: context.textTheme.caption.copyWith(
        color: color ?? context.theme.onSurfaceLayers,
        fontSize: 10,
      ),
    );
  }

  Widget buildProgressBars(BuildContext context, Map<int, _ObjectiveProgress> objectiveProgress) {
    return Row(
      children: objectiveHashes
          .map((e) {
            final progress = objectiveProgress[e];
            if (progress == null) return null;
            return Expanded(child: buildProgressBar(context, progress));
          })
          .whereType<Widget>()
          .toList(),
    );
  }

  Widget buildProgressBar(BuildContext context, _ObjectiveProgress objectiveProgress) {
    final progress = objectiveProgress.percentComplete;
    return Container(
        height: 4,
        margin: EdgeInsets.all(.5),
        color: context.theme.surfaceLayers.layer3,
        alignment: Alignment.centerLeft,
        child: progress > 0
            ? FractionallySizedBox(
                widthFactor: progress.clamp(0, 1),
                child: Container(color: getBarColor(context)),
              )
            : null);
  }

  Color? getBarColor(BuildContext context) {
    if (parentCompleted == true) {
      return this.color ?? context.theme.successLayers.layer0;
    }
    return context.theme.successLayers.layer0;
  }
}
