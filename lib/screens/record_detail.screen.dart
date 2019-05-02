import 'package:bungie_api/enums/destiny_record_state_enum.dart';
import 'package:bungie_api/models/destiny_record_component.dart';
import 'package:bungie_api/models/destiny_record_definition.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/services/littlelight/littlelight.service.dart';
import 'package:little_light/services/littlelight/models/tracked_objective.model.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/item_details/item_lore.widget.dart';
import 'package:little_light/widgets/presentation_nodes/record_detail_objectives.dart';

class RecordDetailScreen extends StatefulWidget {
  final DestinyRecordDefinition definition;
  final ProfileService profile = ProfileService();

  RecordDetailScreen(this.definition, {Key key}) : super(key: key);

  @override
  State<RecordDetailScreen> createState() {
    return RecordDetailScreenState();
  }
}

class RecordDetailScreenState extends State<RecordDetailScreen> {
  bool get isLogged => AuthService().isLogged;
  bool isTracking = false;

  DestinyRecordDefinition get definition => widget.definition;

  Color get foregroundColor {
    return Colors.grey.shade300;
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

  @override
  void initState() {
    super.initState();
    if (isLogged) {
      updateTrackStatus();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  updateTrackStatus() async {
    var objectives = await LittleLightService().getTrackedObjectives();
    var tracked = objectives.firstWhere(
        (o) =>
            o.hash == widget.definition.hash &&
            o.type == TrackedObjectiveType.Triumph,
        orElse: () => null);
    isTracking = tracked != null;
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.definition.displayProperties.name),
        ),
        body: Stack(children: [
          CustomScrollView(slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                buildMainInfo(context),
                RecordObjectivesWidget(
                  definition: definition,
                ),
                buildTrackButton(context),
                ItemLoreWidget(widget.definition.loreHash),
                Container(height: 100)
              ]),
            ),
          ]),
          InventoryNotificationWidget(
            barHeight: 0,
          )
        ]));
  }

  Widget buildMainInfo(BuildContext context) {
    return Row(
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
                    buildDescription(context),
                  ],
                )))
      ],
    );
  }

  Widget buildIcon(BuildContext context) {
    return Container(
        width: 84,
        height: 84,
        margin: EdgeInsets.all(8),
        child: definition == null
            ? Container()
            : QueuedNetworkImage(
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
      buildTrackingIcon(context),
      Container(
          padding: EdgeInsets.all(4),
          child: Text(
            "${definition?.completionInfo?.scoreValue ?? ""}",
            style: TextStyle(
                fontWeight: FontWeight.w300,
                color: foregroundColor,
                fontSize: 13),
          )),
    ]);
  }

  Widget buildTrackingIcon(BuildContext context) {
    if (!isTracking) return Container();
    return Container(
        margin: EdgeInsets.only(top:4),
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

  Widget buildTrackButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: RaisedButton(
        color: isTracking ? Colors.green.shade600 : Colors.green.shade800,
        child: isTracking
            ? TranslatedTextWidget("Stop Tracking", key: Key("stop_tracking"))
            : TranslatedTextWidget("Track Objectives",
                key: Key("track_objectives")),
        onPressed: () {
          var service = LittleLightService();
          if (isTracking) {
            service.removeTrackedObjective(
                TrackedObjectiveType.Triumph, definition.hash);
          } else {
            service.addTrackedObjective(
                TrackedObjectiveType.Triumph, definition.hash);
          }
          updateTrackStatus();
        },
      ),
    );
  }
}
