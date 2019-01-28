import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/selected_page_persistence.dart';

enum PresentationNodeMode{
  collection,
  triumphs
}

class TriumphsScreen extends StatefulWidget {
  final _manifest = new ManifestService();
  final int presentationNodeHash;
  final DestinyPresentationNodeDefinition presentationNodeDefinition;
  final int depth;
  final PresentationNodeMode mode;
  TriumphsScreen(
      {this.presentationNodeHash = DestinyData.collectionsRootHash,
      this.presentationNodeDefinition,
      this.depth = 0, Key key,
      this.mode = PresentationNodeMode.collection}):super(key:key);

  @override
  TriumphsScreenState createState() =>
      new TriumphsScreenState();
}

class TriumphsScreenState extends State<TriumphsScreen> {
  DestinyPresentationNodeDefinition _definition;
  @override
  void initState() {
    super.initState();
    SelectedPagePersistence.saveLatestScreen(SelectedPagePersistence.triumphs);
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
        leading: IconButton(icon:Icon(Icons.menu), onPressed: () {
          Scaffold.of(context).openDrawer();
        },),
        title:Text(definition.displayProperties.name)),
      body:buildBody(context)
    );
  }

  Widget buildBody(BuildContext context) {
    return Container();
  }

  DestinyPresentationNodeDefinition get definition =>
      widget.presentationNodeDefinition ?? _definition;
}
