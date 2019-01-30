import 'package:bungie_api/models/destiny_record_definition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:little_light/screens/record_detail.screen.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';

class RecordItemWidget extends StatelessWidget {
  final ManifestService manifest = new ManifestService();
  final int hash;
  RecordItemWidget({Key key, this.hash}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return DefinitionProviderWidget<DestinyRecordDefinition>(hash,
        (definition) {
      return Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade600, width: 1),
              gradient: LinearGradient(
                  begin: Alignment(0, 0),
                  end: Alignment(1, 2),
                  colors: [
                    Colors.white.withOpacity(.05),
                    Colors.white.withOpacity(.1),
                    Colors.white.withOpacity(.03),
                    Colors.white.withOpacity(.1)
                  ])),
          child: Stack(children: [
            Row(
              children: <Widget>[
                Container(
                    width:72,
                    height:72,
                    child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CachedNetworkImage(
                          imageUrl: BungieApiService.url(
                              definition.displayProperties.icon),
                        ))),
                buildTitle(context, definition),
              ],
            ),
            FlatButton(
              child: Container(),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecordDetailScreen(definition),
                  ),
                );
              },
            )
          ]));
    });
  }

  buildTitle(BuildContext context, DestinyRecordDefinition definition) {
        return Container(
            padding: EdgeInsets.all(8),
            child: Text(
              definition.displayProperties.name,
              softWrap: true,
              style: TextStyle(
                  color: Colors.grey.shade300, fontWeight: FontWeight.bold),
            ));
  }

  buildDescription(BuildContext context, DestinyRecordDefinition definition) {
    return Expanded(
        child: Container(
            padding: EdgeInsets.all(8),
            child: Text(
              definition.displayProperties.description,
              softWrap: true,
              style: TextStyle(
                  color: Colors.grey.shade300),
            )));
  }
}
