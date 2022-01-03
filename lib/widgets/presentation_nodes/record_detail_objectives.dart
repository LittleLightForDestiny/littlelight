import 'dart:async';

import 'package:bungie_api/enums/destiny_record_state.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:bungie_api/models/destiny_record_component.dart';
import 'package:bungie_api/models/destiny_record_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/services/profile/profile_component_groups.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/objective.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';


class RecordObjectivesWidget extends StatefulWidget {
  final ManifestService manifest = new ManifestService();

  final NotificationService broadcaster = new NotificationService();
  final DestinyRecordDefinition definition;

  RecordObjectivesWidget({Key key, this.definition}) : super(key: key);

  @override
  RecordObjectivesWidgetState createState() {
    return RecordObjectivesWidgetState();
  }
}

class RecordObjectivesWidgetState extends State<RecordObjectivesWidget> with AuthConsumer, ProfileConsumer {
  bool isLogged = false;
  Map<int, DestinyObjectiveDefinition> objectiveDefinitions;
  StreamSubscription<NotificationEvent> subscription;

  DestinyRecordDefinition get definition {
    return widget.definition;
  }


  @override
  void initState() {
    super.initState();
    isLogged = auth.isLogged;
    loadDefinitions();
    if(isLogged){
      listenToUpdates();
    }
  }

  @override
  void dispose(){
    if(subscription != null) subscription.cancel();
    super.dispose();
  }

  listenToUpdates(){
    subscription = widget.broadcaster.listen((event) {
      if(!mounted) return;
      if (event.type == NotificationType.receivedUpdate) {
        setState(() {});
      }
    });
  }

  loadDefinitions() async {
    var manifest = ManifestService();
    if (definition?.objectiveHashes != null) {
      objectiveDefinitions =
          await manifest.getDefinitions<DestinyObjectiveDefinition>(
              definition.objectiveHashes);
      if (mounted) setState(() {});
    }
  }

  

  DestinyRecordComponent get record {
    if (!auth.isLogged) return null;
    return profile.getRecord(definition.hash, definition.scope);
  }

  DestinyRecordState get recordState {
    return record?.state ?? DestinyRecordState.ObjectiveNotCompleted;
  }

  bool get completed {
    return !recordState.contains(DestinyRecordState.ObjectiveNotCompleted);
  }

  Color get foregroundColor {
    return Colors.grey.shade300;
  }

  build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8),
        child: Column(children: [
          HeaderWidget(
              padding: EdgeInsets.all(0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                Container(
                    padding: EdgeInsets.all(8),
                    child: TranslatedTextWidget(
                      "Objectives",
                      uppercase: true,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                buildRefreshButton(context)
              ])),
          buildObjectives(context)
        ]));
  }

  buildRefreshButton(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: Stack(
          children: <Widget>[
            InkWell(
                child: Container(
                    padding: EdgeInsets.all(8), child: Icon(Icons.refresh)),
                onTap: () {
                  profile.fetchProfileData(
                      components: ProfileComponentGroups.triumphs);
                })
          ],
        ));
  }

  buildObjectives(BuildContext context) {
    if (definition?.objectiveHashes == null) return Container();
    return Container(
        padding: EdgeInsets.all(8),
        child: Column(
            children: definition.objectiveHashes
                .map((hash){
                  var objective = getRecordObjective(hash);
                  return ObjectiveWidget(
                    definition: objectiveDefinitions != null
                        ? objectiveDefinitions[hash]
                        : null,
                    key:Key("objective_${hash}_${objective?.progress}"),
                    objective: objective,
                    placeholder: definition?.displayProperties?.name ?? "",
                    color: foregroundColor);})
                .toList()));
  }

  DestinyObjectiveProgress getRecordObjective(hash) {
    if (record == null) return null;
    return record.objectives
        .firstWhere((o) => o.objectiveHash == hash, orElse: () => null);
  }
}
