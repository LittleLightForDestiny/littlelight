import 'package:bungie_api/models/destiny_collectible_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/screens/base/presentation_node_base.screen.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/loadouts/loadout_background_item.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_list.widget.dart';

class SelectLoadoutBackgroundScreen extends PresentationNodeBaseScreen {
  SelectLoadoutBackgroundScreen()
      : super(presentationNodeHash: 2381001021, depth: 2);

  @override
  PresentationNodeBaseScreenState createState() =>
      new SelectLoadoutBackgroundScreenState();
}

class SelectLoadoutBackgroundScreenState
    extends PresentationNodeBaseScreenState {
  @override
  loadDefinition() async {
    DestinyPresentationNodeDefinition rootDefinition = await widget.manifest
        .getDefinition<DestinyPresentationNodeDefinition>(
            widget.presentationNodeHash);
    await loadNestedDefinitions(rootDefinition);
    definition = rootDefinition;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (definition == null) return Container();
    return Scaffold(
        appBar:
            AppBar(title: TranslatedTextWidget("Select Loadout Background")),
        body: buildBody(context, hash:widget.presentationNodeHash, depth:widget.depth));
  }

  loadNestedDefinitions(DestinyPresentationNodeDefinition definition) async {
    Iterable<int> nodeHashes = definition.children.presentationNodes
        .map((node) => node.presentationNodeHash)
        .toList();
    Iterable<int> collectibleHashes = definition.children.collectibles
        .map((collectible) => collectible.collectibleHash)
        .toList();
    var collectibleDefs = await widget.manifest
        .getDefinitions<DestinyCollectibleDefinition>(collectibleHashes);
    var emblemHashes =
        collectibleDefs.values.map((def) => def.itemHash).toList();
    await widget.manifest
        .getDefinitions<DestinyInventoryItemDefinition>(emblemHashes);
    var nodeDefs = await widget.manifest
        .getDefinitions<DestinyPresentationNodeDefinition>(nodeHashes);
    for (var def in nodeDefs.values) {
      await loadNestedDefinitions(def);
    }
  }

  @override
  Widget itemBuilder(CollectionListItem item) {
    return LoadoutBackgroundItemWidget(
      hash: item.hash,
    );
  }

  @override
  StaggeredTile tileBuilder(CollectionListItem item) {
    return StaggeredTile.extent(30, kToolbarHeight);
  }

}
