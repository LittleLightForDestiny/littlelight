import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/destiny_item.stateful_widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/objective.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class QuestInfoWidget extends DestinyItemStatefulWidget {
  QuestInfoWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      String characterId})
      : super(item, definition, instanceInfo,
            key: key, characterId: characterId);

  @override
  QuestInfoWidgetState createState() {
    return QuestInfoWidgetState();
  }
}

class QuestInfoWidgetState extends DestinyItemState<QuestInfoWidget> {
  DestinyInventoryItemDefinition questlineDefinition;
  Map<int, DestinyInventoryItemDefinition> questSteps;
  Map<int, DestinyObjectiveDefinition> objectives;

  @override
  void initState() {
    super.initState();
    loadDefinitions();
  }

  loadDefinitions() async {
    questlineDefinition = await widget.manifest
        .getDefinition<DestinyInventoryItemDefinition>(
            definition.objectives.questlineItemHash);
    Iterable<int> stepHashes =
        questlineDefinition.setData.itemList.map((i) => i.itemHash);
    questSteps = await widget.manifest
        .getDefinitions<DestinyInventoryItemDefinition>(stepHashes);
    Iterable<int> objectiveHashes =
        questSteps.values.expand((step) => step.objectives.objectiveHashes);
    objectives = await widget.manifest
        .getDefinitions<DestinyObjectiveDefinition>(objectiveHashes);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    if (questlineDefinition != null) {
      items.add(buildQuestline(context));
    }
    if ((questSteps?.length ?? 0) > 0) {
      items.add(Container(
          padding: EdgeInsets.all(8),
          child: HeaderWidget(
              child: TranslatedTextWidget("Quest steps",
                  uppercase: true,
                  style: TextStyle(fontWeight: FontWeight.bold)))));
      items.addAll(questlineDefinition.setData.itemList
          .map((item) => buildQueststep(context, item.itemHash)));
    }
    if (items.length > 0) {
      return Column(children: items);
    }

    return Container();
  }

  Widget buildQueststep(BuildContext context, int hash) {
    var def = questSteps[hash];
    return Container(
        color:Colors.blueGrey.shade700,
        margin: EdgeInsets.all(8).copyWith(top: 0),
        child: Column(
          children: <Widget>[
            Stack(children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 88),
                  color: DestinyData.getTierColor(def.inventory.tierType),
                  child: Text(def.displayProperties.name.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold),),
                  height: 30,
                ),
                Container(
                  constraints: BoxConstraints(minHeight: 60),
                  padding: EdgeInsets.only(left: 88, top:8, right:8),
                  child:Text(def.displayProperties.description,style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),),
                )
              ]),
              Positioned(
                  top: 8,
                  left: 8,
                  width: 72,
                  height: 72,
                  child: Container(
                      foregroundDecoration: BoxDecoration(border: Border.all(width: 2, color: Colors.grey.shade300)),
                      color: DestinyData.getTierColor(def.inventory.tierType),
                      child: QueuedNetworkImage(
                          imageUrl: BungieApiService.url(
                              def.displayProperties.icon))))
            ])
          ]
              .followedBy(def.objectives.objectiveHashes
                  .map((hash) => buildObjective(context, hash)))
              .toList(),
        ));
  }

  Widget buildObjective(BuildContext context, int hash) {
    var def = objectives[hash];
    return Column(
      children: <Widget>[
        ObjectiveWidget(definition: def)
      ],
    );
  }

  Widget buildQuestline(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            HeaderWidget(
                child: TranslatedTextWidget("From the questline",
                    uppercase: true,
                    style: TextStyle(fontWeight: FontWeight.bold))),
            Container(
              height: 8,
            ),
            Container(
                color: DestinyData.getTierColor(
                    questlineDefinition.inventory.tierType),
                child: Row(
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.all(4),
                        foregroundDecoration: BoxDecoration(
                            border: Border.all(
                                width: 2, color: Colors.grey.shade300)),
                        child: SizedBox(
                            width: 72,
                            height: 72,
                            child: QueuedNetworkImage(
                              imageUrl: BungieApiService.url(
                                  questlineDefinition.displayProperties.icon),
                            ))),
                    Expanded(
                      child: Text(
                        questlineDefinition?.displayProperties?.name
                            ?.toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: DestinyData.getTierTextColor(
                                questlineDefinition.inventory.tierType)),
                      ),
                    )
                  ],
                ))
          ],
        ));
  }
}
