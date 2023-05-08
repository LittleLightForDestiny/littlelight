import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

class SmallObjectiveWidget extends StatelessWidget {
  final int? objectiveHash;
  final DestinyObjectiveProgress? objective;
  final bool forceComplete;
  final Color? color;
  final String? placeholder;
  final bool parentCompleted;

  const SmallObjectiveWidget(
    this.objectiveHash, {
    Key? key,
    Color? this.color,
    bool this.forceComplete = false,
    DestinyObjectiveProgress? this.objective,
    String? this.placeholder,
    bool this.parentCompleted = false,
  }) : super(key: key);

  bool get isComplete => objective?.complete ?? this.forceComplete;

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
      buildProgressValue(context),
      buildProgressBar(context),
      Container(height: 2),
      buildTitle(context),
    ].whereType<Widget>().toList());
  }

  Widget? buildProgressValue(BuildContext context) {
    final definition = context.definition<DestinyObjectiveDefinition>(objectiveHash);
    int progress = objective?.progress ?? 0;
    final total = objective?.completionValue ?? definition?.completionValue ?? 1;
    final allowOverCompletion = definition?.allowOvercompletion ?? false;
    if (!allowOverCompletion) {
      progress = progress.clamp(0, total);
    }
    if (forceComplete) {
      progress = total;
    }
    var percent = (progress / total * 100).round();
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

  Widget buildProgressBar(BuildContext context) {
    final definition = context.definition<DestinyObjectiveDefinition>(objectiveHash);
    final progress = objective?.progress ?? 0;
    final total = definition?.completionValue ?? 0;
    return Container(
        height: 4,
        color: context.theme.surfaceLayers.layer3,
        alignment: Alignment.centerLeft,
        child: progress > 0
            ? FractionallySizedBox(
                widthFactor: (progress / total).clamp(0, 1),
                child: Container(color: getBarColor(context)),
              )
            : null);
  }

  Widget? buildTitle(BuildContext context) {
    final definition = context.definition<DestinyObjectiveDefinition>(objectiveHash);
    String title = definition?.progressDescription ?? "";
    if (title.isEmpty) {
      title = placeholder ?? "";
    }

    return Container(
      child: Text(
        title,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
        style: context.textTheme.caption.copyWith(
          color: color ?? context.theme.onSurfaceLayers,
          fontSize: 10,
        ),
      ),
    );
  }

  Color? getBarColor(BuildContext context) {
    if (parentCompleted == true) {
      return this.color ?? context.theme.successLayers.layer0;
    }
    return context.theme.successLayers.layer0;
  }
}
