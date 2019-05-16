import 'dart:async';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:bungie_api/models/destiny_progression.dart';
import 'package:bungie_api/models/destiny_progression_definition.dart';
import 'package:bungie_api/models/destiny_progression_step_definition.dart';

import 'package:flutter/material.dart';

import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';

import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/flutter/filled_circular_progress_indicator.dart';

class RankItemWidget extends StatefulWidget {
  final String characterId;
  final ProfileService profile = ProfileService();
  final ManifestService manifest = ManifestService();
  final NotificationService broadcaster = NotificationService();

  final DestinyProgression progression;

  RankItemWidget({Key key, this.characterId, this.progression})
      : super(key: key);

  RankItemWidgetState createState() => RankItemWidgetState();
}

class RankItemWidgetState<T extends RankItemWidget> extends State<T>
    with AutomaticKeepAliveClientMixin {
  DestinyProgressionDefinition definition;
  StreamSubscription<NotificationEvent> subscription;

  int progressTotal;

  int get hash => widget.progression.progressionHash;
  DestinyProgression progression;

  @override
  void initState() {
    progression = widget.progression;
    super.initState();
    loadDefinitions();
    subscription = widget.broadcaster.listen((event) {
      if (event.type == NotificationType.receivedUpdate && mounted) {
        progression = widget.profile.getCharacterProgression(widget.characterId).progressions["$hash"];
        setState(() {});
      }
    });
  }

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future<void> loadDefinitions() async {
    definition =
        await widget.manifest.getDefinition<DestinyProgressionDefinition>(hash);
    progressTotal = definition.steps.fold(0, (v, s) => v + s.progressTotal);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (definition == null || progression == null) {
      return Container(height: 200, color: Colors.blueGrey.shade900);
    }
    return Stack(children: [
      Positioned.fill(
          child: Container(
              alignment: Alignment.center, child: buildRankProgress(context))),
      Positioned.fill(
          child: Container(
              alignment: Alignment.center, child: buildStepProgress(context))),
      Positioned.fill(
          child: Container(
              alignment: Alignment.center,
              child: buildBackgroundCircle(context))),
      Positioned.fill(
          child: Container(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/imgs/rank-bg.png',
                alignment: Alignment.center,
              ))),
      Positioned.fill(
          child: Container(
        alignment: Alignment.center,
        child: buildRankIcon(context),
      )),
      Positioned.fill(
          child: Container(
        alignment: Alignment.center,
        child: buildLabels(context),
      ))
    ]);
  }

  Widget buildRankIcon(BuildContext context) {
    return FractionallySizedBox(
        widthFactor: .56,
        child: QueuedNetworkImage(
          imageUrl: BungieApiService.url(currentStep.icon),
        ));
  }

  Widget buildBackgroundCircle(BuildContext context) {
    return FractionallySizedBox(
        widthFactor: .60,
        child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(200)),
            )));
  }

  Widget buildLabels(BuildContext context) {
    return FractionallySizedBox(
        widthFactor: .60,
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          buildTopLabels(context),
          AspectRatio(aspectRatio: 1, child: Container()),
          buildBottomLabels(context),
        ]));
  }

  buildTopLabels(BuildContext context) {
    return Column(children: [
      Text(
        definition?.displayProperties?.name?.toUpperCase() ?? "",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
      ),
      Text(
        currentStep?.stepName?.toUpperCase() ?? "",
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      )
    ]);
  }

  buildBottomLabels(BuildContext context) {
    return Column(children: [
      Text(
        "${progression.progressToNextLevel}/${progression.nextLevelAt}",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      Text(
        "${progression.currentProgress}/$progressTotal",
        style: TextStyle(fontSize: 10),
      )
    ]);
  }

  buildRankProgress(BuildContext context) {
    var mainColor = Color.fromARGB(255, definition.color.red,
        definition.color.green, definition.color.blue);

    return FractionallySizedBox(
        widthFactor: .72,
        child: AspectRatio(
          aspectRatio: 1,
          child: FilledCircularProgressIndicator(
              backgroundColor: Colors.blueGrey.shade500,
              valueColor: AlwaysStoppedAnimation<Color>(
                  Color.lerp(mainColor, Colors.white, .5)),
              value: progression.currentProgress / progressTotal),
        ));
  }

  buildStepProgress(BuildContext context) {
    return FractionallySizedBox(
        widthFactor: .68,
        child: AspectRatio(
          aspectRatio: 1,
          child: FilledCircularProgressIndicator(
              backgroundColor: Colors.blueGrey.shade700,
              valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(
                  255,
                  definition.color.red,
                  definition.color.green,
                  definition.color.blue)),
              value: progression.progressToNextLevel / progression.nextLevelAt),
        ));
  }

  DestinyProgressionStepDefinition get currentStep =>
      definition.steps[widget.progression.level];

  @override
  bool get wantKeepAlive => true;
}
