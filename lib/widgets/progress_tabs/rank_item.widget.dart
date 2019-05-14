import 'dart:async';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:bungie_api/models/destiny_progression.dart';
import 'package:bungie_api/models/destiny_progression_definition.dart';
import 'package:bungie_api/models/destiny_progression_step_definition.dart';

import 'package:flutter/material.dart';
import 'package:little_light/screens/item_detail.screen.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/objective.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

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
  Map<int, DestinyObjectiveDefinition> objectiveDefinitions;
  List<DestinyObjectiveProgress> itemObjectives;
  StreamSubscription<NotificationEvent> subscription;
  bool fullyLoaded = false;

  DestinyItemInstanceComponent instanceInfo;

  int get hash => widget.progression.progressionHash;
  DestinyProgression get item => widget.progression;

  @override
  void initState() {
    super.initState();
    loadDefinitions();
    subscription = widget.broadcaster.listen((event) {
      if (event.type == NotificationType.receivedUpdate ||
          event.type == NotificationType.localUpdate && mounted) {
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

    if (itemObjectives != null) {
      Iterable<int> objectiveHashes =
          itemObjectives.map((o) => o.objectiveHash);
      objectiveDefinitions = await widget.manifest
          .getDefinitions<DestinyObjectiveDefinition>(objectiveHashes);
    }
    if (mounted) {
      setState(() {});
      fullyLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (definition == null || item == null) {
      return Container(height: 200, color: Colors.blueGrey.shade900);
    }
    return Stack(children: [
      Positioned.fill(
          child: Container(
            alignment: Alignment.center,
            child: Image.asset('assets/imgs/rank-bg.png', alignment: Alignment.center,))),
      Container(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Flexible(
            child: Container(
          child: AspectRatio(
              aspectRatio: 1,
              child: QueuedNetworkImage(
                imageUrl: BungieApiService.url(currentStep.icon),
              )),
        )),
        Text(currentStep.stepName)
      ])),
    ]);
  }

  DestinyProgressionStepDefinition get currentStep =>
      definition.steps[widget.progression.level];

  @override
  bool get wantKeepAlive => fullyLoaded ?? false;
}
