import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/widgets/collections/collection_list.widget.dart';

class CollectionsScreen extends StatefulWidget {
  final _manifest = new ManifestService();
  final int presentationNodeHash;
  CollectionsScreen({this.presentationNodeHash = 3790247699});

  @override
  CollectionsScreenState createState() => new CollectionsScreenState();
}

class CollectionsScreenState extends State<CollectionsScreen> {
  DestinyPresentationNodeDefinition definition;

  @override
  void initState() {
    super.initState();
    loadDefinition();
  }

  loadDefinition() async{
      definition = await widget._manifest.getDefinition<DestinyPresentationNodeDefinition>(widget.presentationNodeHash);
      setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if(definition == null) return Container();
    return Scaffold(
      appBar: AppBar(title: Text(definition.displayProperties.name),),
      body: CollectionListWidget(definition: definition,),
    );
  }
}
