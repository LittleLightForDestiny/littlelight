import 'package:bungie_api/models/destiny_collectible_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/loadouts/loadout_background_item.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_list.widget.dart';
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
    DestinyPresentationNodeDefinition rootDefinition = await manifest
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

  loadNestedDefinitions(DestinyPresentationNodeDefinition definition) async {
    Iterable<int> nodeHashes = definition.children.presentationNodes
        .map((node) => node.presentationNodeHash)
        .toList();
    Iterable<int> collectibleHashes = definition.children.collectibles
        .map((collectible) => collectible.collectibleHash)
        .toList();
    var collectibleDefs = await manifest
        .getDefinitions<DestinyCollectibleDefinition>(collectibleHashes);
    var emblemHashes =
        collectibleDefs.values.map((def) => def.itemHash).toList();
    await manifest
        .getDefinitions<DestinyInventoryItemDefinition>(emblemHashes);
    var nodeDefs = await manifest
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
    );
  }

  @override
  Widget itemBuilder(CollectionListItem item, int depth, bool isCategorySet) {
    return LoadoutBackgroundItemWidget(
      hash: item.hash,
    );
  }
}
