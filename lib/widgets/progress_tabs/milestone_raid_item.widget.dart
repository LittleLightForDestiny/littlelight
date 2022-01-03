import 'package:bungie_api/models/destiny_activity_definition.dart';
import 'package:bungie_api/models/destiny_milestone.dart';
import 'package:bungie_api/models/destiny_milestone_activity_phase.dart';
import 'package:bungie_api/models/destiny_milestone_challenge_activity.dart';

import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/icon_fonts/littlelight_icons.dart';
import 'package:little_light/widgets/progress_tabs/milestone_item.widget.dart';

class MilestoneRaidItemWidget extends MilestoneItemWidget {
  final String characterId;

  final ManifestService manifest = ManifestService();
  final NotificationService broadcaster = NotificationService();

  final DestinyMilestone milestone;

  MilestoneRaidItemWidget({Key key, this.characterId, this.milestone})
      : super(key: key);

  _MilestoneRaidItemWidgetState createState() =>
      _MilestoneRaidItemWidgetState();
}

class _MilestoneRaidItemWidgetState
    extends MilestoneItemWidgetState<MilestoneRaidItemWidget> {
  buildMilestoneActivities(BuildContext context) {
    var activities = milestone?.activities
        ?.where((a) => a.phases != null && a.phases.length > 0);
    if ((activities?.length ?? 0) == 0) {
      return Container();
    }
    if (activities.length == 1) {
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
            child: HeaderWidget(
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
      children:
          activity?.phases?.map((p) => buildPhase(context, p))?.toList() ?? [],
    );
  }

  Widget buildPhase(BuildContext context, DestinyMilestoneActivityPhase phase) {
    return Flexible(
        child: Container(
            height: 60,
            alignment: Alignment.center,
            padding: EdgeInsets.all(4),
            margin: EdgeInsets.all(2),
            color: LittleLightTheme.of(context).surfaceLayers.layer2,
            child: buildPhaseLabel(context, phase)));
  }

  Widget buildPhaseLabel(
      BuildContext context, DestinyMilestoneActivityPhase phase) {
    String text;
    IconData icon;
    switch (phase.phaseHash) {
      case RaidPhases.leviathanGardens:
        icon = LittleLightIcons.leviathan_dogs;
        break;
      case RaidPhases.leviathanArena:
        icon = LittleLightIcons.leviathan_axes;
        break;
      case RaidPhases.leviathanPools:
        icon = LittleLightIcons.leviathan_sun;
        break;
      case RaidPhases.leviathanCallus:
        icon = LittleLightIcons.leviathan_cup;
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

      case RaidPhases.cosRitual:
        text = "Hive Ritual";
        break;
      case RaidPhases.cosInfiltration:
        text = "Infiltration";
        break;
      case RaidPhases.cosDeception:
        text = "Deception";
        break;
      case RaidPhases.cosGahlran:
        text = "Gahlran";
        break;

      case RaidPhases.gosEvasion:
        text = "Evasion";
        break;
      case RaidPhases.gosSummon:
        text = "Summon";
        break;
      case RaidPhases.gosConsecratedMind:
        text = "Consecrated Mind";
        break;
      case RaidPhases.gosSanctifieddMind:
        text = "Sanctified Mind";
        break;
    }
    final theme = LittleLightTheme.of(context);
    Color color =
        phase.complete ? theme.achievementLayers.layer1 : theme.onSurfaceLayers.layer2.withOpacity(.7);
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
}
