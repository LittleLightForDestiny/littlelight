import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_list.widget.dart';

class PresentationNodeRootScreen extends StatefulWidget {
  final _manifest = new ManifestService();
  final int presentationNodeHash;
  final DestinyPresentationNodeDefinition presentationNodeDefinition;
  final int depth;
  PresentationNodeRootScreen(
      {this.presentationNodeHash = DestinyData.collectionsRootHash,
      this.presentationNodeDefinition,
      this.depth = 0, Key key}):super(key:key);

  @override
  PresentationNodeRootScreenState createState() =>
      new PresentationNodeRootScreenState();
}

class PresentationNodeRootScreenState extends State<PresentationNodeRootScreen> {
  DestinyPresentationNodeDefinition _definition;
  @override
  void initState() {
    super.initState();
    if (definition == null) {
      loadDefinition();
    }
  }

  loadDefinition() async {
    _definition = await widget._manifest
        .getDefinition<DestinyPresentationNodeDefinition>(
            widget.presentationNodeHash);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (definition == null) return Container();
    return Scaffold(
      appBar: AppBar(title:Text(definition.displayProperties.name)),
      body:buildBody(context)
    );
  }

  Widget buildBody(BuildContext context) {
    return PresentationNodeListWidget(definition: definition, depth: widget.depth);
  }

  DestinyPresentationNodeDefinition get definition =>
      widget.presentationNodeDefinition ?? _definition;
}
