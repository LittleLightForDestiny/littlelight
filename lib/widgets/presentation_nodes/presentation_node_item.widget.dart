import 'package:bungie_api/models/destiny_presentation_node_component.dart';
import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';

typedef void PresentationNodePressedHandler(int hash, int depth);

class PresentationNodeItemWidget extends StatefulWidget {
  final int hash;
  final int depth;
  final PresentationNodePressedHandler onPressed;
  final ManifestService manifest = ManifestService();
  final ProfileService profile = ProfileService();
  PresentationNodeItemWidget(
      {Key key, this.hash, this.depth, @required this.onPressed})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PresentationNodeWidgetState();
  }
}

class PresentationNodeWidgetState extends State<PresentationNodeItemWidget> {
  DestinyPresentationNodeComponent profileProgress;
  Map<String, DestinyPresentationNodeComponent> charactersProgress;
  DestinyPresentationNodeDefinition definition;

  @override
  void initState() {
    super.initState();
    this.loadDefinition();
    this.loadCompletionData();
  }

  loadDefinition() async {
    definition = await widget.manifest
        .getDefinition<DestinyPresentationNodeDefinition>(widget.hash);
    setState(() {});
  }

  loadCompletionData() {
    var profileNodes = widget.profile.getProfilePresentationNodes();
    var characters = widget.profile.getCharacters();

    if (profileNodes != null) {
      this.profileProgress = profileNodes["${widget.hash}"];
    }
    if (characters != null) {
      charactersProgress = Map.fromEntries(characters.map((char) {
        var nodes =
            widget.profile.getCharacterPresentationNodes(char.characterId);
        return MapEntry(char.characterId, nodes["${widget.hash}"]);
      }));
      charactersProgress.removeWhere((k, v) => v == null);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                widget.onPressed(widget.hash, widget.depth);
              })
        ]));
  }

  List<Widget> buildContent(
      BuildContext context, DestinyPresentationNodeDefinition definition) {
    return [
      AspectRatio(
          aspectRatio: 1,
          child: definition?.displayProperties?.icon == null
              ? Container()
              : Padding(
                  padding: EdgeInsets.all(8),
                  child: QueuedNetworkImage(
                    imageUrl:
                        BungieApiService.url(definition.displayProperties.icon),
                  ))),
      buildTitle(context, definition),
      buildCount(context)
    ];
  }

  buildCount(BuildContext context) {
    if (definition == null) {
      return Container();
    }
    if (profileProgress != null) {
      return Container(
          padding: EdgeInsets.all(8),
          child: Text(
            "${profileProgress.progressValue}/${profileProgress.completionValue}",
            style: TextStyle(fontWeight: FontWeight.bold),
          ));
    }
    if (charactersProgress != null) {
      return Container(
          padding: EdgeInsets.all(8),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: charactersProgress
                  .map((k, v) {
                    return MapEntry(
                        k,
                        
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child:Row(children: [
                          Icon(DestinyData.getClassIcon(
                              widget.profile.getCharacter(k).classType), size:14),
                          Text("${v.progressValue}/${v.completionValue}",
                              style: TextStyle(fontWeight: FontWeight.bold))
                        ])));
                  })
                  .values
                  .toList()));
    }
    return Container();
  }

  buildTitle(
      BuildContext context, DestinyPresentationNodeDefinition definition) {
    return Expanded(
        child: Container(
            padding: EdgeInsets.all(8),
            child: Text(
              definition?.displayProperties?.name ?? "",
              softWrap: true,
              style: TextStyle(
                  color: Colors.grey.shade300, fontWeight: FontWeight.bold),
            )));
  }
}
