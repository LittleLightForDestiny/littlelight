import 'dart:async';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';

import 'package:flutter/material.dart';
import 'package:little_light/widgets/progress_tabs/pursuit_item.widget.dart';

class TrackedPursuitItemWidget extends PursuitItemWidget {
  final String itemInstanceId;
  final int hash;

  TrackedPursuitItemWidget({Key key, String characterId, this.itemInstanceId, this.hash}) : super(key: key, characterId:characterId, );

  TrackedPursuitItemWidgetState createState() => TrackedPursuitItemWidgetState();
}

class TrackedPursuitItemWidgetState extends PursuitItemWidgetState<TrackedPursuitItemWidget>{
  @override
  String get itemInstanceId => widget.itemInstanceId;
  
  @override
  int get hash => widget.hash;

  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  Future<void> loadDefinitions() async {
    super.loadDefinitions();
  }

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }

  List<Widget> buildObjectives(
      BuildContext context, DestinyInventoryItemDefinition questStepDef) {
    return super.buildObjectives(context, questStepDef);
  }

  Widget buildCurrentObjective(
      BuildContext context, DestinyObjectiveProgress objective) {
        if(objectiveDefinitions == null) return Container();
    return super.buildCurrentObjective(context, objective);
  }
}
