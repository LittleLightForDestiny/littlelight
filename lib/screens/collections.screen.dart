import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/selected_page_persistence.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_list.widget.dart';

enum PresentationNodeMode{
  collection,
  triumphs
}

class CollectionsScreen extends StatefulWidget {
  final _manifest = new ManifestService();
  final int presentationNodeHash;
  final DestinyPresentationNodeDefinition presentationNodeDefinition;
  final int depth;
  final PresentationNodeMode mode;
  final AuthService auth = new AuthService();
  final ProfileService profile = new ProfileService();
  CollectionsScreen(
      {this.presentationNodeHash = DestinyData.collectionsRootHash,
      this.presentationNodeDefinition,
      this.depth = 0, Key key,
      this.mode = PresentationNodeMode.collection}):super(key:key);

  @override
  CollectionsScreenState createState() =>
      new CollectionsScreenState();
}

class CollectionsScreenState extends State<CollectionsScreen> {
  DestinyPresentationNodeDefinition _definition;
  @override
  void initState() {
    SelectedPagePersistence.saveLatestScreen(SelectedPagePersistence.collections);
    super.initState();
    if (definition == null) {
      loadDefinition();
    }
    if(widget.auth.isLogged){
      widget.profile.fetchProfileData(components:ProfileComponentGroups.collections);
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
    return PresentationNodeListWidget(definition: definition, depth: widget.depth);
  }

  DestinyPresentationNodeDefinition get definition =>
      widget.presentationNodeDefinition ?? _definition;
}
