import 'dart:async';
import 'package:bungie_api/enums/destiny_item_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';

import 'package:flutter/material.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'package:little_light/services/littlelight/littlelight.service.dart';

import 'package:little_light/widgets/progress_tabs/pursuit_item.widget.dart';

class TrackedPursuitItemWidget extends PursuitItemWidget {
  final String itemInstanceId;
  final int hash;

  TrackedPursuitItemWidget(
      {Key key, String characterId, this.itemInstanceId, this.hash})
      : super(
          key: key,
          characterId: characterId,
          includeCharacterIcon:true
        );

  TrackedPursuitItemWidgetState createState() =>
      TrackedPursuitItemWidgetState();
}

class TrackedPursuitItemWidgetState<T extends TrackedPursuitItemWidget>
    extends PursuitItemWidgetState<T> {
  DestinyItemComponent _item;

  DestinyInventoryItemDefinition questlineDefinition;

  @override
  String get itemInstanceId => _item?.itemInstanceId ?? widget.itemInstanceId;

  @override
  int get hash => _item?.itemHash ?? widget.hash;

  @override
  DestinyItemComponent get item {
    return _item ?? super.item;
  }

  @override
  void initState() {
    findItem();
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  Future<void> loadDefinitions() async {
    definition = await widget.manifest
        .getDefinition<DestinyInventoryItemDefinition>(hash);
    objectiveDefinitions = await widget.manifest
        .getDefinitions<DestinyObjectiveDefinition>(
            itemObjectives?.map((o) => o.objectiveHash));
    if (definition?.objectives?.questlineItemHash != null) {
      questlineDefinition = await widget.manifest
          .getDefinition<DestinyInventoryItemDefinition>(
              definition.objectives.questlineItemHash);
    }
    setState(() {});
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

  findItem() {
    var _item;
    if (this.itemInstanceId != null) {
      _item = widget.profile.getItemsByInstanceId([this.itemInstanceId]).first;
    }

    if (_item != null) {
      this._item = _item;
      setState(() {});
      return;
    }
    if ([
      DestinyItemType.Quest,
      DestinyItemType.QuestStep,
      DestinyItemType.Bounty
    ].contains(definition?.itemType)) {
      List<DestinyItemComponent> charInventory =
          widget.profile.getCharacterInventory(widget.characterId);
      _item = charInventory.firstWhere((i) => i.itemHash == widget.hash,
          orElse: () => null);
      if (_item != null) {
        this._item = _item;
        setState(() {});
        return;
      }
      if (questlineDefinition != null) {
        List<int> questStepsHashes = questlineDefinition.setData.itemList
            .map((i) => i.itemHash)
            .toList();
        _item = charInventory.firstWhere(
            (i) => questStepsHashes.contains(i.itemHash),
            orElse: () => null);
        this._item = _item;
        setState(() {});
        return;
      }
    }
    LittleLightService().removeTrackedObjective(TrackedObjectiveType.Item, widget.hash, instanceId:itemInstanceId, characterId: widget.characterId);
  }

  updateProgress() {
    var _itemInstanceId = this.itemInstanceId;
    itemObjectives = widget.profile.getItemObjectives(_itemInstanceId, widget.characterId, hash);
    setState(() {});
  }
}
