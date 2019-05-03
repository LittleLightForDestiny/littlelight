import 'dart:async';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';

import 'package:flutter/material.dart';
import 'package:little_light/screens/item_detail.screen.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/objective.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

class PursuitItemWidget extends StatefulWidget {
  final String characterId;
  final ProfileService profile = ProfileService();
  final ManifestService manifest = ManifestService();
  final NotificationService broadcaster = NotificationService();

  final DestinyItemComponent item;

  PursuitItemWidget({Key key, this.characterId, this.item}) : super(key: key);

  PursuitItemWidgetState createState() => PursuitItemWidgetState();
}

class PursuitItemWidgetState<T extends PursuitItemWidget> extends State<T>
    with AutomaticKeepAliveClientMixin {
  DestinyInventoryItemDefinition definition;
  Map<int, DestinyObjectiveDefinition> objectiveDefinitions;
  List<DestinyObjectiveProgress> itemObjectives;
  StreamSubscription<NotificationEvent> subscription;
  bool fullyLoaded = false;

  String get itemInstanceId=>widget.item.itemInstanceId;
  int get hash=>widget.item.itemHash;
  DestinyItemComponent get item => widget.item;

  @override
  void initState() {
    super.initState();
    loadDefinitions();
    subscription = widget.broadcaster.listen((event) {
      if (event.type == NotificationType.receivedUpdate ||
          event.type == NotificationType.localUpdate && mounted) {
        itemObjectives =
            widget.profile.getItemObjectives(itemInstanceId);
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
        .getDefinition<DestinyInventoryItemDefinition>(hash);
    itemObjectives =
        widget.profile.getItemObjectives(itemInstanceId);
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
      Container(
          decoration: BoxDecoration(border: Border.all(color: DestinyData.getTierColor(definition.inventory.tierType), width: 1), color: Colors.blueGrey.shade900,),
          child: Column(
              children: <Widget>[
            Stack(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(8).copyWith(left: 88),
                  color:
                      DestinyData.getTierColor(definition.inventory.tierType),
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
                      color: DestinyData.getTierColor(
                          definition.inventory.tierType),
                      child: QueuedNetworkImage(
                          imageUrl: BungieApiService.url(
                              definition.displayProperties.icon))))
            ])
          ].followedBy(buildObjectives(context, definition)).toList())),
      Positioned.fill(
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailScreen(
                            item,
                            definition,
                            widget.profile.getInstanceInfo(item.itemInstanceId),
                            characterId: widget.characterId,
                            
                          ),
                    ),
                  );
                },
              )))
    ]);
  }

  List<Widget> buildObjectives(
      BuildContext context, DestinyInventoryItemDefinition questStepDef) {
    if (itemObjectives == null) return [];
    return itemObjectives
        .map((objective) => buildCurrentObjective(context, objective))
        .toList();
  }

  Widget buildCurrentObjective(
      BuildContext context, DestinyObjectiveProgress objective) {
        if(objectiveDefinitions == null) return Container();
    var definition = objectiveDefinitions[objective.objectiveHash];
    return Column(
      children: <Widget>[
        ObjectiveWidget(
          definition: definition,
          objective: objective,
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => fullyLoaded ?? false;
}
