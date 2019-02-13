import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/destiny_item.stateful_widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/objective.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class ItemObjectivesWidget extends DestinyItemStatefulWidget {
  ItemObjectivesWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      String characterId})
      : super(item, definition, instanceInfo,
            key: key, characterId: characterId);

  @override
  ItemObjectivesWidgetState createState() {
    return ItemObjectivesWidgetState();
  }
}

class ItemObjectivesWidgetState extends DestinyItemState<ItemObjectivesWidget> {
  Map<int, DestinyObjectiveDefinition> objectiveDefinitions;
  List<DestinyObjectiveProgress> itemObjectives;

  @override
  void initState() {
    super.initState();
    loadDefinitions();
  }

  loadDefinitions() async {
    itemObjectives = widget.profile.getItemObjectives(item?.itemInstanceId);
    objectiveDefinitions = await widget.manifest
        .getDefinitions<DestinyObjectiveDefinition>(
            definition?.objectives?.objectiveHashes);
    if(mounted){
      setState(() {});
    }
    
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    if ((objectiveDefinitions?.length ?? 0) == 0) return Container();

    items.add(Container(
        padding: EdgeInsets.all(8),
        child: HeaderWidget(
            child: TranslatedTextWidget("Objectives",
                uppercase: true,
                style: TextStyle(fontWeight: FontWeight.bold)))));
    items.addAll(buildObjectives(context));
    return Column(children: items);
  }

  List<Widget> buildObjectives(BuildContext context) {
    if (itemObjectives != null) {
      return itemObjectives
          .map((objective) => buildCurrentObjective(context, objective))
          .toList();
    }
    return definition.objectives.objectiveHashes
        .map((hash) => buildCurrentObjective(context))
        .toList();
  }

  Widget buildCurrentObjective(BuildContext context,
      [DestinyObjectiveProgress objective]) {
    var def = objectiveDefinitions[objective.objectiveHash];
    return 
        Container(
          padding: EdgeInsets.all(8),
          child:ObjectiveWidget(
          definition: def,
          objective: objective,
        ));
  }
}
