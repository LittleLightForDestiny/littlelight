import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/objective_tracking/objective_tracking.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';
import 'package:provider/provider.dart';
import 'package:tinycolor2/tinycolor2.dart';

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
    final trackingState = context.watch<ObjectiveTracking>();
    final isTracking = trackingState.isTracked(TrackedObjectiveType.Triumph, recordHash);
    final buttonColor = context.theme.successLayers.layer0;
    return Container(
      margin: EdgeInsets.all(8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor.mix(context.theme.surfaceLayers, isTracking ? 40 : 10),
        ),
        child: Text(
          isTracking ? "Stop tracking".translate(context) : "Track objectives".translate(context),
        ),
        onPressed: () => context
            .read<ObjectiveTracking>()
            .changeTrackingStatus(TrackedObjectiveType.Triumph, recordHash, track: !isTracking),
      ),
    );
  }
}
