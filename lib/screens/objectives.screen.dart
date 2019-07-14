import 'dart:async';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'package:little_light/services/littlelight/littlelight.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/refresh_button.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/presentation_nodes/record_item.widget.dart';
import 'package:little_light/widgets/progress_tabs/tracked_plug_item.widget.dart';
import 'package:little_light/widgets/progress_tabs/tracked_pursuit_item.widget.dart';

class ObjectivesScreen extends StatefulWidget {
  final ProfileService profile = ProfileService();
  final ManifestService manifest = ManifestService();
  @override
  LoadoutScreenState createState() => new LoadoutScreenState();
}

class LoadoutScreenState extends State<ObjectivesScreen> {
  List<TrackedObjective> objectives;
  Map<TrackedObjective, DestinyItemComponent> items;

  StreamSubscription<NotificationEvent> subscription;

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadObjectives();
    subscription = NotificationService().listen((event) {
      if (event.type == NotificationType.receivedUpdate ||
          event.type == NotificationType.localUpdate) {
        loadObjectives();
      }
    });
  }

  void loadObjectives() async {
    LittleLightService service = LittleLightService();
    objectives = (await service.getTrackedObjectives()).reversed.toList();
    items = new Map();
    var itemObjectives =
        objectives.where((o) => o.type == TrackedObjectiveType.Item);
    var plugObjectives =
        objectives.where((o) => o.type == TrackedObjectiveType.Plug);
    for (var o in itemObjectives) {
      DestinyItemComponent item = await findItem(o);
      if (item != null) {
        items[o] = item;
      }
    }
    for (var o in plugObjectives) {
      DestinyItemComponent item = await findPlugItem(o);
      if (item != null) {
        items[o] = item;
      }
    }
    setState(() {});
  }

  Future<DestinyItemComponent> findItem(TrackedObjective objective) async {
    var item = widget.profile
        .getCharacterInventory(objective.characterId)
        .firstWhere((i) => i.itemInstanceId == objective.instanceId,
            orElse: () => null);
    if (item != null) return item;
    var items = widget.profile.getItemsByInstanceId([objective.instanceId]);
    if (items.length > 0) return items.first;
    var def = await widget.manifest
        .getDefinition<DestinyInventoryItemDefinition>(objective.hash);
    if (def?.objectives?.questlineItemHash != null) {
      var questline = await widget.manifest
          .getDefinition<DestinyInventoryItemDefinition>(
              def.objectives.questlineItemHash);
      var questStepHashes =
          questline?.setData?.itemList?.map((i) => i.itemHash)?.toList() ?? [];
      var item = widget.profile
          .getCharacterInventory(objective.characterId)
          .firstWhere((i) => questStepHashes.contains(i.itemHash),
              orElse: () => null);
      if (item != null) return item;
    }
    return null;
  }

  Future<DestinyItemComponent> findPlugItem(TrackedObjective objective) async {
    var items = widget.profile.getAllItems();
    var item = items.firstWhere((i) => i.itemHash == objective.parentHash,
        orElse: () => null);
    if (item == null) return null;
    var sockets = widget.profile.getItemSockets(item.itemInstanceId);
    var plug = sockets.firstWhere(
        (p) =>
            p.plugHash == objective.hash ||
            (p?.reusablePlugHashes?.contains(objective.hash) ?? false),
        orElse: () => null);
    if (plug?.plugObjectives == null) {
      return null;
    }
    return item;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            actions: <Widget>[
              RefreshButtonWidget(
                padding: EdgeInsets.all(8),
              )
            ],
            title: TranslatedTextWidget("Objectives")),
        body: buildBody(context),
      ),
      InventoryNotificationWidget(
        key: Key("notification_widget"),
        barHeight: 0,
      )
    ]);
  }

  Widget buildBody(BuildContext context) {
    if (objectives == null) {
      return Container();
    }

    if (objectives.length == 0) {
      return Container(
          padding: EdgeInsets.all(16),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TranslatedTextWidget(
                  "You aren't tracking any objectives yet. Add one from Triumphs or Pursuits.",
                  textAlign: TextAlign.center,
                ),
                Container(height: 16),
              ]));
    }

    return StaggeredGridView.countBuilder(
      padding: EdgeInsets.all(4),
      crossAxisCount: 30,
      itemCount: objectives.length,
      itemBuilder: (BuildContext context, int index) => getItem(context, index),
      staggeredTileBuilder: (int index) => getTileBuilder(index),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }

  StaggeredTile getTileBuilder(int index) {
    bool isTablet = MediaQueryHelper(context).tabletOrBigger;
    return StaggeredTile.fit(isTablet ? 15 : 30);
  }

  Widget getItem(BuildContext context, int index) {
    TrackedObjective objective = objectives[index];
    switch (objective.type) {
      case TrackedObjectiveType.Triumph:
        return RecordItemWidget(
          hash: objective.hash,
          key: Key("loadout_${objective.hash}"),
        );

      case TrackedObjectiveType.Item:
        if (items[objective] != null) {
          return TrackedPursuitItemWidget(
            characterId: objective.characterId,
            item: items[objective],
          );
        }
        break;

      case TrackedObjectiveType.Plug:
        if (items[objective] != null) {
          return TrackedPlugItemWidget(
            item: items[objective],
            plugHash: objective.hash,
          );
        }
    }
    return Container();
  }
}
