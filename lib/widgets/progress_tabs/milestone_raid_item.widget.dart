import 'dart:async';
import 'package:bungie_api/models/destiny_activity_definition.dart';
import 'package:bungie_api/models/destiny_milestone.dart';
import 'package:bungie_api/models/destiny_milestone_activity_phase.dart';
import 'package:bungie_api/models/destiny_milestone_challenge_activity.dart';
import 'package:bungie_api/models/destiny_milestone_definition.dart';

import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/icon_fonts/destiny_icons_icons.dart';

class MilestoneRaidItemWidget extends StatefulWidget {
  final String characterId;
  final ProfileService profile = ProfileService();
  final ManifestService manifest = ManifestService();
  final NotificationService broadcaster = NotificationService();

  final DestinyMilestone milestone;

  MilestoneRaidItemWidget({Key key, this.characterId, this.milestone})
      : super(key: key);

  _MilestoneRaidItemWidgetState createState() =>
      _MilestoneRaidItemWidgetState();
}

class _MilestoneRaidItemWidgetState extends State<MilestoneRaidItemWidget>
    with AutomaticKeepAliveClientMixin {
  DestinyMilestoneDefinition definition;
  StreamSubscription<NotificationEvent> subscription;
  bool fullyLoaded = false;

  @override
  void initState() {
    super.initState();
    loadDefinitions();
    subscription = widget.broadcaster.listen((event) {
      if ((event.type == NotificationType.receivedUpdate ||
              event.type == NotificationType.localUpdate) &&
          mounted) {
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
            widget.milestone.milestoneHash);
    if (mounted) {
      setState(() {});
      fullyLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (definition == null) {
      return Container(height: 200, color: Colors.blueGrey.shade800);
    }

    return Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade900,
        ),
        
        margin: EdgeInsets.all(8).copyWith(top: 0),
        child: Column(children: <Widget>[
          buildHeader(context),
          buildActivities(context)
        ]));
  }

  buildHeader(BuildContext context) {
    return Stack(children: <Widget>[
      Positioned.fill(
        child: QueuedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: BungieApiService.url(definition.image)),
      ),
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
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
      ]),
    ]);
  }

  buildActivities(BuildContext context) {
    var activities = widget.milestone.activities
        .where((a) => a.phases != null && a.phases.length > 0);

    if(activities.length == 1){
      return Container(
        padding: EdgeInsets.all(2),
        child: Column(
            children:
                activities.map((a) => buildPhases(context, a)).toList()));
    }
    return Container(
        padding: EdgeInsets.all(2),
        child: Column(
            children:
                activities.map((a) => buildActivity(context, a)).toList()));
  }

  Widget buildActivity(
      BuildContext context, DestinyMilestoneChallengeActivity activity) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(2),
          child:HeaderWidget(
            child: ManifestText<DestinyActivityDefinition>(
                activity.activityHash,
                uppercase: true,
                textExtractor: (def) =>
                    def?.selectionScreenDisplayProperties?.name ??
                    def.displayProperties.name,
                style: TextStyle(fontWeight: FontWeight.bold)))),
        buildPhases(context, activity)
      ],
    );
  }

  Widget buildPhases(
      BuildContext context, DestinyMilestoneChallengeActivity activity) {
    return Row(
      children: activity.phases.map((p) => buildPhase(context, p)).toList(),
    );
  }

  Widget buildPhase(BuildContext context, DestinyMilestoneActivityPhase phase) {
    return Flexible(
            child: Container(
                height: 60,
                alignment: Alignment.center,
                padding: EdgeInsets.all(4),
                margin: EdgeInsets.all(2),
                color:Colors.blueGrey.shade700,
                child: buildPhaseLabel(context, phase)));
  }

  Widget buildPhaseLabel(
      BuildContext context, DestinyMilestoneActivityPhase phase) {
    String text;
    IconData icon;
    switch (phase.phaseHash) {
      case RaidPhases.leviathanGardens:
        icon = DestinyIcons.leviathan_dogs;
        break;
      case RaidPhases.leviathanArena:
        icon = DestinyIcons.leviathan_axes;
        break;
      case RaidPhases.leviathanPools:
        icon = DestinyIcons.leviathan_sun;
        break;
      case RaidPhases.leviathanCallus:
        icon = DestinyIcons.leviathan_cup;
        break;

      case RaidPhases.eowLoyalists:
        text = "Loyalists";
        break;
      case RaidPhases.eowRings:
        text = "Vex Rings";
        break;
      case RaidPhases.eowShields:
        text = "Shields";
        break;
      case RaidPhases.eowArgos:
        text = "Argos";
        break;

      case RaidPhases.sosStatueGarden:
        text = "Statue Garden";
        break;
      case RaidPhases.sosConduitRoom:
        text = "Conduit Room";
        break;
      case RaidPhases.sosShips:
        text = "Ships";
        break;
      case RaidPhases.sosValCauor:
        text = "Val Ca'uor";
        break;

      case RaidPhases.lwKalli:
        text = "Kalli";
        break;
      case RaidPhases.lwShuroChi:
        text = "Shuro Chi";
        break;
      case RaidPhases.lwMorgeth:
        text = "Morgeth";
        break;
      case RaidPhases.lwVault:
        text = "Vault Room";
        break;
      case RaidPhases.lwRiven:
        text = "Riven";
        break;

      case RaidPhases.sotpBotzaDistrict:
        text = "Botza District";
        break;
      case RaidPhases.sotpVaultAccess:
        text = "Vault Access";
        break;
      case RaidPhases.sotpInsurectionPrime:
        text = "Insurrection Prime";
        break;
    }
    Color color = phase.complete
        ? Colors.amber.shade100
        : Colors.blueGrey.shade200;
    if (icon != null) {
      return Icon(icon, color: color, size: 30);
    }
    if (text != null) {
      return TranslatedTextWidget(
        text,
        uppercase: true,
        textAlign: TextAlign.center,
        style:
            TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
      );
    }
    return Icon(phase.complete ? Icons.check_circle : Icons.remove_circle,
        color: color);
  }

  @override
  bool get wantKeepAlive => fullyLoaded ?? false;
}
