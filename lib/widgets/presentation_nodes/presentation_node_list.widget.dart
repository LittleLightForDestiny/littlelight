import 'dart:math';

import 'package:bungie_api/models/destiny_presentation_node_child_entry.dart';
import 'package:bungie_api/models/destiny_presentation_node_collectible_child_entry.dart';
import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:bungie_api/models/destiny_presentation_node_record_child_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/services/manifest/manifest.service.dart';

typedef StaggeredTile PresentationNodeTileBuilder(CollectionListItem item);
typedef Widget PresentationNodeItemBuilder(CollectionListItem item, int depth);

class PresentationNodeListWidget extends StatefulWidget {
  final ManifestService manifest = new ManifestService();
  final int presentationNodeHash;
  final PresentationNodeTileBuilder tileBuilder;
  final PresentationNodeItemBuilder itemBuilder;
  final int depth;
  PresentationNodeListWidget({
    Key key,
    @required this.tileBuilder,
    @required this.itemBuilder,
    this.presentationNodeHash,
    this.depth = 0,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PresentationNodeListWidgetState();
  }
}

class PresentationNodeListWidgetState
    extends State<PresentationNodeListWidget> {
  DestinyPresentationNodeDefinition definition;
  Map<int, DestinyPresentationNodeDefinition> _presentationNodeDefinitions;

  List<CollectionListItem> listIndex;

  @override
  void initState() {
    super.initState();
    if (widget.presentationNodeHash != null) {
      buildIndex();
    }
  }

  void buildIndex() async {
    definition = await widget.manifest
        .getDefinition<DestinyPresentationNodeDefinition>(
            widget.presentationNodeHash);
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
      var def = _presentationNodeDefinitions[node.presentationNodeHash];
      if ((def?.children?.collectibles?.length ?? 0) <= 5) {
        def?.children?.collectibles?.forEach((collectible) {
          listIndex.add(CollectionListItem(
              CollectionListItemType.nestedCollectible,
              collectible.collectibleHash));
        });
      }
    });
    collectibles.forEach((collectible) {
      listIndex.add(CollectionListItem(
          CollectionListItemType.collectible, collectible.collectibleHash));
    });

    records.forEach((record) {
      listIndex.add(
          CollectionListItem(CollectionListItemType.record, record.recordHash));
    });
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenPadding = MediaQuery.of(context).padding;

    return StaggeredGridView.countBuilder(
      padding: EdgeInsets.all(4).copyWith(
          left: max(screenPadding.left, 4),
          right: max(screenPadding.right, 4),
          bottom: 4 + screenPadding.bottom),
      crossAxisCount: 30,
      itemCount: count,
      itemBuilder: (BuildContext context, int index) => getItem(context, index),
      staggeredTileBuilder: (int index) => getTileBuilder(index),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }

  Widget getItem(BuildContext context, int index) {
    var item = listIndex[index];
    return widget.itemBuilder(item, widget.depth);
  }

  List<DestinyPresentationNodeChildEntry> get presentationNodes =>
      definition?.children?.presentationNodes;

  List<DestinyPresentationNodeCollectibleChildEntry> get collectibles =>
      definition?.children?.collectibles;

  List<DestinyPresentationNodeRecordChildEntry> get records =>
      definition?.children?.records;

  int get count => listIndex?.length ?? 0;

  StaggeredTile getTileBuilder(int index) {
    var item = listIndex[index];
    return widget.tileBuilder(item);
  }
}

enum CollectionListItemType {
  presentationNode,
  collectible,
  nestedCollectible,
  nestedRecord,
  record
}

class CollectionListItem {
  final CollectionListItemType type;
  final int hash;
  CollectionListItem(this.type, this.hash);
}
