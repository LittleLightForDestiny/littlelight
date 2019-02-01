import 'dart:math';

import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';

class ObjectiveWidget extends StatelessWidget {
  final DestinyObjectiveDefinition definition;
  final Color color;

  final DestinyObjectiveProgress objective;

  const ObjectiveWidget({Key key, this.definition, this.color, this.objective})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(4),
        child: Row(children: [
          buildCheck(context),
          Expanded(
            child: buildBar(context),
          )
        ]));
  }

  Widget buildCheck(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(
                width: 1, color: this.color ?? Colors.grey.shade300)),
        width: 22,
        height: 22,
        padding: EdgeInsets.all(2),
        child: buildCheckFill(context));
  }

  buildCheckFill(BuildContext context) {
    var completed = objective?.complete == true;
    if (!completed) return null;
    return Container(color: DestinyData.objectiveProgress);
  }

  buildBar(BuildContext context) {
    if (definition == null) return Container();
    return Container(
        margin: EdgeInsets.only(left: 4),
        height: 22,
        padding: EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
            border: Border.all(
                width: 1, color: this.color ?? Colors.grey.shade300)),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [buildTitle(context), buildFraction(context)]))
          ],
        ));
  }

  buildTitle(BuildContext context) {
    return Flexible(
        child: Text(definition?.progressDescription ?? "",
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
            style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 12,
                color: this.color ?? Colors.grey.shade300)));
  }

  buildFraction(BuildContext context) {
    int progress = objective?.progress ?? 0;
    int total = definition.completionValue ?? 0;
    if (total == 0) return Container();
    if (!definition.allowOvercompletion) {
      progress = max(total, progress);
    }

    return Text("$progress/$total",
        style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 13,
            color: this.color ?? Colors.grey.shade300));
  }
}
