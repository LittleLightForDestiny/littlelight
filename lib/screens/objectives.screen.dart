import 'dart:async';
import 'dart:math';

import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'package:little_light/screens/item_detail.screen.dart';
import 'package:little_light/services/littlelight/objectives.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/media_query_helper.dart';
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
  ObjectivesScreenState createState() => new ObjectivesScreenState();
}

class ObjectivesScreenState extends State<ObjectivesScreen> {
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
    ObjectivesService service = ObjectivesService();
    objectives = (await service.getTrackedObjectives()).reversed.toList();
    items = new Map();
    var itemObjectives =
        objectives.where((o) => o.type == TrackedObjectiveType.Item);
    var plugObjectives =
        objectives.where((o) => o.type == TrackedObjectiveType.Plug);
    for (var o in itemObjectives) {
      DestinyItemComponent item = await service.findObjectiveItem(o);
      if (item != null) {
        items[o] = item;
      }
    }
    for (var o in plugObjectives) {
      DestinyItemComponent item = await service.findObjectivePlugItem(o);
      if (item != null) {
        items[o] = item;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        appBar: AppBar(
            leading: IconButton(enableFeedback: false,
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
    var screenPadding = MediaQuery.of(context).padding;
    if (objectives.length == 0) {
      return Container(
          padding: EdgeInsets.all(16).copyWith(left:max(screenPadding.left, 16), right:max(screenPadding.right, 16)),
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
      padding: EdgeInsets.only(left:max(screenPadding.left, 4), right:max(screenPadding.right, 4), bottom: max(screenPadding.bottom, 4), top:4),
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
            key: Key(
                "objective_${objective.hash}_objective_${objective.instanceId}_${objective.characterId}"),
            hash: objective.hash);

      case TrackedObjectiveType.Item:
        if (items[objective] != null) {
          return TrackedPursuitItemWidget(
              key: Key(
                  "objective_${objective.hash}_objective_${objective.instanceId}_${objective.characterId}"),
              characterId: objective.characterId,
              item: items[objective],
              onTap: (item, definition, instanceInfo, characterId) async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemDetailScreen(
                          item:item,
                          definition:definition,
                          instanceInfo:instanceInfo,
                          characterId: characterId,
                        ),
                  ),
                );
                loadObjectives();
              });
        }
        break;

      case TrackedObjectiveType.Plug:
        if (items[objective] != null) {
          return TrackedPlugItemWidget(
              key: Key(
                  "objective_${objective.hash}_objective_${objective.instanceId}_${objective.characterId}"),
              item: items[objective],
              plugHash: objective.hash,
              onTap: (item, definition, instanceInfo, characterId) async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemDetailScreen(
                          item:item,
                          definition:definition,
                          instanceInfo:instanceInfo,
                          characterId: characterId,
                        ),
                  ),
                );
                loadObjectives();
              });
        }
    }
    return Container();
  }
}
