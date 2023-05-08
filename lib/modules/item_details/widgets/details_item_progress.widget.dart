import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';
import 'package:little_light/shared/widgets/objectives/objective.widget.dart';
import 'package:little_light/shared/widgets/objectives/track_objectives.button.dart';

class DetailsItemProgressWidget extends StatelessWidget {
  final DestinyItemInfo itemInfo;

  const DetailsItemProgressWidget(
    this.itemInfo, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(4),
        child: PersistentCollapsibleContainer(
          title: Text("Objectives".translate(context).toUpperCase()),
          persistenceID: 'item objectives',
          content: buildContent(context),
        ));
  }

  Widget buildContent(
    BuildContext context,
  ) {
    final definition = context.definition<DestinyInventoryItemDefinition>(itemInfo.itemHash);
    final objectiveHashes = definition?.objectives?.objectiveHashes;
    if (objectiveHashes == null || objectiveHashes.isEmpty) return Container();
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...objectiveHashes.map(
              (oh) => buildObjective(context, oh),
            ),
            buildTrackButton(context),
          ].whereType<Widget>().toList()),
    );
  }

  Widget? buildObjective(
    BuildContext context,
    int? objectiveHash, {
    bool forceCompletion = false,
    String? placeholder,
  }) {
    if (objectiveHash == null) return null;
    final objectives = itemInfo.objectives?.objectives;
    final objective = objectives?.firstWhere((element) => element.objectiveHash == objectiveHash);
    return Container(
        padding: EdgeInsets.all(4).copyWith(top: 0),
        child: ObjectiveWidget(
          objectiveHash,
          objective: objective,
          forceComplete: forceCompletion,
          placeholder: placeholder,
        ));
  }

  Widget? buildTrackButton(BuildContext context) {
    final itemHash = this.itemInfo.itemHash;
    final itemInstanceId = this.itemInfo.instanceId;
    final characterId = itemInstanceId == null ? this.itemInfo.characterId : null;
    if (itemHash == null || (characterId == null && itemInstanceId == null)) return null;

    return Container(
      margin: EdgeInsets.only(top: 8),
      child: TrackObjectivesButton(
        TrackedObjectiveType.Item,
        trackedHash: itemHash,
        instanceId: itemInstanceId,
        characterId: characterId,
      ),
    );
  }
}
