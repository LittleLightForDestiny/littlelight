import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';

import 'package:flutter/material.dart';
import 'package:little_light/screens/item_detail.screen.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/objective.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

class PursuitItemWidget extends StatefulWidget {
  final String characterId;
  final ProfileService profile = ProfileService();
  final ManifestService manifest = ManifestService();

  final DestinyItemComponent item;

  PursuitItemWidget({Key key, this.characterId, this.item}) : super(key: key);

  _PursuitItemWidgetState createState() => _PursuitItemWidgetState();
}

class _PursuitItemWidgetState extends State<PursuitItemWidget>
    with AutomaticKeepAliveClientMixin {
  DestinyInventoryItemDefinition definition;
  Map<int, DestinyObjectiveDefinition> objectiveDefinitions;
  List<DestinyObjectiveProgress> itemObjectives;
  bool fullyLoaded = false;

  @override
  void initState() {
    super.initState();
    loadDefinitions();
  }

  Future<void> loadDefinitions() async {
    definition = await widget.manifest
        .getDefinition<DestinyInventoryItemDefinition>(widget.item.itemHash);
    itemObjectives =
        widget.profile.getItemObjectives(widget.item.itemInstanceId);
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
                            widget.item,
                            definition,
                            null,
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
