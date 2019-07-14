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
  final int plugHash;
  TrackedPlugItemWidget({Key key, DestinyItemComponent item, this.plugHash})
      : super(
          key: key,
          item: item,
        );

  TrackedPlugItemWidgetState createState() => TrackedPlugItemWidgetState();
}

class TrackedPlugItemWidgetState
    extends TrackedPursuitItemWidgetState<TrackedPlugItemWidget> {
  DestinyInventoryItemDefinition plugDefinition;

  @override
  dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadDefinitions();
    updateProgress();
  }

  @override
  Future<void> loadDefinitions() async {
    definition = await widget.manifest
        .getDefinition<DestinyInventoryItemDefinition>(widget.item.itemHash);
    plugDefinition = await widget.manifest.getDefinition<DestinyInventoryItemDefinition>(widget.plugHash);
    objectiveDefinitions = await widget.manifest
        .getDefinitions<DestinyObjectiveDefinition>(
            itemObjectives?.map((o) => o.objectiveHash));
    setState(() {});
  }

  updateProgress() {
    var sockets = widget.profile.getItemSockets(widget.item.itemInstanceId);
    var plug = sockets.firstWhere((socket)=>socket.plugHash == widget.plugHash || (socket?.reusablePlugHashes?.contains(widget.plugHash) ?? false), orElse: ()=>null);
    if(plug == null){
      setState((){});
      return;
    }
    if(plug?.plugHash == widget.plugHash){
      itemObjectives = plug.plugObjectives;
    }else if(plug.reusablePlugHashes.contains(widget.plugHash)){
      itemObjectives = plug.reusablePlugs.firstWhere((p)=>p.plugItemHash == widget.plugHash, orElse:()=>null).plugObjectives;
    }
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

  Widget buildDescription(BuildContext context) {
    return Text(
      plugDefinition?.displayProperties?.description ?? "",
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
    );
  }
}
