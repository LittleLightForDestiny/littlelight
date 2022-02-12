// @dart=2.9

import 'dart:async';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'package:little_light/services/littlelight/objectives.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/notification/notification.package.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/services/profile/profile_component_groups.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/objective.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class ItemObjectivesWidget extends BaseDestinyStatefulItemWidget {
  ItemObjectivesWidget(
      {DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      Key key,
      String characterId})
      : super(item: item, definition: definition, instanceInfo: instanceInfo, key: key, characterId: characterId);

  @override
  ItemObjectivesWidgetState createState() {
    return ItemObjectivesWidgetState();
  }
}

class ItemObjectivesWidgetState extends BaseDestinyItemState<ItemObjectivesWidget> with ProfileConsumer, ManifestConsumer, NotificationConsumer {
  Map<int, DestinyObjectiveDefinition> objectiveDefinitions;
  List<DestinyObjectiveProgress> itemObjectives;
  StreamSubscription<NotificationEvent> subscription;
  bool isTracking = false;

  @override
  void initState() {
    super.initState();
    loadDefinitions();
    this.updateTrackStatus();
    subscription = notifications.listen((event) {
      if (event.type == NotificationType.receivedUpdate || event.type == NotificationType.localUpdate && mounted) {
        updateProgress();
      }
    });
  }

  updateProgress() {
    var itemInstanceId = widget.item?.itemInstanceId;
    if (itemInstanceId == null) {
      var allItems = profile.getAllItems();
      var item = allItems.firstWhere((i) => i.item.itemHash == widget.definition?.hash, orElse: () => null);
      itemInstanceId = item?.item?.itemInstanceId;
    }

    itemObjectives = profile.getItemObjectives(itemInstanceId, characterId, item?.itemHash);

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
    subscription.cancel();
    super.dispose();
  }

  loadDefinitions() async {
    updateProgress();
    objectiveDefinitions =
        await manifest.getDefinitions<DestinyObjectiveDefinition>(definition?.objectives?.objectiveHashes);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    if ((objectiveDefinitions?.length ?? 0) == 0) return Container();
    if (itemObjectives != null) {
      if (itemObjectives.where((o) => o.visible != false).length == 0 && !isTracking) {
        return Container();
      }
    }
    items.add(Container(
        padding: EdgeInsets.all(8),
        child: HeaderWidget(
            padding: EdgeInsets.all(0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                  padding: EdgeInsets.all(8),
                  child: TranslatedTextWidget("Objectives",
                      uppercase: true, style: TextStyle(fontWeight: FontWeight.bold))),
              buildRefreshButton(context)
            ]))));
    items.addAll(buildObjectives(context));
    if (item != null) {
      items.add(buildTrackButton(context));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: items);
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
      padding: EdgeInsets.all(8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: isTracking ? DestinyData.trackingOnColor : DestinyData.trackingOffColor,
        ),
        child: isTracking
            ? TranslatedTextWidget("Stop Tracking", key: Key("stop_tracking"))
            : TranslatedTextWidget("Track Objectives", key: Key("track_objectives")),
        onPressed: () {
          var service = ObjectivesService();
          if (isTracking) {
            service.removeTrackedObjective(TrackedObjectiveType.Item, definition.hash,
                instanceId: widget.item?.itemInstanceId, characterId: widget.characterId);
          } else {
            service.addTrackedObjective(TrackedObjectiveType.Item, definition.hash,
                instanceId: widget.item?.itemInstanceId, characterId: widget.characterId);
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
                child: Container(padding: EdgeInsets.all(8), child: Icon(Icons.refresh)),
                onTap: () {
                  profile.fetchProfileData(components: ProfileComponentGroups.basicProfile);
                })
          ],
        ));
  }

  List<Widget> buildObjectives(BuildContext context) {
    if (itemObjectives != null) {
      return itemObjectives
          .map((objective) => buildCurrentObjective(context, objective.objectiveHash, objective))
          .toList();
    }
    return definition.objectives.objectiveHashes.map((hash) => buildCurrentObjective(context, hash)).toList();
  }

  Widget buildCurrentObjective(BuildContext context, int hash, [DestinyObjectiveProgress objective]) {
    var def = objectiveDefinitions[hash];
    return Container(
        padding: EdgeInsets.all(8),
        child: ObjectiveWidget(
          key: Key("objective_${objective?.objectiveHash}_${objective?.progress}"),
          definition: def,
          objective: objective,
        ));
  }
}
