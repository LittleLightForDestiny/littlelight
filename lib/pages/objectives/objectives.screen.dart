// @dart=2.9

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/core/blocs/profile/profile_component_groups.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'package:little_light/modules/triumphs/widgets/record_item.widget.dart';
import 'package:little_light/core/blocs/objective_tracking/objective_tracking.bloc.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/widgets/common/refresh_button.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/progress_tabs/pursuit_item/tracked_pursuit_item.widget.dart';
import 'package:provider/provider.dart';

class ObjectivesScreen extends StatefulWidget {
  @override
  ObjectivesScreenState createState() => ObjectivesScreenState();
}

class ObjectivesScreenState extends State<ObjectivesScreen> with ProfileConsumer {
  List<TrackedObjective> objectives;
  Map<TrackedObjective, ItemWithOwner> items;

  @override
  dispose() {
    profile.removeListener(loadObjectives);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadObjectives();
    profile.includeComponentsInNextRefresh(ProfileComponentGroups.collections + ProfileComponentGroups.triumphs);
    profile.addListener(loadObjectives);
  }

  void loadObjectives() async {
    profile.includeComponentsInNextRefresh(ProfileComponentGroups.collections + ProfileComponentGroups.triumphs);
    ObjectiveTracking service = context.read<ObjectiveTracking>();
    items = {};
    var itemObjectives = objectives.where((o) => o.type == TrackedObjectiveType.Item);
    var plugObjectives = objectives.where((o) => o.type == TrackedObjectiveType.Plug);
    for (var o in itemObjectives) {
      // DestinyItemComponent item = await service.findObjectiveItem(o);
      // if (item != null) {
      //   final ownerID = profile.getItemOwner(item.itemInstanceId);
      //   items[o] = ItemWithOwner(item, ownerID);
      // }
    }
    for (var o in plugObjectives) {
      // DestinyItemComponent item = await service.findObjectivePlugItem(o);
      // if (item != null) {
      //   final ownerID = profile.getItemOwner(item.itemInstanceId);
      //   items[o] = ItemWithOwner(item, ownerID);
      // }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var bottomPadding = MediaQuery.of(context).padding.bottom;
    return Stack(children: [
      Scaffold(
        appBar: AppBar(
            leading: IconButton(
              enableFeedback: false,
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            title: Text("Objectives".translate(context))),
        body: buildBody(context),
      ),
      Positioned(
        right: 8,
        bottom: 8 + bottomPadding,
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(18)),
          width: 36,
          height: 36,
          child: const RefreshButtonWidget(),
        ),
      ),
    ]);
  }

  Widget buildBody(BuildContext context) {
    if (objectives == null) {
      return Container();
    }
    var screenPadding = MediaQuery.of(context).padding;
    if (objectives.isEmpty) {
      return Container(
          padding:
              const EdgeInsets.all(16).copyWith(left: max(screenPadding.left, 16), right: max(screenPadding.right, 16)),
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
    bool isTablet = MediaQueryHelper(context).tabletOrBigger;
    return MasonryGridView.builder(
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        padding: EdgeInsets.only(
            left: max(screenPadding.left, 4),
            right: max(screenPadding.right, 4),
            bottom: max(screenPadding.bottom, 4),
            top: 4),
        itemCount: objectives.length,
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: isTablet ? 2 : 1),
        itemBuilder: (context, index) => SizedBox(height: 132, child: getItem(context, index)));
  }

  Widget getItem(BuildContext context, int index) {
    TrackedObjective objective = objectives[index];
    switch (objective.type) {
      case TrackedObjectiveType.Triumph:
        return RecordItemWidget(objective.hash, key: Key("objective_${objective.hash}"));

      case TrackedObjectiveType.Item:
        if (items[objective] != null) {
          return TrackedPursuitItemWidget(
              key: Key("objective_${objective.hash}_objective_${objective.instanceId}_${objective.characterId}"),
              characterId: objective.characterId,
              item: items[objective],
              onTap: () async {
                final item = items[objective];
                // await Navigator.push(
                //   context,
                //   ItemDetailsPageRoute(item: item),
                // );
                loadObjectives();
              });
        }
        break;

      case TrackedObjectiveType.Plug:
        return Container();
    }
    return Container();
  }
}
