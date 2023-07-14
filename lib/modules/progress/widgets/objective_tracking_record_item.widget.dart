import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/triumphs/widgets/record_item.widget.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/helpers/presentation_node_helpers.dart';
import 'package:little_light/shared/widgets/objectives/objective.widget.dart';

class ObjectiveTrackingRecordItemWidget extends RecordItemWidget {
  ObjectiveTrackingRecordItemWidget(int? recordHash, {RecordProgressData? progress, Key? key})
      : super(recordHash, key: key, progress: progress);

  @override
  Widget? buildFooter(BuildContext context) {
    final definition = context.definition<DestinyRecordDefinition>(this.recordHash);
    if (definition?.loreHash != null) return null;
    final intervalObjectives = definition?.intervalInfo?.intervalObjectives;
    if (intervalObjectives != null && intervalObjectives.isNotEmpty) return buildCompletionBars(context);
    final objectiveHashes = definition?.objectiveHashes;
    if (objectiveHashes == null) return null;
    return Column(
        children: objectiveHashes
            .map((e) {
              final objective = this
                  .progress
                  ?.getProgress(definition?.scope)
                  ?.objectives
                  ?.firstWhereOrNull((element) => element.objectiveHash == e);
              return ObjectiveWidget(
                e,
                placeholder: definition?.displayProperties?.name,
                objective: objective,
                parentCompleted: isCompleted(context),
                color: foregroundColor(context),
              );
            })
            .whereType<Widget>()
            .toList());
  }
}
