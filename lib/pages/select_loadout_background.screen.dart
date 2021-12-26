import 'package:bungie_api/models/destiny_collectible_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/widgets/loadouts/loadout_background_item.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_list.widget.dart';

import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_tabs.widget.dart';
import 'presentation_node.screen.dart';

class SelectLoadoutBackgroundScreen extends PresentationNodeScreen {
  SelectLoadoutBackgroundScreen()
      : super(presentationNodeHash: 2381001021, depth: 2);

  @override
  PresentationNodeScreenState createState() =>
      new SelectLoadoutBackgroundScreenState();
}

class SelectLoadoutBackgroundScreenState extends PresentationNodeScreenState {
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
    return Scaffold(
        appBar:
            AppBar(title: TranslatedTextWidget("Select Loadout Background")),
        body: buildScaffoldBody(context));
  }

  //  Widget buildBody(BuildContext context, {int hash, int depth}) {
  //   if(definition?.children == null) return Container();
  //   if((definition?.children?.presentationNodes?.length ?? 0) == 0){
  //     return listBuilder(hash, depth);
  //   }

  //   return tabBuilder(hash, 0);
  // }

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
  Widget buildBody(BuildContext context) {
    if(definition == null) return Container();
    return PresentationNodeTabsWidget(
      presentationNodeHashes: definition.children.presentationNodes.map((p)=>p.presentationNodeHash).toList(),
      depth: 0,
      itemBuilder: this.itemBuilder,
      tileBuilder: this.tileBuilder,
    );
  }

  @override
  Widget itemBuilder(CollectionListItem item, int depth, bool isCategorySet) {
    return LoadoutBackgroundItemWidget(
      hash: item.hash,
    );
  }

  @override
  StaggeredTile tileBuilder(CollectionListItem item) {
    return StaggeredTile.extent(30, kToolbarHeight);
  }
}
