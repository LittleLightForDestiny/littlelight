import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';


typedef Widget PresentationNodeTabBodyBuilder(int presentationNodeHash, int depth);

class PresentationNodeTabsWidget extends StatefulWidget {
  final _manifest = new ManifestService();
  final int presentationNodeHash;
  final int depth;
  final PresentationNodeTabBodyBuilder bodyBuilder;
  PresentationNodeTabsWidget(
      {this.presentationNodeHash = DestinyData.collectionsRootHash,
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
    loadDefinition();
  }

  loadDefinition() async {
    definition = await widget._manifest
        .getDefinition<DestinyPresentationNodeDefinition>(
            widget.presentationNodeHash);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (definition == null) return Container();
    List<Color> colors = [
      Colors.blueGrey.shade500,
      Colors.blueGrey.shade600,
      Colors.blueGrey.shade700,
      Colors.blueGrey.shade800
    ];
    return DefaultTabController(
        length: definition.children.presentationNodes.length,
        child: Scaffold(
          appBar: PreferredSize(
            child: Material(
              elevation: (widget.depth*2)/3,
              color:colors[widget.depth],
              child: TabBar(
                indicatorColor: Colors.white,
                isScrollable: widget.depth > 1,
                tabs: buildTabButtons(context),
              ),
            ),
            preferredSize: Size.fromHeight(kToolbarHeight*1.3),
          ),
          body: TabBarView(
            children: buildTabs(context),
          ),
        ));
  }

  List<Widget> buildTabButtons(BuildContext context) {
    return definition.children.presentationNodes.map((node) {
      return buildTabButton(context, node.presentationNodeHash);
    }).toList();
  }

  Widget buildTabButton(BuildContext context, int hash) {
    if (widget.depth < 2) {
      return Container(
        padding: EdgeInsets.all(8),
        child:ManifestImageWidget<DestinyPresentationNodeDefinition>(hash, placeholder: Container(),));
    }
    return Container(
      padding: EdgeInsets.all(8),
      child:ManifestText<DestinyPresentationNodeDefinition>(hash, uppercase: true,
      style: TextStyle(fontWeight: FontWeight.bold,))
    );
  }

  List<Widget> buildTabs(BuildContext context) {
    return definition.children.presentationNodes.map((node) {
      return widget.bodyBuilder(node.presentationNodeHash, widget.depth+1);
    }).toList();
  }
}
