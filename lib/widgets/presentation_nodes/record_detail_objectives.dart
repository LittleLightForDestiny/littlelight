import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:bungie_api/models/destiny_record_component.dart';
import 'package:bungie_api/models/destiny_record_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/objective.widget.dart';
import 'package:bungie_api/enums/destiny_record_state_enum.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class RecordObjectivesWidget extends StatefulWidget {
  final ManifestService manifest = new ManifestService();
  final DestinyRecordDefinition definition;

  RecordObjectivesWidget({Key key, this.definition}) : super(key: key);

  @override
  RecordObjectivesWidgetState createState() {
    return RecordObjectivesWidgetState();
  }
}

class RecordObjectivesWidgetState extends State<RecordObjectivesWidget> {
  bool isLogged = false;
  Map<int, DestinyObjectiveDefinition> objectiveDefinitions;

  DestinyRecordDefinition get definition {
    return widget.definition;
  }

  @override
  void initState() {
    super.initState();
    loadDefinitions();
  }

  loadDefinitions() async {
    isLogged = AuthService().isLogged;
    var manifest = ManifestService();
    if (definition?.objectiveHashes != null) {
      objectiveDefinitions =
          await manifest.getDefinitions<DestinyObjectiveDefinition>(
              definition.objectiveHashes);
      if (mounted) setState(() {});
    }
  }

  DestinyRecordComponent get record {
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
    return Colors.grey.shade300;
  }

  build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8),
        child: Column(children: [
          HeaderWidget(
              child: Container(
                  alignment: Alignment.centerLeft,
                  child: TranslatedTextWidget(
                    "Objectives",
                    uppercase: true,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ))),
          buildObjectives(context)
        ]));
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
                    color: foregroundColor))
                .toList()));
  }

  DestinyObjectiveProgress getRecordObjective(hash) {
    if (record == null) return null;
    return record.objectives
        .firstWhere((o) => o.objectiveHash == hash, orElse: () => null);
  }
}
