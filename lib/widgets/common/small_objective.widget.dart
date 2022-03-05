// @dart=2.9

import 'dart:math';

import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/objective.widget.dart';

class SmallObjectiveWidget extends ObjectiveWidget {
  const SmallObjectiveWidget(
      {Key key,
      DestinyObjectiveDefinition definition,
      Color color,
      bool forceComplete = false,
      DestinyObjectiveProgress objective,
      String placeholder,
      bool parentCompleted = false})
      : super(
            key: key,
            definition: definition,
            color: color,
            forceComplete: forceComplete,
            objective: objective,
            placeholder: placeholder,
            parentCompleted: parentCompleted);

  @override
  State<StatefulWidget> createState() {
    return SmallObjectiveWidgetState();
  }
}

class SmallObjectiveWidgetState extends ObjectiveWidgetState {
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [buildProgressValue(context), buildProgressBar(context), Container(height: 2), buildTitle(context)]);
  }

  bool get isComplete {
    return (objective?.complete == true || forceComplete) ?? false;
  }

  buildProgressValue(BuildContext context) {
    int progress = objective?.progress ?? 0;
    int total = definition.completionValue ?? 0;
    if (total <= 1)
      return Text(
        "",
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 10, color: this.color ?? Colors.grey.shade300),
      );
    if (!definition.allowOvercompletion) {
      progress = min(total, progress);
    }

    if (forceComplete) {
      progress = total;
    }
    var percent = (progress / total * 100).round();
    return Text("$percent%",
        softWrap: false,
        overflow: TextOverflow.clip,
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 10, color: this.color ?? Colors.grey.shade300));
  }

  buildProgressBar(BuildContext context) {
    int progress = objective?.progress ?? 0;
    int total = definition.completionValue ?? 0;
    return Container(
        height: 4,
        color: Theme.of(context).colorScheme.secondary,
        alignment: Alignment.centerLeft,
        child: progress <= 0
            ? Container()
            : FractionallySizedBox(
                widthFactor: max(0.01, min(progress / total, 1)),
                child: Container(color: barColor),
              ));
  }

  buildTitle(BuildContext context) {
    String title = definition?.progressDescription ?? "";
    if (title.length == 0) {
      title = placeholder ?? "";
    }

    return Container(
        child: Text(title.toUpperCase(),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: this.color ?? Colors.grey.shade300)));
  }

  Color get barColor {
    if (parentCompleted == true) {
      return color;
    }
    return DestinyData.objectiveProgress;
  }
}
