import 'package:bungie_api/models/destiny_lore_definition.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:bungie_api/models/destiny_record_component.dart';
import 'package:bungie_api/models/destiny_record_definition.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/models/tracked_objective.dart';
import 'package:little_light/services/littlelight/littlelight.service.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:little_light/screens/record_detail.screen.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/common/objective.widget.dart';
import 'package:bungie_api/enums/destiny_record_state_enum.dart';

class RecordItemWidget extends StatefulWidget {
  final ManifestService manifest = new ManifestService();
  final int hash;
  RecordItemWidget({Key key, this.hash}) : super(key: key);

  @override
  RecordItemWidgetState createState() {
    return RecordItemWidgetState();
  }
}

class RecordItemWidgetState extends State<RecordItemWidget> {
  DestinyRecordDefinition _definition;
  bool isLogged = false;
  Map<int, DestinyObjectiveDefinition> objectiveDefinitions;
  DestinyLoreDefinition loreDefinition;
  bool isTracking = false;

  DestinyRecordDefinition get definition {
    return widget.manifest
            .getDefinitionFromCache<DestinyRecordDefinition>(widget.hash) ??
        _definition;
  }

  @override
  void initState() {
    super.initState();
    loadDefinitions();
    if (isLogged) {
      updateTrackStatus();
    }
  }

  updateTrackStatus() async {
    var objectives = await LittleLightService().getTrackedObjectives();
    var tracked = objectives.firstWhere(
        (o) => o.hash == widget.hash && o.type == TrackedObjectiveType.Triumph,
        orElse: () => null);
    isTracking = tracked != null;
    if (!mounted) return;
    setState(() {});
  }

  loadDefinitions() async {
    isLogged = AuthService().isLogged;
    var manifest = ManifestService();
    if (this.definition == null) {
      _definition =
          await manifest.getDefinition<DestinyRecordDefinition>(widget.hash);
      if (!mounted) return;
      setState(() {});
    }
    if (definition?.objectiveHashes != null) {
      objectiveDefinitions =
          await manifest.getDefinitions<DestinyObjectiveDefinition>(
              definition.objectiveHashes);
      if (mounted) setState(() {});
    }

    if (definition?.loreHash != null) {
      loreDefinition = await manifest
          .getDefinition<DestinyLoreDefinition>(definition.loreHash);
      if (mounted) setState(() {});
    }
  }

  DestinyRecordComponent get record {
    if (definition == null) return null;
    if (!AuthService().isLogged) return null;
    return ProfileService().getRecord(definition.hash, definition.scope);
  }

  int get recordState {
    return record?.state ?? DestinyRecordState.ObjectiveNotCompleted;
  }

  bool get completed {
    return (recordState & DestinyRecordState.ObjectiveNotCompleted) !=
        DestinyRecordState.ObjectiveNotCompleted;
  }

  Color get foregroundColor {
    if (!isLogged) {
      return Colors.grey.shade300;
    }
    return completed ? Colors.amber.shade100 : Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: foregroundColor, width: 1),
        ),
        child: Stack(children: [
          Column(children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                buildIcon(context),
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(8).copyWith(left: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            buildTitle(context),
                            Container(
                              height: 1,
                              color: foregroundColor,
                              margin: EdgeInsets.all(4),
                            ),
                            buildDescription(context),
                            buildLore(context)
                          ],
                        )))
              ],
            ),
            buildObjectives(context)
          ]),
          Positioned.fill(
              child: FlatButton(
            child: Container(),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecordDetailScreen(definition),
                ),
              );
            },
          ))
        ]));
  }

  Widget buildIcon(BuildContext context) {
    return Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        margin: EdgeInsets.all(8),
        child: definition == null
            ? Container()
            : QueuedNetworkImage(
                imageUrl:
                    BungieApiService.url(definition?.displayProperties?.icon)
              ));
  }

  buildTitle(BuildContext context) {
    if (definition == null) return Container();
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
          child: Container(
              padding: EdgeInsets.all(4),
              child: Text(
                definition.displayProperties.name,
                softWrap: true,
                style: TextStyle(
                    color: foregroundColor, fontWeight: FontWeight.bold),
              ))),
      buildTrackingIcon(context),
      Container(
          padding: EdgeInsets.only(left: 4, right: 4),
          child: Text(
            "${definition?.completionInfo?.scoreValue ?? ""}",
            style: TextStyle(
                fontWeight: FontWeight.w300,
                color: foregroundColor,
                fontSize: 14),
          )),
    ]);
  }

  Widget buildTrackingIcon(BuildContext context) {
    if (!isTracking) return Container();
    return Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
            color: Colors.green.shade800,
            borderRadius: BorderRadius.circular(20)),
        child: Icon(
          FontAwesomeIcons.crosshairs,
          size: 12,
          color: Colors.lightGreenAccent.shade100,
        ));
  }

  buildDescription(BuildContext context) {
    if (definition == null) return Container();
    if ((definition?.displayProperties?.description?.length ?? 0) == 0)
      return Container();

    return Container(
        padding: EdgeInsets.all(4),
        child: Text(
          definition.displayProperties.description,
          softWrap: true,
          style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w300,
              fontSize: 13),
        ));
  }

  buildLore(BuildContext context) {
    if (loreDefinition == null) return Container();
    return Container(
        padding: EdgeInsets.all(4),
        child: Text(
          loreDefinition.displayProperties.description,
          softWrap: true,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w300,
              fontSize: 13),
        ));
  }

  DestinyObjectiveProgress getRecordObjective(hash) {
    if (record == null) return null;
    return record.objectives
        .firstWhere((o) => o.objectiveHash == hash, orElse: () => null);
  }

  buildObjectives(BuildContext context) {
    if (definition?.objectiveHashes == null) return Container();
    return Container(
        padding: EdgeInsets.all(8),
        child: Column(
            children: definition.objectiveHashes
                .map((hash) => ObjectiveWidget(
                      definition: objectiveDefinitions != null
                          ? objectiveDefinitions[hash]
                          : null,
                      objective: getRecordObjective(hash),
                      placeholder: definition?.displayProperties?.name ?? "",
                      color: foregroundColor,
                      parentCompleted: completed,
                    ))
                .toList()));
  }
}
