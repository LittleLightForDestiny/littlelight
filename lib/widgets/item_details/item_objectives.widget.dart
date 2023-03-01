// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/core/blocs/profile/profile_component_groups.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'package:little_light/services/littlelight/objectives.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/objective.widget.dart';

class ItemObjectivesWidget extends BaseDestinyStatefulItemWidget {
  const ItemObjectivesWidget(
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
  ItemObjectivesWidgetState createState() {
    return ItemObjectivesWidgetState();
  }
}

class ItemObjectivesWidgetState
    extends BaseDestinyItemState<ItemObjectivesWidget>
    with ProfileConsumer, ManifestConsumer {
  Map<int, DestinyObjectiveDefinition> objectiveDefinitions;
  List<DestinyObjectiveProgress> itemObjectives;
  bool isTracking = false;

  @override
  void initState() {
    super.initState();
    loadDefinitions();
    updateTrackStatus();
    profile.addListener(updateProgress);
  }

  updateProgress() {
    var itemInstanceId = widget.item?.itemInstanceId;
    if (itemInstanceId == null) {
      var allItems = profile.getAllItems();
      var item = allItems.firstWhere(
          (i) => i.item.itemHash == widget.definition?.hash,
          orElse: () => null);
      itemInstanceId = item?.item?.itemInstanceId;
    }

    itemObjectives =
        profile.getItemObjectives(itemInstanceId, characterId, item?.itemHash);

    if (itemObjectives != null) {
      setState(() {});
      return;
    }

    var plugObjectives = profile.getPlugObjectives(itemInstanceId);
    var plugHash = "${widget.definition.hash}";
    if (plugObjectives?.containsKey(plugHash) ?? false) {
      itemObjectives = plugObjectives["${widget.definition.hash}"];
    }
    setState(() {});
    return;
  }

  @override
  dispose() {
    profile.removeListener(updateProgress);
    super.dispose();
  }

  loadDefinitions() async {
    updateProgress();
    objectiveDefinitions =
        await manifest.getDefinitions<DestinyObjectiveDefinition>(
            definition?.objectives?.objectiveHashes);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    if ((objectiveDefinitions?.length ?? 0) == 0) return Container();
    if (itemObjectives != null) {
      if (itemObjectives.where((o) => o.visible != false).isEmpty &&
          !isTracking) {
        return Container();
      }
    }
    items.add(Container(
        padding: const EdgeInsets.all(8),
        child: HeaderWidget(
            padding: const EdgeInsets.all(0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        "Objectives".translate(context).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )),
                  buildRefreshButton(context)
                ]))));
    items.addAll(buildObjectives(context));
    if (item != null) {
      items.add(buildTrackButton(context));
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: items);
  }

  updateTrackStatus() async {
    var objectives = await ObjectivesService().getTrackedObjectives();
    var tracked = objectives.firstWhere(
        (o) =>
            o.hash == widget.definition.hash &&
            (o.instanceId == widget.item?.itemInstanceId) &&
            o.characterId == widget.characterId,
        orElse: () => null);
    isTracking = tracked != null;
    if (!mounted) return;
    setState(() {});
  }

  Widget buildTrackButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: isTracking
              ? DestinyData.trackingOnColor
              : DestinyData.trackingOffColor,
        ),
        child: isTracking
            ? Text("Stop Tracking".translate(context),
                key: const Key("stop_tracking"))
            : Text("Track Objectives".translate(context),
                key: const Key("track_objectives")),
        onPressed: () {
          var service = ObjectivesService();
          if (isTracking) {
            service.removeTrackedObjective(
                TrackedObjectiveType.Item, definition.hash,
                instanceId: widget.item?.itemInstanceId,
                characterId: widget.characterId);
          } else {
            service.addTrackedObjective(
                TrackedObjectiveType.Item, definition.hash,
                instanceId: widget.item?.itemInstanceId,
                characterId: widget.characterId);
          }
          updateTrackStatus();
        },
      ),
    );
  }

  buildRefreshButton(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: Stack(
          children: <Widget>[
            InkWell(
                child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.refresh)),
                onTap: () {
                  profile.refresh(ProfileComponentGroups.basicProfile);
                })
          ],
        ));
  }

  List<Widget> buildObjectives(BuildContext context) {
    if (itemObjectives != null) {
      return itemObjectives
          .map((objective) => buildCurrentObjective(
              context, objective.objectiveHash, objective))
          .toList();
    }
    return definition.objectives.objectiveHashes
        .map((hash) => buildCurrentObjective(context, hash))
        .toList();
  }

  Widget buildCurrentObjective(BuildContext context, int hash,
      [DestinyObjectiveProgress objective]) {
    var def = objectiveDefinitions[hash];
    return Container(
        padding: const EdgeInsets.all(8),
        child: ObjectiveWidget(
          key: Key(
              "objective_${objective?.objectiveHash}_${objective?.progress}"),
          definition: def,
          objective: objective,
        ));
  }
}
