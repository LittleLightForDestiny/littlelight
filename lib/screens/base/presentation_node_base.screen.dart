import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/presentation_nodes/collectible_item.widget.dart';
import 'package:little_light/widgets/presentation_nodes/nested_collectible_item.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_item.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_list.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_tabs.widget.dart';
import 'package:little_light/widgets/presentation_nodes/record_item.widget.dart';

class PresentationNodeBaseScreen extends StatefulWidget {
  final manifest = new ManifestService();
  final int presentationNodeHash;
  final int depth;
  PresentationNodeBaseScreen(
      {this.presentationNodeHash = DestinyData.collectionsRootHash,
      this.depth = 0});

  @override
  PresentationNodeBaseScreenState createState() =>
      new PresentationNodeBaseScreenState();
}

class PresentationNodeBaseScreenState<T extends PresentationNodeBaseScreen>
    extends State<PresentationNodeBaseScreen> {
  DestinyPresentationNodeDefinition definition;
  @override
  void initState() {
    super.initState();
    if (definition == null) {
      loadDefinition();
    }
  }

  loadDefinition() async {
    definition = await widget.manifest
        .getDefinition<DestinyPresentationNodeDefinition>(
            widget.presentationNodeHash);
    print(definition);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (definition == null) return Container();
    print(widget.depth);
    return Scaffold(
        appBar: AppBar(title: Text(definition.displayProperties.name)),
        body: buildBody(context, widget.presentationNodeHash, widget.depth));
  }

  Widget buildBody(BuildContext context, int presentationNodeHash, int depth) {
    if (depth == 0 || depth > 2) {
      return listBuilder(presentationNodeHash, depth);
    }
    return tabBuilder(presentationNodeHash, depth);
  }

  Widget tabBuilder(int presentationNodeHash, int depth) {
    return PresentationNodeTabsWidget(
      presentationNodeHash: presentationNodeHash,
      depth: depth,
      bodyBuilder: (int presentationNodeHash, depth) {
        return buildBody(context, presentationNodeHash, depth);
      },
    );
  }

  Widget listBuilder(int presentationNodeHash, int depth) {
    return PresentationNodeListWidget(
      presentationNodeHash: presentationNodeHash,
      depth: depth,
      itemBuilder: itemBuilder,
      tileBuilder: tileBuilder,
    );
  }

  Widget itemBuilder(CollectionListItem item) {
    switch (item.type) {
      case CollectionListItemType.presentationNode:
        return PresentationNodeItemWidget(
          hash: item.hash,
          depth: widget.depth,
          onPressed: onPresentationNodePressed,
        );

      case CollectionListItemType.nestedCollectible:
        return NestedCollectibleItemWidget(hash: item.hash);

      case CollectionListItemType.collectible:
        return CollectibleItemWidget(hash: item.hash);

      case CollectionListItemType.record:
        return RecordItemWidget(hash: item.hash);

      default:
        return Container(color: Colors.red);
    }
  }

  StaggeredTile tileBuilder(CollectionListItem item) {
    switch (item.type) {
      case CollectionListItemType.presentationNode:
        return StaggeredTile.count(30, 7);

      case CollectionListItemType.nestedCollectible:
        return StaggeredTile.count(6, 6);

      case CollectionListItemType.collectible:
        return StaggeredTile.count(30, 7);

      case CollectionListItemType.record:
        return StaggeredTile.extent(30, 150);

      default:
        return StaggeredTile.count(30, 7);
    }
  }

  void onPresentationNodePressed(int hash, int depth) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PresentationNodeBaseScreen(presentationNodeHash: hash, depth: depth+1,),
        ),
      );
  }
}
