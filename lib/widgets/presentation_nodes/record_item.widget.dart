import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_record_definition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:little_light/screens/record_detail.screen.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/widgets/common/objective.widget.dart';

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
  DestinyRecordDefinition definition;
  Map<int, DestinyObjectiveDefinition> objectiveDefinitions;

  bool _keepAlive = false;
  KeepAliveHandle _handle;

  @override
  void deactivate() {
    _handle?.release();
    _handle = null;
    super.deactivate();
  }

  void setKeepAlive(bool value) {
    _keepAlive = value;
    if (_keepAlive) {
      if (_handle == null) {
        _handle = new KeepAliveHandle();
        new KeepAliveNotification(_handle).dispatch(context);
      }
    } else {
      _handle?.release();
      _handle = null;
    }
  }

  @override
  void initState() {
    super.initState();
    loadDefinitions();
  }

  loadDefinitions() async {
    var manifest = ManifestService();
    definition =
        await manifest.getDefinition<DestinyRecordDefinition>(widget.hash);
    if (!mounted) return;
    setState(() {});
    
    if(definition?.objectiveHashes != null){
      objectiveDefinitions = await manifest
          .getDefinitions<DestinyObjectiveDefinition>(definition.objectiveHashes);
    }
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_keepAlive && _handle == null) {
      _handle = new KeepAliveHandle();
      new KeepAliveNotification(_handle).dispatch(context);
    }
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade600, width: 1),
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
                              color: Colors.grey.shade300.withOpacity(.8),
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
    return Container(
        padding: EdgeInsets.all(4),
        child: Text(
          definition.displayProperties.name,
          softWrap: true,
          style: TextStyle(
              color: Colors.grey.shade300, fontWeight: FontWeight.bold),
        ));
  }

  buildDescription(BuildContext context) {
    if (definition == null) return Container();

    return Container(
        padding: EdgeInsets.all(4),
        child: Text(
          definition.displayProperties.description,
          softWrap: true,
          style: TextStyle(
              color: Colors.grey.shade300,
              fontWeight: FontWeight.w300,
              fontSize: 13),
        ));
  }

  buildObjectives(BuildContext context) {
    if (definition?.objectiveHashes == null) return Container();
    return Column(
        children: definition.objectiveHashes
            .map((hash) => ObjectiveWidget(
                  definition: objectiveDefinitions[hash],
                ))
            .toList());
  }
}
