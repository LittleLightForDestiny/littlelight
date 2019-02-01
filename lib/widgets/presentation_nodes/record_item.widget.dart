import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:bungie_api/models/destiny_record_component.dart';
import 'package:bungie_api/models/destiny_record_definition.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  DestinyRecordDefinition get definition {
    return widget.manifest
            .getDefinitionFromCache<DestinyRecordDefinition>(widget.hash) ??
        _definition;
  }

  Map<int, DestinyObjectiveDefinition> objectiveDefinitions;

  @override
  void initState() {
    super.initState();
    loadDefinitions();
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
    }
    if (!mounted) return;
    setState(() {});
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
    return completed ? Colors.amber.shade100 : Colors.grey.shade400;
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                            buildDescription(context)
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
        width: 84,
        height: 84,
        margin: EdgeInsets.all(8),
        child: definition == null
            ? Container()
            : CachedNetworkImage(
                imageUrl:
                    BungieApiService.url(definition.displayProperties.icon),
              ));
  }

  buildTitle(BuildContext context) {
    if (definition == null) return Container();
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          child: Container(
              padding: EdgeInsets.all(4),
              child: Text(
                definition.displayProperties.name,
                softWrap: true,
                style: TextStyle(
                    color: foregroundColor, fontWeight: FontWeight.bold),
              ))),
      Container(
          padding: EdgeInsets.only(right: 4, top: 4),
          child: Text(
            "${definition?.completionInfo?.scoreValue ?? ""}",
            style: TextStyle(
                fontWeight: FontWeight.w300,
                color: foregroundColor,
                fontSize: 13),
          )),
    ]);
  }

  buildDescription(BuildContext context) {
    if (definition == null) return Container();

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
                      color: foregroundColor,
                    ))
                .toList()));
  }
}
