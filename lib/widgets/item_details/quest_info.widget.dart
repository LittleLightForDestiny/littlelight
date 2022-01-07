import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/objective.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class QuestInfoWidget extends BaseDestinyStatefulItemWidget{
  QuestInfoWidget(
      {DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      Key key,
      String characterId})
      : super(
            item: item,
            definition: definition,
            instanceInfo: instanceInfo,
            key: key,
            characterId: characterId);

  @override
  QuestInfoWidgetState createState() {
    return QuestInfoWidgetState();
  }
}

class QuestInfoWidgetState extends BaseDestinyItemState<QuestInfoWidget> with ProfileConsumer, ManifestConsumer {
  DestinyInventoryItemDefinition questlineDefinition;
  Map<int, DestinyInventoryItemDefinition> questSteps;
  Map<int, DestinyObjectiveDefinition> objectiveDefinitions;
  List<DestinyObjectiveProgress> itemObjectives;
  bool showSpoilers = false;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    loadDefinitions();
  }

  loadDefinitions() async {
    itemObjectives = profile
        .getItemObjectives(item?.itemInstanceId, characterId, item?.itemHash);
    questlineDefinition = await manifest
        .getDefinition<DestinyInventoryItemDefinition>(
            definition.objectives.questlineItemHash);
    List<int> stepHashes = questlineDefinition.setData?.itemList
            ?.map((i) => i.itemHash)
            ?.toList() ??
        [];
    currentIndex = stepHashes.indexOf(item.itemHash);
    questSteps = await manifest
        .getDefinitions<DestinyInventoryItemDefinition>(stepHashes);
    Iterable<int> objectiveHashes =
        questSteps.values.expand((step) => step.objectives.objectiveHashes);
    objectiveDefinitions = await manifest
        .getDefinitions<DestinyObjectiveDefinition>(objectiveHashes);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    if (questlineDefinition == null) {
      return Container();
    }
    items.add(buildQuestline(context));
    if ((questSteps?.length ?? 0) > 0) {
      items.add(Container(
          padding: EdgeInsets.all(8),
          child: HeaderWidget(
              alignment: Alignment.centerLeft,
              child: TranslatedTextWidget("Quest steps",
                  uppercase: true,
                  style: TextStyle(fontWeight: FontWeight.bold)))));
    }
    items.addAll(buildQuestSteps(context));
    if (currentIndex < questlineDefinition.setData.itemList.length &&
        !showSpoilers) {
      items.add(Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary:
                  DestinyData.getTierColor(definition?.inventory?.tierType),
            ),
            child: TranslatedTextWidget("View next steps",
                style: TextStyle(
                    color: DestinyData.getTierTextColor(
                        definition?.inventory?.tierType))),
            onPressed: () {
              showSpoilers = true;
              setState(() {});
            },
          )));
    }
    if (items.length > 0) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, children: items);
    }

    return Container();
  }

  List<Widget> buildQuestSteps(BuildContext context) {
    List<Widget> items = [];
    int lastIndex = showSpoilers
        ? questlineDefinition.setData.itemList.length - 1
        : currentIndex;
    for (int i = 0; i <= lastIndex; i++) {
      items.add(buildQueststep(context, i));
    }
    return items;
  }

  Widget buildQueststep(BuildContext context, int index) {
    if (questlineDefinition?.setData?.itemList == null || questSteps == null)
      return Container();
    var item = questlineDefinition.setData.itemList[index];
    var def = questSteps[item.itemHash];
    return Container(
        color: Theme.of(context).colorScheme.secondary,
        margin: EdgeInsets.all(8).copyWith(top: 0),
        child: Column(
            children: <Widget>[
          Stack(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(8).copyWith(left: 88),
                color: DestinyData.getTierColor(def.inventory.tierType),
                child: Text(
                  def.displayProperties.name.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                constraints: BoxConstraints(minHeight: 60),
                padding: EdgeInsets.all(8).copyWith(left: 88),
                child: Text(
                  def.displayProperties.description,
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
                        border:
                            Border.all(width: 2, color: Colors.grey.shade300)),
                    color: DestinyData.getTierColor(def.inventory.tierType),
                    child: QueuedNetworkImage(
                        imageUrl:
                            BungieApiService.url(def.displayProperties.icon))))
          ])
        ].followedBy(buildObjectives(context, def, index)).toList()));
  }

  List<Widget> buildObjectives(BuildContext context,
      DestinyInventoryItemDefinition questStepDef, int stepIndex) {
    if (stepIndex == currentIndex && itemObjectives != null) {
      return itemObjectives
          .map((objective) => buildCurrentObjective(context, objective))
          .toList();
    }
    return questStepDef.objectives.objectiveHashes
        .map((hash) => buildObjective(context, hash, stepIndex))
        .toList();
  }

  Widget buildObjective(BuildContext context, int hash, int stepIndex) {
    if (objectiveDefinitions == null) return Container();
    var def = objectiveDefinitions[hash];
    return Column(
      children: <Widget>[
        ObjectiveWidget(
            definition: def, forceComplete: stepIndex < currentIndex)
      ],
    );
  }

  Widget buildCurrentObjective(
      BuildContext context, DestinyObjectiveProgress objective) {
    if (objectiveDefinitions == null) return Container();
    var def = objectiveDefinitions[objective.objectiveHash];
    return Column(
      children: <Widget>[
        ObjectiveWidget(
          definition: def,
          objective: objective,
        )
      ],
    );
  }

  Widget buildQuestline(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            HeaderWidget(
                alignment: Alignment.centerLeft,
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
