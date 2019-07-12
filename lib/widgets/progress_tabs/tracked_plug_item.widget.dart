import 'dart:async';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_plug.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';

import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/progress_tabs/tracked_pursuit_item.widget.dart';

class TrackedPlugItemWidget extends TrackedPursuitItemWidget {
  final int parentHash;
  TrackedPlugItemWidget({Key key, hash, this.parentHash})
      : super(
          key: key,
          hash: hash,
        );

  TrackedPlugItemWidgetState createState() => TrackedPlugItemWidgetState();
}

class TrackedPlugItemWidgetState
    extends TrackedPursuitItemWidgetState<TrackedPlugItemWidget> {
  DestinyInventoryItemDefinition plugDefinition;

  @override
  String get itemInstanceId => null;

  @override
  int get hash => widget.hash;

  int parentHash;

  @override
  DestinyItemComponent get item {
    return null;
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Future<void> loadDefinitions() async {
    plugDefinition = await widget.manifest
        .getDefinition<DestinyInventoryItemDefinition>(widget.hash);
    definition = await widget.manifest
        .getDefinition<DestinyInventoryItemDefinition>(widget.parentHash);
    objectiveDefinitions = await widget.manifest
        .getDefinitions<DestinyObjectiveDefinition>(
            itemObjectives?.map((o) => o.objectiveHash));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }

  Widget buildObjective(
      BuildContext context, DestinyObjectiveProgress objective) {
    if (objectiveDefinitions == null) return Container();
    return Column(children: [
      Container(
        padding: EdgeInsets.all(4),
        child:Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 24,
            height: 24,
            child: QueuedNetworkImage(
              imageUrl:
                  BungieApiService.url(plugDefinition?.displayProperties?.icon),
            ),
          ),
          Container(
            width: 8,
          ),
          Text(
            plugDefinition?.displayProperties?.name ?? "",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      )),
      super.buildObjective(context, objective)
    ]);
  }

  findItem() {}

  updateProgress() {
    var sockets = widget.profile.getAllSockets();
    DestinyItemPlug plugItem;
    sockets.values.firstWhere((s) {
      s.sockets.firstWhere((c) {
        plugItem = c?.reusablePlugs
            ?.firstWhere((c) => c.plugItemHash == hash, orElse: () => null);
        return plugItem != null;
      }, orElse: () => null);
      return plugItem != null;
    }, orElse: () => null);
    itemObjectives = plugItem?.plugObjectives;
    setState(() {});
  }

  Widget buildDescription(BuildContext context) {
    return Text(
      plugDefinition.displayProperties.description,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
    );
  }
}
