import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/presentation_nodes/collectible_item.widget.dart';
import 'package:little_light/widgets/presentation_nodes/nested_collectible_item.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_item.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_list.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_tabs.widget.dart';
import 'package:little_light/widgets/presentation_nodes/record_item.widget.dart';

class PresentationNodeBaseScreen extends StatefulWidget {
  final ManifestService manifest = new ManifestService();
  final ProfileService profile = new ProfileService();
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
    if (definition == null && widget.presentationNodeHash != null) {
      loadDefinition();
    }
  }

  loadDefinition() async {
    definition = await widget.manifest
        .getDefinition<DestinyPresentationNodeDefinition>(
            widget.presentationNodeHash);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(definition.displayProperties.name)),
        body: buildBody(context,
            hash: widget.presentationNodeHash, depth: widget.depth));
  }

  Widget buildBody(BuildContext context, {int hash, int depth}) {
    if (depth == 1 || depth > 3 || definition?.nodeType == 2) {
      return listBuilder(hash, depth);
    }
    return tabBuilder(hash, depth);
  }

  Widget tabBuilder(int presentationNodeHash, int depth) {
    return PresentationNodeTabsWidget(
      presentationNodeHash: presentationNodeHash,
      depth: depth,
      bodyBuilder: (int presentationNodeHash, depth) {
        return buildBody(context, hash: presentationNodeHash, depth: depth);
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

  Widget itemBuilder(CollectionListItem item, int depth) {
    switch (item.type) {
      case CollectionListItemType.presentationNode:
        return PresentationNodeItemWidget(
          hash: item.hash,
          depth: depth,
          onPressed: onPresentationNodePressed,
        );

      case CollectionListItemType.nestedCollectible:
        return NestedCollectibleItemWidget(hash: item.hash);

      case CollectionListItemType.collectible:
        return CollectibleItemWidget(hash: item.hash);

      case CollectionListItemType.record:
        return RecordItemWidget(
          hash: item.hash,
          key: Key("record_${item.hash}"),
        );

      default:
        return Container(color: Colors.red);
    }
  }

  StaggeredTile tileBuilder(CollectionListItem item) {
    switch (item.type) {
      case CollectionListItemType.presentationNode:
        return StaggeredTile.extent(30, 92);

      case CollectionListItemType.nestedCollectible:
        if (MediaQueryHelper(context).tabletOrBigger) {
          return StaggeredTile.count(3, 3);
        }
        return StaggeredTile.count(6, 6);

      case CollectionListItemType.collectible:
        if (MediaQueryHelper(context).tabletOrBigger) {
          return StaggeredTile.extent(10, 96);
        }
        return StaggeredTile.extent(30, 96);

      case CollectionListItemType.record:
        if (MediaQueryHelper(context).tabletOrBigger) {
          return StaggeredTile.fit(10);
        }
        return StaggeredTile.fit(30);

      default:
        return StaggeredTile.count(30, 7);
    }
  }

  void onPresentationNodePressed(int hash, int depth) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PresentationNodeBaseScreen(
          presentationNodeHash: hash,
          depth: depth + 1,
        ),
      ),
    );
  }
}
