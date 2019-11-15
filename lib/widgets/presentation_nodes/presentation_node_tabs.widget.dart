import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

typedef Widget PresentationNodeTabBodyBuilder(
    int presentationNodeHash, int depth);

class PresentationNodeTabsWidget extends StatefulWidget {
  final _manifest = new ManifestService();
  final int presentationNodeHash;
  final List<int> presentationNodeHashes;
  final int depth;
  final PresentationNodeTabBodyBuilder bodyBuilder;
  PresentationNodeTabsWidget(
      {this.presentationNodeHash,
      this.presentationNodeHashes,
      this.depth = 0,
      @required this.bodyBuilder});

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
    if(widget.presentationNodeHash != null){
      loadDefinition();
    }
  }

  loadDefinition() async {
    definition = await widget._manifest
        .getDefinition<DestinyPresentationNodeDefinition>(
            widget.presentationNodeHash);
    if(mounted){
      setState(() {});
    }
  }

  List<int> get nodeHashes => widget.presentationNodeHashes ?? definition?.children?.presentationNodes?.map((p)=>p.presentationNodeHash)?.toList();

  @override
  Widget build(BuildContext context) {
    if (nodeHashes == null) return Container();
    List<Color> colors = [
      Colors.blueGrey.shade500,
      Colors.blueGrey.shade600,
      Colors.blueGrey.shade700,
      Colors.blueGrey.shade800
    ];
    int depth = widget.depth > -1 ? widget.depth : 0;
    if(nodeHashes.length == 0){
      return widget.bodyBuilder(
          widget.presentationNodeHash,
          widget.depth + 1);
    }
    if (nodeHashes.length == 1) {
      return widget.bodyBuilder(
          nodeHashes[0],
          widget.depth + 1);
    }
    return DefaultTabController(
        length: nodeHashes.length,
        child: Column(children: [
          Material(
            elevation: (depth * 2) / 3,
            color: colors[depth],
            child: Center(
                child: TabBar(
              indicatorColor: Colors.white,
              isScrollable: depth > 1,
              tabs: buildTabButtons(context),
            )),
          ),
          Expanded(
              child: TabBarView(
            children: buildTabs(context),
          ))
        ]));
  }

  List<Widget> buildTabButtons(BuildContext context) {
    return nodeHashes.map((hash) {
      return buildTabButton(context, hash);
    }).toList();
  }

  Widget buildTabButton(BuildContext context, int hash) {
    if (widget.depth < 3 && widget.depth != 0) {
      return Container(
          padding: EdgeInsets.all(8),
          child: Container(
            constraints: BoxConstraints(maxHeight: 48),
            child:AspectRatio(
            aspectRatio: 1,
              child: ManifestImageWidget<DestinyPresentationNodeDefinition>(
            hash,
            placeholder: Container(),
          ))));
    }
    return Container(
        padding: EdgeInsets.all(8),
        child: ManifestText<DestinyPresentationNodeDefinition>(hash,
            uppercase: true,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )));
  }

  List<Widget> buildTabs(BuildContext context) {
    return nodeHashes.map((hash) {
      return widget.bodyBuilder(hash, widget.depth + 1);
    }).toList();
  }
}
