import 'dart:async';
import 'package:bungie_api/enums/destiny_item_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';

import 'package:flutter/material.dart';
import 'package:little_light/services/littlelight/models/tracked_objective.model.dart';
import 'package:little_light/widgets/progress_tabs/pursuit_item.widget.dart';
import 'package:little_light/services/littlelight/littlelight.service.dart';

class TrackedPursuitItemWidget extends PursuitItemWidget {
  final String itemInstanceId;
  final int hash;

  TrackedPursuitItemWidget(
      {Key key, String characterId, this.itemInstanceId, this.hash})
      : super(
          key: key,
          characterId: characterId,
        );

  TrackedPursuitItemWidgetState createState() =>
      TrackedPursuitItemWidgetState();
}

class TrackedPursuitItemWidgetState
    extends PursuitItemWidgetState<TrackedPursuitItemWidget> {
  DestinyItemComponent _item;

  @override
  String get itemInstanceId => _item?.itemInstanceId;

  @override
  int get hash => _item?.itemHash;

  @override
  DestinyItemComponent get item => _item;

  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  Future<void> loadDefinitions() async {
    definition = await widget.manifest
        .getDefinition<DestinyInventoryItemDefinition>(widget.hash);

    if ([
      DestinyItemType.Quest,
      DestinyItemType.QuestStep,
      DestinyItemType.Bounty
    ].contains(definition.itemType)) {
      List<DestinyItemComponent> charInventory =
          widget.profile.getCharacterInventory(widget.characterId);
      _item = charInventory.firstWhere(
          (i) => i.itemInstanceId == widget.itemInstanceId,
          orElse: () => null);

      if (_item == null) {
        _item = charInventory.firstWhere((i) => i.itemHash == widget.hash,
            orElse: () => null);
      }
      if (_item == null) {
        var questlineDefinition = await widget.manifest
            .getDefinition<DestinyInventoryItemDefinition>(
                definition.objectives.questlineItemHash);
        if (questlineDefinition != null) {
          List<int> questStepsHashes = questlineDefinition.setData.itemList
              .map((i) => i.itemHash)
              .toList();
          _item = charInventory.firstWhere(
              (i) => questStepsHashes.contains(i.itemHash),
              orElse: () => null);
        }
      }
      if (_item == null) {
        LittleLightService().removeTrackedObjective(TrackedObjectiveType.Item,
            widget.hash, widget.itemInstanceId, widget.characterId);
        return;
      }
    } else {
      List<DestinyItemComponent> allInventory = widget.profile.getAllItems();
      _item = allInventory.firstWhere(
          (i) => i.itemInstanceId == widget.itemInstanceId,
          orElse: () => null);
      if (_item == null) {
        _item = allInventory.firstWhere((i) => i.itemHash == widget.hash,
            orElse: () => null);
      }
      if (_item == null) {
        LittleLightService().removeTrackedObjective(TrackedObjectiveType.Item,
            widget.hash, widget.itemInstanceId, widget.characterId);
        return;
      }
    }

    itemObjectives = widget.profile.getItemObjectives(itemInstanceId);
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
    return super.build(context);
  }

  Widget buildCurrentObjective(
      BuildContext context, DestinyObjectiveProgress objective) {
    if (objectiveDefinitions == null) return Container();
    return super.buildCurrentObjective(context, objective);
  }
}
