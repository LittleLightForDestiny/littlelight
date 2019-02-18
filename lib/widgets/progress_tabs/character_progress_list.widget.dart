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
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/progress_tabs/milestone_item.widget.dart';
import 'package:little_light/widgets/progress_tabs/milestone_raid_item.widget.dart';

class CharacterProgressListWidget extends StatefulWidget {
  final String characterId;
  final ProfileService profile = ProfileService();
  final ManifestService manifest = ManifestService();

  CharacterProgressListWidget({Key key, this.characterId}) : super(key: key);

  _CharacterProgressListWidgetState createState() =>
      _CharacterProgressListWidgetState();
}

class _CharacterProgressListWidgetState
    extends State<CharacterProgressListWidget> {
  final List<int> raidHashes = [
    3660836525,
    2986584050,
    2683538554,
    3181387331,
    1342567285,
  ];
  Map<String, DestinyMilestone> milestones;
  Map<int, DestinyMilestoneDefinition> milestoneDefinitions;

  @override
  void initState() {
    super.initState();
    getMilestones();
  }

  Future<void> getMilestones() async {
    milestones =
        widget.profile.getCharacterProgression(widget.characterId).milestones;
    var hashes = milestones.values.map((m)=>m.milestoneHash);
    milestoneDefinitions = await widget.manifest.getDefinitions<DestinyMilestoneDefinition>(hashes);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: buildRaids(context),
      ),
    );
  }

  List<Widget> buildRaids(BuildContext context) {
    List<Widget> widgets = [];
    raidHashes.forEach((hash){
      widgets.add(buildRaidMilestone(context, milestones.values.firstWhere((m)=>m.milestoneHash == hash)));
    });
    return widgets;
  }

  Widget buildRaidMilestone(BuildContext context, DestinyMilestone milestone) {    
    return MilestoneRaidItemWidget(characterId:widget.characterId, milestone: milestone,);
  }

  Widget buildMilestoneActivities(BuildContext context,
      List<DestinyMilestoneChallengeActivity> activities) {
    List<Widget> widgets = [];
    activities.forEach((activity) {
      widgets.add(Container(
          padding: EdgeInsets.all(8),
          color: Colors.black,
          child:
              ManifestText<DestinyActivityDefinition>(activity.activityHash)));
      if (activity.phases != null) {
        widgets
            .add(Container(padding: EdgeInsets.all(8), child: Text('Phases')));
        widgets.add(buildActivityPhases(context, activity.phases));
      }
      if ((activity.challenges?.length ?? 0) > 0) {
        widgets.add(buildActivityChallenges(context, activity.challenges));
      }
      widgets.add(Container(height: 8));
    });
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: widgets);
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
    widgets.add(Text("Challenges"));
    challenges.forEach((challenge) {
      widgets.add(Row(children: [
        ManifestText<DestinyObjectiveDefinition>(
            challenge.objective.objectiveHash),
        Text(":${challenge.objective.progress}")
      ]));
    });
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround, children: widgets);
  }

  Widget buildAvailableQuests(
      BuildContext context, List<DestinyMilestoneQuest> availableQuests) {
    List<Widget> widgets = [];
    widgets.add(Text("Quests"));
    availableQuests.forEach((quest) {
      widgets.add(Row(children: [
        ManifestText<DestinyInventoryItemDefinition>(quest.questItemHash),
        Text(":${quest.status.completed}")
      ]));
    });
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround, children: widgets);
  }

  Widget buildRewards(
      BuildContext context, List<DestinyMilestoneRewardCategory> rewards) {
    List<Widget> widgets = [];
    widgets.add(Text("Rewards"));
    rewards.forEach((reward) {
      reward.entries.forEach((entry) {
        widgets.add(
            Row(children: [Text("${entry.rewardEntryHash}:${entry.earned}")]));
      });
    });
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround, children: widgets);
  }
}
