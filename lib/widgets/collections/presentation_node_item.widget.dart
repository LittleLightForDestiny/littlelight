import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:little_light/screens/presenation_node.screen.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';

class PresentationNodeItemWidget extends StatelessWidget {
  final int hash;
  final int depth;
  PresentationNodeItemWidget({Key key, this.hash, this.depth}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return DefinitionProviderWidget<DestinyPresentationNodeDefinition>(hash,
        (definition) {
      return Container(
          margin: EdgeInsets.symmetric(vertical: 4),
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
                AspectRatio(
                    aspectRatio: 1,
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PresentationNodeScreen(
                          presentationNodeHash: hash,
                          depth:depth + 1
                        ),
                  ),
                );
              },
            )
          ]));
    });
  }

  buildTitle(
      BuildContext context, DestinyPresentationNodeDefinition definition) {
    return Expanded(
        child: Container(
          padding:EdgeInsets.all(8),
          child:Text(
          definition.displayProperties.name,
          softWrap: true,
          style: TextStyle(
              color: Colors.grey.shade300, fontWeight: FontWeight.bold),
        )));
  }
}
