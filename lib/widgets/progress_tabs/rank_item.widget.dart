// @dart=2.9

import 'dart:async';
import 'package:bungie_api/models/destiny_progression.dart';
import 'package:bungie_api/models/destiny_progression_definition.dart';
import 'package:bungie_api/models/destiny_progression_step_definition.dart';

import 'package:flutter/material.dart';

import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/notification/notification.package.dart';
import 'package:little_light/services/profile/profile.consumer.dart';

import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/flutter/filled_circular_progress_indicator.dart';

class RankItemWidget extends StatefulWidget {
  final String characterId;

  final DestinyProgression progression;

  RankItemWidget({Key key, this.characterId, this.progression}) : super(key: key);

  RankItemWidgetState createState() => RankItemWidgetState();
}

class RankItemWidgetState<T extends RankItemWidget> extends State<T>
    with AutomaticKeepAliveClientMixin, ProfileConsumer, ManifestConsumer, NotificationConsumer {
  DestinyProgressionDefinition definition;
  StreamSubscription<NotificationEvent> subscription;

  int progressTotal;

  int get hash => widget.progression.progressionHash;
  DestinyProgression progression;

  @override
  void initState() {
    super.initState();

    progression = widget.progression;
    loadDefinitions();
    subscription = notifications.listen((event) {
      if (event.type == NotificationType.receivedUpdate && mounted) {
        progression = profile.getCharacterProgression(widget.characterId).progressions["$hash"];
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
    definition = await manifest.getDefinition<DestinyProgressionDefinition>(hash);
    progressTotal = definition.steps.fold(0, (v, s) => v + s.progressTotal);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (definition == null || progression == null) {
      return Container(height: 200, color: Theme.of(context).colorScheme.secondaryContainer);
    }
    return Stack(children: [
      Positioned.fill(child: Container(alignment: Alignment.center, child: buildRankProgress(context))),
      Positioned.fill(child: Container(alignment: Alignment.center, child: buildStepProgress(context))),
      Positioned.fill(child: Container(alignment: Alignment.center, child: buildBackgroundCircle(context))),
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
              decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(200)),
            )));
  }

  Widget buildLabels(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildTopLabels(context),
          FractionallySizedBox(widthFactor: .60, child: AspectRatio(aspectRatio: 1, child: Container())),
          buildBottomLabels(context),
        ]);
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
        "${progression?.progressToNextLevel}/${progression?.nextLevelAt}",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      Text(
        "${progression.currentProgress}/$progressTotal",
        style: TextStyle(fontSize: 10),
      )
    ]);
  }

  buildRankProgress(BuildContext context) {
    var mainColor = Color.fromARGB(255, definition.color.red, definition.color.green, definition.color.blue);

    return FractionallySizedBox(
        widthFactor: .72,
        child: AspectRatio(
          aspectRatio: 1,
          child: FilledCircularProgressIndicator(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Color.lerp(mainColor, Theme.of(context).colorScheme.onSurface, .5)),
              value: progression.currentProgress / progressTotal),
        ));
  }

  buildStepProgress(BuildContext context) {
    return FractionallySizedBox(
        widthFactor: .68,
        child: AspectRatio(
          aspectRatio: 1,
          child: FilledCircularProgressIndicator(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, definition.color.red, definition.color.green, definition.color.blue)),
              value: (progression?.progressToNextLevel ?? 0) / (progression?.nextLevelAt ?? 1)),
        ));
  }

  DestinyProgressionStepDefinition get currentStep =>
      definition.steps[widget.progression.level.clamp(0, definition.steps.length - 1)];

  @override
  bool get wantKeepAlive => true;
}
