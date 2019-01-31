import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_lore_definition.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/destiny_item.stateful_widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/inventory_item_wrapper.widget.dart';

class QuestInfoWidget extends DestinyItemStatefulWidget {
  QuestInfoWidget(DestinyItemComponent item, DestinyInventoryItemDefinition definition, DestinyItemInstanceComponent instanceInfo, {Key key, String characterId}) : super(item, definition, instanceInfo, key:key, characterId:characterId);
  

  @override
  QuestInfoWidgetState createState() {
    return QuestInfoWidgetState();
  }
}

class QuestInfoWidgetState extends DestinyItemState<QuestInfoWidget>{
  DestinyInventoryItemDefinition questlineDefinition;
  Map<int, DestinyInventoryItemDefinition> questSteps;
  Map<int, DestinyObjectiveDefinition> objectives;

  @override
  void initState() {
    super.initState();
    loadDefinitions();
  }


  loadDefinitions() async{
    questlineDefinition = await widget.manifest.getDefinition<DestinyInventoryItemDefinition>(definition.objectives.questlineItemHash);
    Iterable<int> stepHashes = questlineDefinition.setData.itemList.map((i)=>i.itemHash);
    questSteps = await widget.manifest.getDefinitions<DestinyInventoryItemDefinition>(stepHashes);
    Iterable<int> objectiveHashes = questSteps.values.expand((step)=>step.objectives.objectiveHashes);
    objectives = await widget.manifest.getDefinitions<DestinyObjectiveDefinition>(objectiveHashes);
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget>items = [];
    if(questlineDefinition != null){
      items.add(buildQuestline(context));
    }
    if((questSteps?.length ?? 0) > 0){
      items.addAll(questlineDefinition.setData.itemList.map((item)=>buildQueststep(context, item.itemHash)));
    }
    if(items.length > 0){
      return Column(children:items);
    }
    
    return Container();
  }

  Widget buildQueststep(BuildContext context, int hash){
    var def = questSteps[hash];
    return Column(children: <Widget>[
      Text("####QUESTSTEP#####"),
      Text(def.displayProperties.name),
      Text(def.displayProperties.description),
    ].followedBy(
      def.objectives.objectiveHashes.map((hash)=>buildObjective(context, hash))
      ).toList(),);
  }

  Widget buildObjective(BuildContext context, int hash){
    var def = objectives[hash];
    return Column(children: <Widget>[
      Text("####OBJECTIVE#####"),
      Text(def.progressDescription ?? ""),
    ],);
  }

  Widget buildQuestline(BuildContext context){
    return Column(children: <Widget>[
      Text("####QUESTLINE#####"),
      Text(questlineDefinition.displayProperties.name),
      Text(questlineDefinition.displayProperties.description),
    ],);
  }

}