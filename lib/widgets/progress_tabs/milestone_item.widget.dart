import 'dart:async';
import 'package:bungie_api/models/destiny_activity_definition.dart';
import 'package:bungie_api/models/destiny_challenge_status.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_milestone.dart';
import 'package:bungie_api/models/destiny_milestone_activity_phase.dart';
import 'package:bungie_api/models/destiny_milestone_challenge_activity.dart';
import 'package:bungie_api/models/destiny_milestone_definition.dart';
import 'package:bungie_api/models/destiny_milestone_quest.dart';
import 'package:bungie_api/models/destiny_milestone_reward_category.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/common/generic_progress_bar.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class MilestoneItemWidget extends StatefulWidget {
  final String characterId;
  final ProfileService profile = ProfileService();
  final ManifestService manifest = ManifestService();
  final NotificationService broadcaster = NotificationService();

  final DestinyMilestone milestone;

  MilestoneItemWidget({Key key, this.characterId, this.milestone})
      : super(key: key);

  _MilestoneItemWidgetState createState() => _MilestoneItemWidgetState();
}

class _MilestoneItemWidgetState extends State<MilestoneItemWidget>
    with AutomaticKeepAliveClientMixin {
  DestinyMilestoneDefinition definition;
  StreamSubscription<NotificationEvent> subscription;
  DestinyMilestone milestone;
  int get hash => widget.milestone.milestoneHash;
  bool fullyLoaded = false;

  @override
  void initState() {
    milestone = widget.milestone;
    super.initState();
    loadDefinitions();
    subscription = widget.broadcaster.listen((event) {
      if (event.type == NotificationType.receivedUpdate && mounted) {
        milestone = widget.profile.getCharacterProgression(widget.characterId).milestones["$hash"];
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
    definition = await widget.manifest
        .getDefinition<DestinyMilestoneDefinition>(
            milestone.milestoneHash);
    if (mounted) {
      setState(() {});
      fullyLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (definition == null) {
      return Container(height: 200, color: Colors.blueGrey.shade900);
    }

    List<Widget> items = [buildHeader(context)];

    if (milestone.activities != null) {
      items.add(buildMilestoneActivities(context, milestone.activities));
    }

    // if (widget.milestone.rewards != null) {
    //   items.add(buildRewards(context, widget.milestone.rewards));
    // }
    if (milestone.availableQuests != null) {
      items
          .add(buildAvailableQuests(context, milestone.availableQuests));
    }
    return Container(
        decoration: BoxDecoration(
            color: Colors.blueGrey.shade900,
            border: Border.all(width: 1, color: Colors.blueGrey.shade200)),
        margin: EdgeInsets.all(8).copyWith(top: 0),
        child: Column(children: items));
  }

  buildHeader(BuildContext context) {
    return Stack(children: <Widget>[
      definition.image != null
          ? Positioned.fill(
              child: QueuedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: BungieApiService.url(definition.image)),
            )
          : Container(),
      Positioned.fill(
        child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
              Colors.black.withOpacity(1),
              Colors.black.withOpacity(.3)
            ]))),
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              padding: EdgeInsets.all(8),
              width: 64,
              height: 64,
              child: QueuedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl:
                      BungieApiService.url(definition.displayProperties.icon))),
          Expanded(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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

  Widget buildMilestoneActivities(BuildContext context,
      List<DestinyMilestoneChallengeActivity> activities) {
    List<Widget> widgets = [];
    activities.forEach((activity) {
      if ((activity.challenges?.length ?? 0) > 0) {
        widgets.add(Container(
            padding: EdgeInsets.all(4),
            child: HeaderWidget(
                alignment: Alignment.centerLeft,
                child: ManifestText<DestinyActivityDefinition>(
                  activity.activityHash,
                  textExtractor: (def) {
                    return def?.selectionScreenDisplayProperties?.name ??
                        def.displayProperties.name;
                  },
                  uppercase: true,
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.fade,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ))));
        widgets.add(buildActivityChallenges(context, activity.challenges));
      }
    });
    return Container(
        padding: EdgeInsets.all(4).copyWith(bottom: 8),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, children: widgets));
  }

  Widget buildActivityPhases(
      BuildContext context, List<DestinyMilestoneActivityPhase> phases) {
    List<Widget> widgets = [];
    phases.forEach((phase) {
      widgets.add(Container(
          padding: EdgeInsets.all(4),
          child: Column(children: [
            Text("${phase.phaseHash}"),
            Text("${phase.complete}")
          ])));
    });
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: widgets));
  }

  Widget buildActivityChallenges(
      BuildContext context, List<DestinyChallengeStatus> challenges) {
    List<Widget> widgets = [];
    challenges.forEach((challenge) {
      widgets.add(GenericProgressBarWidget(
        completed: challenge.objective.complete,
        progress: challenge.objective.progress,
        total: challenge.objective.completionValue,
        description: ManifestText<DestinyObjectiveDefinition>(
            challenge.objective.objectiveHash),
      ));
    });
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround, children: widgets);
  }

  Widget buildAvailableQuests(
      BuildContext context, List<DestinyMilestoneQuest> availableQuests) {
    List<Widget> widgets = [];
    availableQuests.forEach((quest) {
      widgets.add(Container(
          padding: EdgeInsets.all(4),
          child: GenericProgressBarWidget(
            description: ManifestText<DestinyInventoryItemDefinition>(
                quest.questItemHash),
            completed: quest.status.completed,
            total: 1,
          )));
    });
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround, children: widgets);
  }

  Widget buildRewards(
      BuildContext context, List<DestinyMilestoneRewardCategory> rewards) {
    List<Widget> widgets = [];
    widgets.add(TranslatedTextWidget("Rewards",
        uppercase: true,
        style: TextStyle(
            color: Colors.green.shade300,
            fontWeight: FontWeight.bold,
            fontSize: 12)));
    rewards.forEach((reward) {
      reward.entries.forEach((entry) {
        widgets.add(
            Row(children: [Text("${entry.rewardEntryHash}:${entry.earned}")]));
      });
    });
    return Container(
        padding: EdgeInsets.all(8),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: widgets));
  }

  @override
  bool get wantKeepAlive => fullyLoaded ?? false;
}
