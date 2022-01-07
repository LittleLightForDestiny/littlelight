import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_presentation_node_component.dart';
import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

typedef void PresentationNodePressedHandler(
    int hash, int depth, bool isCategorySet);

class PresentationNodeItemWidget extends StatefulWidget {
  final int hash;
  final int depth;
  final PresentationNodePressedHandler onPressed;
  

  final bool isCategorySet;
  PresentationNodeItemWidget(
      {Key key,
      this.hash,
      this.depth,
      @required this.onPressed,
      @required this.isCategorySet})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PresentationNodeWidgetState();
  }
}

class PresentationNodeWidgetState extends State<PresentationNodeItemWidget>
    with AuthConsumer, UserSettingsConsumer, ProfileConsumer, ManifestConsumer {
  DestinyPresentationNodeComponent progress;
  Map<String, DestinyPresentationNodeComponent> multiProgress;
  DestinyPresentationNodeDefinition definition;

  @override
  void initState() {
    super.initState();
    this.loadDefinition();
    if (auth.isLogged) {
      this.loadCompletionData();
    }
  }

  loadDefinition() async {
    definition = await manifest
        .getDefinition<DestinyPresentationNodeDefinition>(widget.hash);
    if (mounted) {
      setState(() {});
    }
  }

  loadCompletionData() {
    var profileNodes = profile.getProfilePresentationNodes();

    if (profileNodes?.containsKey("${widget.hash}") ?? false) {
      this.progress = profileNodes["${widget.hash}"];
    }
    if (this.progress != null) return;

    var characters =
        profile.getCharacters(userSettings.characterOrdering);
    if (characters == null || characters.length == 0) return;

    DestinyPresentationNodeComponent highest;
    multiProgress = Map();
    bool allEqual = true;

    for (var c in characters) {
      var characterNodes =
          profile.getCharacterPresentationNodes(c.characterId);
      var node = characterNodes["${widget.hash}"];
      if (highest == null ||
          (node?.progressValue ?? 0) > highest?.progressValue) {
        highest = node;
      }
      if (highest != null && node.progressValue != highest.progressValue) {
        allEqual = false;
      }
      multiProgress[c.characterId] = node;
    }

    if (allEqual) {
      multiProgress = null;
    }

    this.progress = highest;
  }

  int get progressValue => progress?.progressValue ?? 0;
  int get completionValue => progress?.completionValue;
  bool get completed =>
      completionValue != null && progressValue >= completionValue;

  @override
  Widget build(BuildContext context) {
    var color = completed ? Colors.amber.shade100 : Colors.grey.shade300;
    return Container(
        decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(.6), width: 1),
            gradient: LinearGradient(
                begin: Alignment(0, 0),
                end: Alignment(1, 2),
                colors: [
                  color.withOpacity(.05),
                  color.withOpacity(.1),
                  color.withOpacity(.03),
                  color.withOpacity(.1)
                ])),
        child: Stack(children: [
          Opacity(
              opacity: completed ? 1 : .7,
              child: Row(children: buildContent(context, definition))),
          Positioned(
              child: buildProgressBar(context), bottom: 0, left: 0, right: 0),
          MaterialButton(
              child: Container(),
              onPressed: () {
                widget.onPressed(
                    widget.hash, widget.depth, widget.isCategorySet);
              })
        ]));
  }

  Widget buildProgressBar(BuildContext context) {
    if ((completionValue ?? 0) <= 1) return Container();

    var color = completed ? Colors.amber.shade100 : Colors.grey.shade300;
    return Container(
      height: 4,
      color: color.withOpacity(.4),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
          widthFactor: progressValue / completionValue,
          child: Container(color: color.withOpacity(.7))),
    );
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

    if (multiProgress != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: multiProgress.entries.map((e) {
          var c = profile.getCharacter(e.key);
          return buildSingleCount(context, e.value, c);
        }).toList(),
      );
    }

    if (progress != null) {
      return buildSingleCount(context, progress);
    }

    return Container();
  }

  Widget buildSingleCount(
      BuildContext context, DestinyPresentationNodeComponent progress,
      [DestinyCharacterComponent character]) {
    var color = completed ? Colors.amber.shade100 : Colors.grey.shade300;
    return Container(
        padding: EdgeInsets.only(top: 2, bottom: 2, right: 8),
        child: Row(children: [
          character != null
              ? Icon(
                  DestinyData.getClassIcon(
                    character.classType,
                  ),
                  size: 16,
                  color: color)
              : Container(),
          Container(width: 4),
          (completionValue ?? 0) > 0
              ? Text(
                  "${progress?.progressValue}/${progress.completionValue}",
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                )
              : Container()
        ]));
  }

  buildTitle(
      BuildContext context, DestinyPresentationNodeDefinition definition) {
    var color = completed ? Colors.amber.shade100 : Colors.grey.shade300;
    return Expanded(
        child: Container(
            padding: EdgeInsets.all(8),
            child: Text(
              definition?.displayProperties?.name ?? "",
              softWrap: true,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            )));
  }
}
