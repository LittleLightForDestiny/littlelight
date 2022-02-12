// @dart=2.9

import 'dart:async';
import 'package:bungie_api/models/destiny_activity_definition.dart';
import 'package:bungie_api/models/destiny_activity_modifier_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_milestone.dart';
import 'package:bungie_api/models/destiny_milestone_challenge_activity.dart';
import 'package:bungie_api/models/destiny_milestone_definition.dart';
import 'package:bungie_api/models/destiny_milestone_quest.dart';
import 'package:bungie_api/models/destiny_milestone_reward_category_definition.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/notification/notification.package.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/generic_progress_bar.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/icon_fonts/littlelight_icons.dart';

class MilestoneItemWidget extends StatefulWidget {
  final String characterId;

  
  

  final DestinyMilestone milestone;

  MilestoneItemWidget({Key key, this.characterId, this.milestone}) : super(key: key);

  MilestoneItemWidgetState createState() => MilestoneItemWidgetState();
}

class MilestoneItemWidgetState<T extends MilestoneItemWidget> extends State<T> with AutomaticKeepAliveClientMixin, ProfileConsumer, ManifestConsumer, NotificationConsumer {
  DestinyMilestoneDefinition definition;
  StreamSubscription<NotificationEvent> subscription;
  DestinyMilestone milestone;
  int get hash => widget.milestone.milestoneHash;
  bool fullyLoaded = false;
  Map<int, bool> activitiesOpened = Map();

