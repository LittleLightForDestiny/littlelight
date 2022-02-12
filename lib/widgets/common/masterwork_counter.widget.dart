// @dart=2.9

import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

class MasterworkCounterWidget extends StatefulWidget {
  final DestinyItemComponent item;

  MasterworkCounterWidget(this.item, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MasterworkCounterWidgetState();
  }
}

class MasterworkCounterWidgetState extends State<MasterworkCounterWidget>
    with AutomaticKeepAliveClientMixin, ProfileConsumer, ManifestConsumer {
  DestinyObjectiveProgress masterworkObjective;
  DestinyObjectiveDefinition masterworkObjectiveDefinition;

  initState() {
    super.initState();
    loadDefinitions();
  }

  loadDefinitions() async {
    if (widget.item == null) return;
    var plugObjectives = profile.getPlugObjectives(widget.item.itemInstanceId);
    for (var objectives in plugObjectives.values) {
      for (var objective in objectives) {
        if (objective.visible) {
          masterworkObjective = objective;
          masterworkObjectiveDefinition =
              await manifest.getDefinition<DestinyObjectiveDefinition>(objective.objectiveHash);
        }
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (this.masterworkObjective == null || this.masterworkObjectiveDefinition?.displayProperties?.icon == null) {
      return Container();
    }
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 26,
              height: 26,
              child: QueuedNetworkImage(
                  imageUrl: BungieApiService.url(masterworkObjectiveDefinition.displayProperties.icon)),
            ),
            Container(
              width: 4,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(masterworkObjectiveDefinition.progressDescription,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 11)),
                Container(
                  width: 4,
                ),
                Text("${masterworkObjective.progress}", style: TextStyle(color: Colors.amber.shade200, fontSize: 15)),
              ],
            ))
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
