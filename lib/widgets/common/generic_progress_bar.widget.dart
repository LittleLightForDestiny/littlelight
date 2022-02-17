// @dart=2.9

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';

class GenericProgressBarWidget extends StatelessWidget {
  final Color color;

  final Widget description;
  final bool completed;
  final int total;
  final int progress;

  const GenericProgressBarWidget(
      {Key key, this.color, this.completed = false, this.total = 0, this.progress = 0, this.description})
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
        decoration: BoxDecoration(border: Border.all(width: 1, color: this.color ?? Colors.grey.shade300)),
        width: 22,
        height: 22,
        padding: EdgeInsets.all(2),
        child: buildCheckFill(context));
  }

  buildCheckFill(BuildContext context) {
    if (!completed) return null;
    return Container(color: barColor);
  }

  buildBar(BuildContext context) {
    if (total <= 1) {
      return Container(padding: EdgeInsets.only(left: 8), child: buildTitle(context));
    }
    return Container(
        margin: EdgeInsets.only(left: 4),
        height: 22,
        decoration:
            completed ? null : BoxDecoration(border: Border.all(width: 1, color: this.color ?? Colors.grey.shade300)),
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
                    children: [Expanded(child: buildTitle(context)), buildCount(context)]))
          ],
        ));
  }

  buildTitle(BuildContext context) {
    return Container(child: description);
  }

  buildCount(BuildContext context) {
    if (total <= 1) return Container();

    return Text("$progress/$total",
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: this.color ?? Colors.grey.shade300));
  }

  buildProgressBar(BuildContext context) {
    Color color = Color.lerp(barColor, Colors.black, .1);
    if (completed) return Container();
    return Container(
        margin: EdgeInsets.all(2),
        color: Theme.of(context).colorScheme.secondaryContainer,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: min(progress / total, 1),
          child: Container(color: color),
        ));
  }

  Color get barColor {
    return DestinyData.objectiveProgress;
  }
}
