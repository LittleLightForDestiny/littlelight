import 'package:bungie_api/models/destiny_presentation_node_child_entry.dart';
import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/widgets/collections/presentation_node_item.widget.dart';


class CollectionListWidget extends StatelessWidget {
  final DestinyPresentationNodeDefinition definition;
  CollectionListWidget({Key key, this.definition}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 30,
      itemCount: count,
      itemBuilder: (BuildContext context, int index) => getItem(context, index),
      staggeredTileBuilder: (int index) => getTileBuilder(index),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }

  Widget getItem(BuildContext context, int index) {
    DestinyPresentationNodeChildEntry node = presentationNodes[index];
    return PresentationNodeItemWidget(hash: node.presentationNodeHash);
  }

  List<DestinyPresentationNodeChildEntry> get presentationNodes =>
      definition.children.presentationNodes;

  int get count => definition.children.presentationNodes.length;

  StaggeredTile getTileBuilder(int index) {
    return StaggeredTile.extent(30, 30);
  }
}