  @override
  void initState() {
    super.initState();

    milestone = widget.milestone;
    loadDefinitions();
    subscription = notifications.listen((event) {
      if (event.type == NotificationType.receivedUpdate && mounted) {
        milestone = profile.getCharacterProgression(widget.characterId).milestones["$hash"];
        setState(() {});
      }
    });
  }

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future<void> loadDefinitions() async {
    definition = await manifest.getDefinition<DestinyMilestoneDefinition>(milestone.milestoneHash);
    if (mounted) {
      setState(() {});
      fullyLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (definition == null || milestone == null) {
      return Container(height: 200, color: LittleLightTheme.of(context).surfaceLayers.layer1);
    }

    return Container(
      decoration: BoxDecoration(
          color: LittleLightTheme.of(context).surfaceLayers.layer1,
          border: Border.all(width: 1, color: LittleLightTheme.of(context).surfaceLayers.layer3)),
      margin: EdgeInsets.all(8).copyWith(
        top: 0,
      ),
      child: Stack(children: [
        definition.image != null
            ? Positioned.fill(
                child: QueuedNetworkImage(fit: BoxFit.cover, imageUrl: BungieApiService.url(definition.image)),
              )
            : Container(),
        Positioned.fill(
          child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(1), Colors.black.withOpacity(.5)]))),
        ),
        buildContent(context)
      ]),
    );
  }

  buildContent(BuildContext context) {
    return Column(children: [
      buildHeader(context),
      buildMilestoneActivities(context),
      buildRewards(context),
      buildActivitiesObjectives(context),
      buildAvailableQuests(context)
    ]);
  }

  buildHeader(BuildContext context) {
    return Stack(children: <Widget>[
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          definition.displayProperties.hasIcon
              ? Container(
                  padding: EdgeInsets.all(8),
                  width: 64,
                  height: 64,
                  child: QueuedNetworkImage(
                      fit: BoxFit.cover, imageUrl: BungieApiService.url(definition.displayProperties.icon)))
              : Container(),
          Expanded(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(8),
              child: Text(
                definition.displayProperties.name.toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              child: Text(
                definition.displayProperties.description,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
              ),
            )
          ])),
        ],
      )
    ]);
  }

  Widget buildMilestoneActivities(BuildContext context) {
    if ((milestone?.activities?.length ?? 0) == 0) {
      return Container();
    }
    List<DestinyMilestoneChallengeActivity> activities = milestone.activities;
    List<DestinyMilestoneChallengeActivity> activitiesWithModifiers =
        activities?.where((a) => a.modifierHashes != null)?.toList();
    if ((activitiesWithModifiers?.length ?? 0) > 0) {
      activities = activitiesWithModifiers;
    }
    List<DestinyMilestoneChallengeActivity> activitiesWithChallenges =
        activities?.where((a) => (a.challenges?.length ?? 0) > 0)?.toList();
    if (activitiesWithChallenges.length > 0) {
      activities = activitiesWithChallenges;
    }
    return Container(
        padding: EdgeInsets.all(4).copyWith(bottom: 8),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: activities.map((a) => buildActivity(context, a)).toList()));
  }

  Widget buildActivity(BuildContext context, DestinyMilestoneChallengeActivity activity) {
    return DefinitionProviderWidget<DestinyActivityDefinition>(
        activity.activityHash,
        (def) => Column(children: [
              Stack(children: [
                Container(
                    margin: EdgeInsets.all(4),
                    padding: EdgeInsets.all(8),
                    color: Theme.of(context).colorScheme.secondary,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Row(children: [
                        Container(
                            width: 32,
                            height: 32,
                            child: QueuedNetworkImage(
                                imageUrl: (def?.displayProperties?.hasIcon ?? false)
                                    ? BungieApiService.url(def?.displayProperties?.icon)
                                    : BungieApiService.url(definition?.displayProperties?.icon))),
                        Container(width: 4),
                        Text(
                            def?.originalDisplayProperties?.name ??
                                def?.selectionScreenDisplayProperties?.name ??
                                def.displayProperties.name,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(child: Container()),
                        (def?.activityLightLevel ?? 0) > 0
                            ? Row(children: [
                                Icon(
                                  LittleLightIcons.power,
                                  size: 12,
                                  color: Colors.amber.shade500,
                                ),
                                Text("${def?.activityLightLevel}",
                                    style: TextStyle(color: Colors.amber.shade500, fontWeight: FontWeight.bold))
                              ])
                            : Container(),
                      ]),
                      Text(
                          def?.originalDisplayProperties?.description ??
                              def?.selectionScreenDisplayProperties?.description ??
                              def.displayProperties.description,
                          style: TextStyle(fontWeight: FontWeight.w500)),
                    ])),
                Positioned.fill(
                    child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    child: Container(),
                    onTap: () {
                      activitiesOpened[activity.activityHash] = !(activitiesOpened[activity.activityHash] ?? false);
                      setState(() {});
                    },
                  ),
                ))
              ]),
              (activitiesOpened[activity.activityHash] ?? false)
                  ? buildActivitiesModifiers(context, activity.activityHash)
                  : Container()
            ]));
  }

  Widget buildActivitiesObjectives(BuildContext context) {
    Map<int, DestinyObjectiveProgress> objectives = {};
    milestone.activities?.forEach((a) {
      a.challenges?.forEach((c) {
        objectives[c.objective?.objectiveHash] = c.objective;
      });
    });
    if (objectives.values.length == 0) return Container();
    return Container(
        padding: EdgeInsets.only(bottom: 4),
        child: Column(
          children: objectives.values
              .map((o) => Container(
                  margin: EdgeInsets.all(4),
                  child: GenericProgressBarWidget(
                    completed: o.complete,
                    progress: o.progress,
                    total: o.completionValue,
                    description: ManifestText<DestinyObjectiveDefinition>(o.objectiveHash),
                  )))
              .toList(),
        ));
  }

  Widget buildActivitiesModifiers(BuildContext context, [int activityHash]) {
    Set<int> modifierHashes = Set();
    milestone?.activities?.forEach((a) {
      if (activityHash == null || a.activityHash == activityHash) {
        modifierHashes.addAll(a.modifierHashes ?? []);
      }
    });
    if (modifierHashes.length == 0) return Container();
    return Container(
        padding: EdgeInsets.all(8).copyWith(top: 0),
        child: Column(
          children: <Widget>[
            HeaderWidget(
              alignment: Alignment.centerLeft,
              child: TranslatedTextWidget(
                "Modifiers",
                uppercase: true,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(height: 8)
          ]
              .followedBy(modifierHashes.map((m) => Container(
                  margin: EdgeInsets.all(4),
                  child: DefinitionProviderWidget<DestinyActivityModifierDefinition>(
                      m,
                      (def) => Row(
                            children: <Widget>[
                              Container(
                                width: 4,
                              ),
                              Container(
                                  width: 24,
                                  height: 24,
                                  child:
                                      QueuedNetworkImage(imageUrl: BungieApiService.url(def?.displayProperties?.icon))),
                              Container(
                                width: 8,
                              ),
                              Text(def.displayProperties.name)
                            ],
                          )))))
              .toList(),
        ));
  }

  Widget buildAvailableQuests(BuildContext context) {
    if ((milestone?.availableQuests?.length ?? 0) == 0) {
      return Container();
    }
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: milestone.availableQuests.map((q) => buildAvailableQuest(context, q)).toList());
  }

  Widget buildAvailableQuest(BuildContext context, DestinyMilestoneQuest quest) {
    return Container(
        padding: EdgeInsets.all(4).copyWith(bottom: 8),
        child: Column(
            children: quest.status.stepObjectives
                .map((o) => GenericProgressBarWidget(
                      description: ManifestText<DestinyInventoryItemDefinition>(quest.questItemHash),
                      progress: o.progress,
                      total: o.completionValue,
                      completed: o.complete,
                    ))
                .toList()));
  }

  Widget buildRewards(BuildContext context) {
    List<DestinyMilestoneRewardCategoryDefinition> rewards = definition?.rewards?.values?.toList();
    Map<int, int> itemQuantities = {};
    rewards?.forEach((r) {
      r.rewardEntries.values.forEach((e) {
        e.items.forEach((i) {
          itemQuantities[i.itemHash] = i.quantity;
        });
      });
    });
    if (itemQuantities.length == 0) {
      return Container();
    }

    return Container(
        padding: EdgeInsets.all(8).copyWith(top: 0),
        child: Column(
            children: <Widget>[
          HeaderWidget(
            alignment: Alignment.centerLeft,
            child: TranslatedTextWidget(
              "Rewards",
              uppercase: true,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(height: 8)
        ]
                .followedBy(itemQuantities.entries.map((e) => DefinitionProviderWidget<DestinyInventoryItemDefinition>(
                    e.key,
                    (def) => Row(children: <Widget>[
                          Container(
                            width: 4,
                          ),
                          Container(
                              width: 24,
                              height: 24,
                              child: QueuedNetworkImage(
                                imageUrl: BungieApiService.url(def.displayProperties?.icon),
                              )),
                          Container(
                            width: 4,
                          ),
                          Text(
                            def?.displayProperties?.name ?? "",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          )
                        ]))))
                .toList()));
  }

  @override
  bool get wantKeepAlive => fullyLoaded ?? false;
}
