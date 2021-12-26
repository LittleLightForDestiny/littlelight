import 'package:bungie_api/models/destiny_collectible_definition.dart';

import 'package:flutter/material.dart';
import 'package:little_light/pages/definition_search.screen.dart';
import 'package:little_light/widgets/presentation_nodes/collectible_item.widget.dart';

class CollectibleSearchScreen extends DefinitionSearchScreen {
  CollectibleSearchScreen({Key key}) : super(key: key);

  @override
  CollectibleSearchScreenState createState() =>
      new CollectibleSearchScreenState();
}

class CollectibleSearchScreenState
    extends DefinitionSearchScreenState<DefinitionSearchScreen, DestinyCollectibleDefinition> {

  @override
  initState() {
    super.initState();
  }

  Widget itemBuilder(BuildContext context, int index) {
    var item = items[index];
    return Stack(children: [
      Container(
          height: 96,
          child:
              CollectibleItemWidget(key: Key("${item.hash}"), hash: item.hash)),
    ]);
  }
}
