import 'dart:async';
import 'package:bungie_api/models/destiny_milestone.dart';
import 'package:bungie_api/models/destiny_milestone_definition.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

class MilestoneItemWidget extends StatefulWidget {
  final String characterId;
  final ProfileService profile = ProfileService();
  final ManifestService manifest = ManifestService();
  final NotificationService broadcaster = NotificationService();

  final DestinyMilestone item;

  MilestoneItemWidget({Key key, this.characterId, this.item}) : super(key: key);

  _MilestoneItemWidgetState createState() => _MilestoneItemWidgetState();
}

class _MilestoneItemWidgetState extends State<MilestoneItemWidget>
    with AutomaticKeepAliveClientMixin {
  DestinyMilestoneDefinition definition;
  Map<int, DestinyObjectiveDefinition> objectiveDefinitions;
  List<DestinyObjectiveProgress> itemObjectives;
  StreamSubscription<NotificationEvent> subscription;
  bool fullyLoaded = false;

  @override
  void initState() {
    super.initState();
    loadDefinitions();
    subscription = widget.broadcaster.listen((event) {
      if ((event.type == NotificationType.receivedUpdate ||
              event.type == NotificationType.localUpdate) &&
          mounted) {
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
    definition = await widget.manifest
        .getDefinition<DestinyMilestoneDefinition>(widget.item.milestoneHash);
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
    if (definition == null) {
      return Container(height: 200, color: Colors.blueGrey.shade900);
    }
    return Stack(children: [
      Container(
          color: Colors.blueGrey.shade900,
          margin: EdgeInsets.all(8).copyWith(top: 0),
          child: Column(children: <Widget>[
            Stack(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(8).copyWith(left: 88),
                  child: Text(
                    definition.displayProperties.name.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  constraints: BoxConstraints(minHeight: 60),
                  padding: EdgeInsets.all(8).copyWith(left: 88),
                  child: Text(
                    definition.displayProperties.description,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                  ),
                )
              ]),
              Positioned(
                  top: 8,
                  left: 8,
                  width: 72,
                  height: 72,
                  child: Container(
                      foregroundDecoration: BoxDecoration(
                          border: Border.all(
                              width: 2, color: Colors.grey.shade300)),
                      child: QueuedNetworkImage(
                          imageUrl: BungieApiService.url(
                              definition.displayProperties.icon))))
            ]),
          ]))
    ]);
  }

  @override
  bool get wantKeepAlive => fullyLoaded ?? false;
}
