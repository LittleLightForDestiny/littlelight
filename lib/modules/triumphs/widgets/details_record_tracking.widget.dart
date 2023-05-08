import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';
import 'package:little_light/shared/widgets/objectives/track_objectives.button.dart';

class DetailsRecordObjectiveTrackingWidget extends StatelessWidget {
  final int recordHash;

  const DetailsRecordObjectiveTrackingWidget(
    this.recordHash, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(4),
        child: PersistentCollapsibleContainer(
          title: Text("Objective tracking".translate(context).toUpperCase()),
          persistenceID: 'record objective tracking',
          content: buildContent(context),
        ));
  }

  Widget buildContent(BuildContext context) {
    return TrackObjectivesButton(
      TrackedObjectiveType.Triumph,
      trackedHash: recordHash,
    );
  }
}
