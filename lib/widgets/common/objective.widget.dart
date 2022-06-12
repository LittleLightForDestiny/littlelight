// @dart=2.9

import 'dart:math';

import 'package:bungie_api/enums/destiny_unlock_value_uistyle.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:little_light/core/providers/language/language.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/utils/destiny_data.dart';

class ObjectiveWidget extends StatefulWidget {
  final DestinyObjectiveDefinition definition;
  final Color color;
  final Color barColor;
  final bool forceComplete;

  final DestinyObjectiveProgress objective;

  final String placeholder;
  final bool parentCompleted;

  final bool omitCheckBox;

  const ObjectiveWidget({
    Key key,
    this.definition,
    this.color,
    this.barColor,
    this.parentCompleted,
    this.objective,
    this.forceComplete = false,
    this.placeholder,
    this.omitCheckBox = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ObjectiveWidgetState();
  }
}

class ObjectiveWidgetState extends State<ObjectiveWidget> with ManifestConsumer {
  DestinyObjectiveDefinition _definition;
  DestinyObjectiveDefinition get definition => widget.definition ?? _definition;

  Color get color => widget.color;
  bool get forceComplete => widget.forceComplete;
  DestinyObjectiveProgress get objective => widget.objective;
  String get placeholder => widget.placeholder;
  bool get parentCompleted => widget.parentCompleted;

  @override
  void initState() {
    super.initState();
    loadDefinitions();
  }

  void loadDefinitions() async {
    if (widget.definition == null) {
      _definition = await manifest.getDefinition<DestinyObjectiveDefinition>(widget.objective.objectiveHash);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(4),
        child: Row(children: [
          if (!widget.omitCheckBox) buildCheck(context),
          Expanded(
            child: buildBar(context),
          )
        ]));
  }

  Widget buildCheck(BuildContext context) {
    return Container(
        decoration: BoxDecoration(border: Border.all(width: 1, color: widget.color ?? Colors.grey.shade300)),
        width: 22,
        height: 22,
        padding: EdgeInsets.all(2),
        child: buildCheckFill(context));
  }

  buildCheckFill(BuildContext context) {
    if (!isComplete) return null;
    return Container(color: barColor);
  }

  bool get isComplete {
    return widget.objective?.complete == true || widget.forceComplete;
  }

  buildBar(BuildContext context) {
    if (definition == null) return Container();
    if ((definition?.completionValue ?? 0) <= 1) {
      return Container(
          padding: EdgeInsets.only(left: 8, right: 4),
          child: Row(children: [Expanded(child: buildTitle(context)), buildProgressValue(context)]));
    }
    return Container(
        margin: EdgeInsets.only(left: 4),
        height: 22,
        decoration:
            isComplete ? null : BoxDecoration(border: Border.all(width: 1, color: this.color ?? Colors.grey.shade300)),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: buildProgressBar(context),
            ),
            Positioned.fill(
                left: 4,
                right: 4,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [Expanded(child: buildTitle(context)), buildProgressValue(context)]))
          ],
        ));
  }

  buildTitle(BuildContext context) {
    String title = definition?.progressDescription ?? "";
    if (title.length == 0) {
      title = placeholder ?? "";
    }

    return Container(
        child: Text(title,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: this.color ?? Colors.grey.shade300)));
  }

  Widget buildProgressValue(BuildContext context) {
    if (definition.completedValueStyle == DestinyUnlockValueUIStyle.DateTime) {
      return buildDate(context);
    }
    return buildCount(context);
  }

  Widget buildCount(BuildContext context) {
    int progress = objective?.progress ?? 0;
    int total = definition.completionValue ?? 0;
    if (!definition.allowOvercompletion) {
      progress = min(total, progress);
    }

    if (forceComplete) {
      progress = total;
    }

    final formatter = NumberFormat.decimalPattern(context.currentLanguage);
    String formattedProgress = formatter.format(progress);
    String formattedTotal = formatter.format(total);

    return Text(total <= 1 ? "$formattedProgress" : "$formattedProgress/$formattedTotal",
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: this.color ?? Colors.grey.shade300));
  }

  Widget buildDate(BuildContext context) {
    final formatter = DateFormat.yMd(context.currentLanguage);
    final progress = formatter.format(DateTime.fromMillisecondsSinceEpoch(objective.progress * 1000));
    return Text("$progress",
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: this.color ?? Colors.grey.shade300));
  }

  buildProgressBar(BuildContext context) {
    int progress = objective?.progress ?? 0;
    int total = definition.completionValue ?? 0;
    Color color = Color.lerp(barColor, Colors.black, .1);
    if (isComplete) return Container();
    return Container(
        margin: EdgeInsets.all(2),
        color: Theme.of(context).colorScheme.secondaryContainer,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: max(0.01, min(progress / total, 1)),
          child: Container(color: color),
        ));
  }

  Color get barColor {
    if (parentCompleted == true) {
      return color;
    }
    return widget.barColor ?? DestinyData.objectiveProgress;
  }
}
