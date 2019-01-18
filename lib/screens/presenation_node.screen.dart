import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/collections/collection_list.widget.dart';

class PresentationNodeScreen extends StatefulWidget {
  final _manifest = new ManifestService();
  final int presentationNodeHash;
  final DestinyPresentationNodeDefinition presentationNodeDefinition;
  final int depth;
  PresentationNodeScreen(
      {this.presentationNodeHash = DestinyData.collectionsRootHash,
      this.presentationNodeDefinition,
      this.depth = 0});

  @override
  PresentationNodeScreenState createState() =>
      new PresentationNodeScreenState();
}

class PresentationNodeScreenState extends State<PresentationNodeScreen> {
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
      appBar: AppBar(
        title: Text(definition.displayProperties.name),
      ),
      body: CollectionListWidget(definition: definition, depth: widget.depth),
    );
  }

  DestinyPresentationNodeDefinition get definition =>
      widget.presentationNodeDefinition ?? _definition;
}
