import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/objective_tracking/objective_tracking.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'package:provider/provider.dart';
import 'package:tinycolor2/tinycolor2.dart';

class TrackObjectivesButton extends StatelessWidget {
  final TrackedObjectiveType type;
  final int? trackedHash;
  final String? characterId;
  final String? instanceId;

  const TrackObjectivesButton(
    this.type, {
    Key? key,
    this.trackedHash,
    this.characterId,
    this.instanceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final trackingState = context.watch<ObjectiveTracking>();
    final isTracking = trackingState.isTracked(
      this.type,
      this.trackedHash,
      characterId: this.characterId,
      instanceId: this.instanceId,
    );
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
        onPressed: () => context.read<ObjectiveTracking>().changeTrackingStatus(
              this.type,
              trackedHash,
              track: !isTracking,
              instanceId: this.instanceId,
              characterId: this.characterId,
            ),
      ),
    );
  }
}
