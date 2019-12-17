import 'package:bungie_api/enums/destiny_class_enum.dart';
import 'package:bungie_api/models/destiny_presentation_node_component.dart';
import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';
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
  Map<int, DestinyPresentationNodeComponent> progress;
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

    if (profileNodes?.containsKey("${widget.hash}") ?? false) {
      this.progress = {DestinyClass.Unknown: profileNodes["${widget.hash}"]};
      if (this.progress != null) return;
    }
    var characters =
        widget.profile.getCharacters(UserSettingsService().characterOrdering);
    if (characters == null || characters.length == 0) return;
    var progress = Map.fromEntries(
        characters.map<MapEntry<int, DestinyPresentationNodeComponent>>((c) {
      var characterNodes =
          widget.profile.getCharacterPresentationNodes(c.characterId);
      var node = characterNodes["${widget.hash}"];
      return MapEntry<int, DestinyPresentationNodeComponent>(
        c.classType,
        node
      );
    }));
    var valuesSet = progress.values.map((v) => v.progressValue).toSet();
    if (valuesSet.length == 1) {
      progress = {DestinyClass.Unknown: progress.values.first};
    }
    this.progress = progress;
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
      definition?.displayProperties?.hasIcon == true
          ? AspectRatio(
              aspectRatio: 1,
              child: definition?.displayProperties?.icon == null
                  ? Container()
                  : Padding(
                      padding: EdgeInsets.all(8),
                      child: QueuedNetworkImage(
                        imageUrl: BungieApiService.url(
                            definition.displayProperties.icon),
                      )))
          : Container(width: 20),
      buildTitle(context, definition),
      buildCount(context)
    ];
  }

  buildCount(BuildContext context) {
    if (definition == null) {
      return Container();
    }
    if (progress != null) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: progress?.entries
                  ?.map((e) => Container(
                      padding: EdgeInsets.only(top: 2, bottom: 2, right: 8),
                      child: Row(children: [
                        e.key != DestinyClass.Unknown ? Icon(
                          DestinyData.getClassIcon(e.key),
                          size: 16,
                        ) : Container(),
                        Container(width: 4),
                        Text(
                          "${e?.value?.progressValue}/${e?.value?.completionValue}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ])))
                  ?.toList() ??
              []);
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
