import 'dart:math';

import 'package:bungie_api/enums/destiny_unlock_value_uistyle.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

const _objectiveBarHeight = 22.0;

class ObjectiveWidget extends StatelessWidget {
  final Color? color;
  final Color? barColor;

  final bool forceComplete;
  final int objectiveHash;
  final DestinyObjectiveProgress? objective;
  final String? placeholder;

  final bool? parentCompleted;

  final bool omitCheckBox;

  const ObjectiveWidget(
    this.objectiveHash, {
    Key? key,
    this.objective,
    this.color,
    this.barColor,
    this.parentCompleted,
    this.forceComplete = false,
    this.placeholder,
    this.omitCheckBox = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(4),
        child: Row(children: [
          if (!omitCheckBox) buildCheck(context),
          Expanded(
            child: buildBar(context),
          )
        ]));
  }

  Widget buildCheck(BuildContext context) {
    return Container(
        decoration: BoxDecoration(border: Border.all(width: 1, color: color ?? context.theme.onSurfaceLayers.layer2)),
        width: _objectiveBarHeight,
        height: _objectiveBarHeight,
        padding: const EdgeInsets.all(2),
        child: buildCheckFill(context));
  }

  Widget? buildCheckFill(BuildContext context) {
    if (!isComplete) return null;
    return Container(color: getBarColor(context));
  }

  bool get isComplete {
    return forceComplete || (objective?.complete ?? false);
  }

  Color getForegroundColor(BuildContext context) => color ?? context.theme.onSurfaceLayers.layer0;

  Widget buildBar(BuildContext context) {
    final definition = context.definition<DestinyObjectiveDefinition>(objectiveHash);
    if (definition == null) return Container();
    final completionValue = definition.completionValue ?? 0;
    if (completionValue <= 1) {
      return Container(
        padding: const EdgeInsets.only(left: 8, right: 4),
        child: Row(
          children: [
            Expanded(child: buildTitle(context)),
            buildProgressValue(context),
          ],
        ),
      );
    }
    return Container(
        margin: const EdgeInsets.only(left: 4),
        height: _objectiveBarHeight,
        decoration: isComplete ? null : BoxDecoration(border: Border.all(width: 1, color: getForegroundColor(context))),
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
                children: [
                  Expanded(child: buildTitle(context)),
                  buildProgressValue(context),
                ],
              ),
            ),
          ],
        ));
  }

  Widget buildTitle(BuildContext context) {
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
        style: context.textTheme.body.copyWith(
          color: getForegroundColor(context),
        ),
      ),
    );
  }

  Widget buildProgressValue(BuildContext context) {
    final definition = context.definition<DestinyObjectiveDefinition>(objectiveHash);
    if (definition == null) return Container();
    if (definition.completedValueStyle == DestinyUnlockValueUIStyle.DateTime) {
      return buildDate(context);
    }
    return buildCount(context);
  }

  Widget buildCount(BuildContext context) {
    final definition = context.definition<DestinyObjectiveDefinition>(objectiveHash);
    int progress = objective?.progress ?? 0;
    int maximum = definition?.completionValue ?? 0;
    var allowOvercompletion = definition?.allowOvercompletion ?? false;
    if (!allowOvercompletion) {
      progress = progress.clamp(0, maximum);
    }

    if (forceComplete) {
      progress = maximum;
    }

    final formatter = NumberFormat.decimalPattern(context.currentLanguage);
    String formattedProgress = formatter.format(progress);
    String formattedTotal = formatter.format(maximum);

    return Text(
      maximum <= 1 ? formattedProgress : "$formattedProgress/$formattedTotal",
      style: context.textTheme.body.copyWith(
        color: getForegroundColor(context),
      ),
    );
  }

  Widget buildDate(BuildContext context) {
    final formatter = DateFormat.yMd(context.currentLanguage);
    final objectiveProgress = objective?.progress ?? 0;
    final progress = formatter.format(DateTime.fromMillisecondsSinceEpoch(objectiveProgress * 1000));
    return Text(
      progress,
      style: context.textTheme.body.copyWith(
        color: getForegroundColor(context),
      ),
    );
  }

  Widget buildProgressBar(BuildContext context) {
    final definition = context.definition<DestinyObjectiveDefinition>(objectiveHash);
    int progress = objective?.progress ?? 0;
    int total = definition?.completionValue ?? 0;
    Color? color = Color.lerp(getBarColor(context), context.theme.surfaceLayers.layer0, .1);
    if (isComplete) return Container();
    return Container(
        margin: const EdgeInsets.all(2),
        color: Theme.of(context).colorScheme.secondaryContainer,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: max(0.01, min(progress / total, 1)),
          child: Container(color: color),
        ));
  }

  Color? getBarColor(BuildContext context) {
    if (parentCompleted == true) {
      return context.theme.successLayers.layer0;
    }
    return barColor ?? context.theme.successLayers.layer0;
  }
}
