import 'package:bungie_api/models/destiny_progression.dart';
import 'package:bungie_api/models/destiny_progression_definition.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/progress_bars/filled_circular_progress_indicator.dart';
import 'package:little_light/utils/color_utils.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:tinycolor2/tinycolor2.dart';

class CoreActivityRankItemWidget extends StatelessWidget {
  final DestinyProgression progression;

  CoreActivityRankItemWidget(this.progression, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final definition = context.definition<DestinyProgressionDefinition>(progression.progressionHash);
    final color = definition?.color?.toMaterialColor() ?? context.theme.primaryLayers;
    final bgColor = color.mix(context.theme.surfaceLayers, 60);
    final rankProgress = progression.currentProgress ?? 0;
    final levelCap = progression.levelCap ?? -1;
    final stepsTotal = definition?.steps?.fold<int>(0, (v, s) => v + (s.progressTotal ?? 0)) ?? 0;
    final rankTotal = levelCap > 0 ? stepsTotal : 0;
    final rankProportional = rankTotal > 0 ? rankProgress / rankTotal : 0.0;
    final stepProgress = progression.progressToNextLevel ?? 0;
    final stepTotal = progression.nextLevelAt ?? 1;
    final stepProportional = stepProgress / stepTotal;
    return Stack(children: [
      Positioned.fill(
          child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(256),
            right: Radius.circular(32),
          ),
        ),
      )),
      Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildIcon(context, rankProgress: rankProportional, stepProgress: stepProportional),
          Expanded(
              child: buildInfo(context,
                  rankProgress: rankProgress, rankTotal: rankTotal, stepProgress: stepProgress, stepTotal: stepTotal)),
        ],
      )
    ]);
  }

  Widget buildIcon(BuildContext context, {double rankProgress = 0, double stepProgress = 0}) {
    final definition = context.definition<DestinyProgressionDefinition>(progression.progressionHash);
    final color = definition?.color?.toMaterialColor(1) ?? context.theme.primaryLayers;
    final step = definition?.steps?.elementAtOrNull(progression.stepIndex ?? 0);
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          Positioned(
            child: Padding(
              padding: EdgeInsets.all(4),
              child: buildBackgroundCircle(context),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: buildProgress(
                context,
                rankProgress,
                color: color.mix(context.theme.onSurfaceLayers, 50),
                backgroundColor: context.theme.surfaceLayers.layer3,
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: buildProgress(
                context,
                stepProgress,
                color: color.mix(context.theme.onSurfaceLayers, 25),
                backgroundColor: context.theme.surfaceLayers.layer2,
              ),
            ),
          ),
          Positioned(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: buildBackgroundCircle(context),
            ),
          ),
          Positioned.fill(
              child: Padding(
            padding: EdgeInsets.all(16),
            child: QueuedNetworkImage.fromBungie(step?.icon),
          )),
          Positioned.fill(
            child: Image.asset(
              'assets/imgs/rank-bg.png',
              alignment: Alignment.center,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBackgroundCircle(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer1,
        borderRadius: BorderRadius.circular(256),
      ),
    );
  }

  Widget buildProgress(BuildContext context, double rankProgress, {Color? color, Color? backgroundColor}) {
    color ??= context.theme.primaryLayers.layer0;

    return FilledCircularProgressIndicator(
      backgroundColor: backgroundColor,
      valueColor: AlwaysStoppedAnimation<Color>(color),
      value: rankProgress,
    );
  }

  Widget buildInfo(
    BuildContext context, {
    int rankProgress = 0,
    int rankTotal = 1,
    int stepProgress = 0,
    int stepTotal = 1,
  }) {
    final definition = context.definition<DestinyProgressionDefinition>(progression.progressionHash);
    final color = definition?.color?.toMaterialColor(1) ?? context.theme.primaryLayers;
    final totalSteps = definition?.steps?.length ?? 0;
    final step = definition?.steps?.elementAtOrNull(progression.stepIndex ?? 0);
    final currentLevel = progression.level ?? 0;
    final levelCap = progression.levelCap ?? 0;
    return Container(
      padding: EdgeInsets.all(2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
            decoration: BoxDecoration(
              color: context.theme.surfaceLayers.layer1,
              borderRadius: BorderRadius.circular(4),
            ),
            margin: EdgeInsets.only(bottom: 2),
            padding: EdgeInsets.all(2),
            child: Row(children: [
              Expanded(
                  child: Text(
                (step?.stepName ?? "").toUpperCase(),
                style: context.textTheme.itemNameMediumDensity,
                overflow: TextOverflow.fade,
                softWrap: false,
              )),
              Text("  ${currentLevel + 1}" + (levelCap > 0 ? "/$totalSteps" : ""),
                  style: context.textTheme.itemNameMediumDensity)
            ])),
        Expanded(
            child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            definition?.displayProperties?.name ?? "",
            style: context.textTheme.caption,
          ),
        )),
        buildProgressBar(
          context,
          label: "Total progress".translate(
            context,
          ),
          progress: rankProgress,
          total: rankTotal,
          color: color.mix(context.theme.onSurfaceLayers, 50),
        ),
        buildProgressBar(
          context,
          label: "Until next level".translate(
            context,
          ),
          progress: stepProgress,
          total: stepTotal,
          color: color.mix(context.theme.onSurfaceLayers, 25),
        ),
        Container(
            padding: EdgeInsets.all(2),
            margin: EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: context.theme.surfaceLayers.withOpacity(.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(children: [
              Expanded(child: Text("Reset count".translate(context), style: context.textTheme.caption)),
              Text("${progression.currentResetCount ?? 0}", style: context.textTheme.caption)
            ])),
      ]),
    );
  }

  Widget buildProgressBar(BuildContext context, {int progress = 0, int total = 1, String label = "", Color? color}) {
    color ??= context.theme.primaryLayers;
    return Container(
      padding: EdgeInsets.all(2),
      margin: EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.withOpacity(.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Text(label, style: context.textTheme.caption)),
          Text(total > 0 ? "$progress/$total" : "$progress", style: context.textTheme.caption)
        ]),
        Container(
          margin: EdgeInsets.only(top: 2),
          height: 5,
          color: context.theme.surfaceLayers.layer2,
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: (progress < total ? progress / total : 0),
            child: Container(color: color),
          ),
        ),
      ]),
    );
  }
}
