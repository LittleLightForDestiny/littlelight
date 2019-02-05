import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';

typedef void PresentationNodePressedHandler(int hash, int depth);

class PresentationNodeItemWidget extends StatelessWidget {
  final int hash;
  final int depth;
  final PresentationNodePressedHandler onPressed;
  PresentationNodeItemWidget(
      {Key key, this.hash, this.depth, @required this.onPressed})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return DefinitionProviderWidget<DestinyPresentationNodeDefinition>(hash,
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
            Row(children: buildContent(context, definition)),
            FlatButton(
                child: Container(),
                onPressed: () {
                  onPressed(this.hash, this.depth);
                })
          ]));
    });
  }

  List<Widget> buildContent(
      BuildContext context, DestinyPresentationNodeDefinition definition) {
    return [
      AspectRatio(
          aspectRatio: 1,
          child: definition?.displayProperties?.icon == null ? Container():
          Padding(
              padding: EdgeInsets.all(8),
              child: QueuedNetworkImage(
                imageUrl:
                    BungieApiService.url(definition.displayProperties.icon),
              ))),
      buildTitle(context, definition)
    ];
  }

  buildTitle(
      BuildContext context, DestinyPresentationNodeDefinition definition) {
    return Expanded(
        child: Container(
            padding: EdgeInsets.all(8),
            child: Text(
              definition.displayProperties.name,
              softWrap: true,
              style: TextStyle(
                  color: Colors.grey.shade300, fontWeight: FontWeight.bold),
            )));
  }
}
