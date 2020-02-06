import 'package:bungie_api/enums/destiny_presentation_screen_style.dart';
import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_body.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_list.widget.dart';
import 'package:little_light/utils/media_query_helper.dart';

class PresentationNodeTabsWidget extends StatefulWidget {
  final _manifest = new ManifestService();
  final int presentationNodeHash;
  final List<int> presentationNodeHashes;
  final int depth;

  final PresentationNodeItemBuilder itemBuilder;
  final PresentationNodeTileBuilder tileBuilder;

  final bool isCategorySet;

  PresentationNodeTabsWidget(
      {this.presentationNodeHash,
      this.presentationNodeHashes,
      this.depth = 0,
      this.itemBuilder,
      this.tileBuilder,
      this.isCategorySet = false});

  @override
  PresentationNodeTabsWidgetState createState() =>
      new PresentationNodeTabsWidgetState();
}

class PresentationNodeTabsWidgetState
    extends State<PresentationNodeTabsWidget> {
  DestinyPresentationNodeDefinition definition;
  @override
  void initState() {
    super.initState();
    if (widget.presentationNodeHash != null) {
      loadDefinition();
    }
  }

  loadDefinition() async {
    definition = await widget._manifest
        .getDefinition<DestinyPresentationNodeDefinition>(
            widget.presentationNodeHash);
    if (mounted) {
      setState(() {});
    }
  }

  List<int> get nodeHashes =>
      widget.presentationNodeHashes ??
      definition?.children?.presentationNodes
          ?.map((p) => p.presentationNodeHash)
          ?.toList();

  @override
  Widget build(BuildContext context) {
    if (nodeHashes == null) return Container();
    List<Color> colors = [
      Colors.blueGrey.shade500,
      Colors.blueGrey.shade600,
      Colors.blueGrey.shade700,
      Colors.blueGrey.shade800,
      Colors.blueGrey.shade900
    ];
    int depth = widget.depth > -1 ? widget.depth : 0;
    if (nodeHashes.length == 1) {
      return PresentationNodeBodyWidget(
        depth: widget.depth + 1,
        presentationNodeHash: nodeHashes[0],
        itemBuilder: widget.itemBuilder,
        tileBuilder: widget.tileBuilder,
        isCategorySet: widget.isCategorySet ||
            definition.screenStyle ==
                DestinyPresentationScreenStyle.CategorySets,
      );
    }
    return DefaultTabController(
        length: nodeHashes.length,
        child: Column(children: [
          Material(
              elevation: (depth * 2) / 3,
              color: colors[depth],
              child: Container(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width),
                  color: colors[depth],
                  child: TabBar(
                    labelPadding: EdgeInsets.all(0),
                    indicatorColor: Colors.white,
                    isScrollable: true,
                    tabs: buildTabButtons(context),
                  ))),
          Expanded(
              child: TabBarView(
            children: buildTabs(context),
          ))
        ]));
  }

  List<Widget> buildTabButtons(BuildContext context) {
    return nodeHashes.map((hash) {
      return buildTabButton(context, hash, nodeHashes.length);
    }).toList();
  }

  Widget buildTabButton(BuildContext context, int hash, [int tabCount = 3]) {
    return Container(
        constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width / tabCount),
        padding: EdgeInsets.all(8),
        child: DefinitionProviderWidget<DestinyPresentationNodeDefinition>(hash,
            (def) {
          if (def?.displayProperties?.hasIcon ?? false) {
            if (MediaQueryHelper(context).biggerThan(ScreenSize.Small)) {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        constraints: BoxConstraints(maxHeight: 48),
                        child: AspectRatio(
                            aspectRatio: 1,
                            child: ManifestImageWidget<
                                DestinyPresentationNodeDefinition>(
                              hash,
                              placeholder: Container(),
                            ))),
                    Container(
                      height: 8,
                    ),
                    ManifestText<DestinyPresentationNodeDefinition>(hash,
                        uppercase: true,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12,
                        ))
                  ]);
            }
            return Container(
                constraints: BoxConstraints(maxHeight: 48),
                child: AspectRatio(
                    aspectRatio: 1,
                    child:
                        ManifestImageWidget<DestinyPresentationNodeDefinition>(
                      hash,
                      placeholder: Container(),
                    )));
          }
          return ManifestText<DestinyPresentationNodeDefinition>(hash,
              uppercase: true,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                fontSize: 12,
              ));
        }));
  }

  List<Widget> buildTabs(BuildContext context) {
    return nodeHashes.map((hash) {
      return PresentationNodeBodyWidget(
        depth: widget.depth + 1,
        presentationNodeHash: hash,
        itemBuilder: widget.itemBuilder,
        tileBuilder: widget.tileBuilder,
        isCategorySet: widget.isCategorySet,
      );
    }).toList();
  }
}
