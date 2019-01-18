import 'package:bungie_api/models/destiny_presentation_node_child_entry.dart';
import 'package:bungie_api/models/destiny_presentation_node_collectible_child_entry.dart';
import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:bungie_api/models/destiny_presentation_node_record_child_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/widgets/collections/presentation_node_item.widget.dart';

class CollectionListWidget extends StatefulWidget {
  final ManifestService manifest = new ManifestService();
  final DestinyPresentationNodeDefinition definition;
  final int depth;
  CollectionListWidget({Key key, this.definition, this.depth = 0})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return CollectionListWidgetState();
  }
}

class CollectionListWidgetState extends State<CollectionListWidget> {
  Map<int, DestinyPresentationNodeDefinition> _presentationNodeDefinitions;
  List<CollectionListItem> listIndex;

  @override
  void initState() {
    super.initState();
    buildIndex();
  }

  void buildIndex() async {
    if (presentationNodes.length > 0) {
      List<int> hashes =
          presentationNodes.map((node) => node.presentationNodeHash).toList();
      _presentationNodeDefinitions = await widget.manifest
          .getDefinitions<DestinyPresentationNodeDefinition>(hashes);
    }
    listIndex = List<CollectionListItem>();
    presentationNodes.forEach((node) {
      listIndex.add(CollectionListItem(
          CollectionListItemType.presentationNode, node.presentationNodeHash));
      _presentationNodeDefinitions[node.presentationNodeHash]
          .children
          .collectibles
          .forEach((collectible) {
        listIndex.add(CollectionListItem(
            CollectionListItemType.collectible, collectible.collectibleHash));
      });
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
      padding: EdgeInsets.all(4),
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
    var item = listIndex[index];
    switch (item.type) {
      case CollectionListItemType.presentationNode:
        return PresentationNodeItemWidget(hash: item.hash, depth: widget.depth);

      default:
        return Container(color: Colors.red);
    }
  }

  List<DestinyPresentationNodeChildEntry> get presentationNodes =>
      definition?.children?.presentationNodes;

  List<DestinyPresentationNodeCollectibleChildEntry> get collectibles =>
      definition?.children?.collectibles;

  List<DestinyPresentationNodeRecordChildEntry> get records =>
      definition?.children?.records;

  int get count => listIndex?.length ?? 0;

  DestinyPresentationNodeDefinition get definition => widget.definition;

  StaggeredTile getTileBuilder(int index) {
    var item = listIndex[index];
    switch (item.type) {
      case CollectionListItemType.collectible:
        return StaggeredTile.count(6, 6);

      default:
        return StaggeredTile.count(30, 7);
    }
  }
}

enum CollectionListItemType { presentationNode, collectible, record }

class CollectionListItem {
  final CollectionListItemType type;
  final int hash;
  CollectionListItem(this.type, this.hash);
}
