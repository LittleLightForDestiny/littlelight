// @dart=2.9

import 'package:bungie_api/models/destiny_milestone.dart';
import 'package:bungie_api/models/destiny_milestone_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/widgets/item_list/character_info.widget.dart';
import 'package:little_light/widgets/progress_tabs/milestone_item.widget.dart';
import 'package:little_light/widgets/progress_tabs/milestone_raid_item.widget.dart';

class CharacterProgressListWidget extends StatefulWidget {
  final String characterId;

  CharacterProgressListWidget({Key key, this.characterId}) : super(key: key);

  _CharacterProgressListWidgetState createState() => _CharacterProgressListWidgetState();
}

class _CharacterProgressListWidgetState extends State<CharacterProgressListWidget>
    with ProfileConsumer, ManifestConsumer {
  List<int> raidHashes = [3660836525, 2986584050, 2683538554, 3181387331, 1342567285, 2590427074];
  Map<String, DestinyMilestone> milestones;
  Map<int, DestinyMilestoneDefinition> milestoneDefinitions;

  @override
  void initState() {
    super.initState();
    getMilestones();
  }

  Future<void> getMilestones() async {
    milestones = profile.getCharacterProgression(widget.characterId).milestones;
    var hashes = milestones.values.map((m) => m.milestoneHash);
    milestoneDefinitions = await manifest.getDefinitions<DestinyMilestoneDefinition>(hashes);
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var screenPadding = MediaQuery.of(context).padding;
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: screenPadding.left, right: screenPadding.right),
      child: Column(
        children: buildMilestones(context),
      ),
    );
  }

  List<Widget> buildMilestones(BuildContext context) {
    List<Widget> widgets = [];
    if (milestoneDefinitions == null) return widgets;
    widgets.add(Container(height: 112, child: CharacterInfoWidget(characterId: widget.characterId)));
    widgets.add(Container(
      height: 8,
    ));
    var raidMilestones = milestones.values.where((m) => raidHashes.contains(m.milestoneHash));
    var otherMilestones = milestones.values.where((m) {
      return !raidHashes.contains(m.milestoneHash) &&
          ((m.availableQuests?.length ?? 0) > 0 || (m.activities?.length ?? 0) > 0);
    });
    raidMilestones.forEach((milestone) {
      widgets.add(buildRaidMilestone(context, milestone));
    });

    otherMilestones.forEach((milestone) {
      widgets.add(buildMilestone(context, milestone));
    });
    return widgets;
  }

  Widget buildRaidMilestone(BuildContext context, DestinyMilestone milestone) {
    return MilestoneRaidItemWidget(
      characterId: widget.characterId,
      milestone: milestone,
    );
  }

  Widget buildMilestone(BuildContext context, DestinyMilestone milestone) {
    return MilestoneItemWidget(
      characterId: widget.characterId,
      milestone: milestone,
    );
  }
}
