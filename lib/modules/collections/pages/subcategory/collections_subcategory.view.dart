import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/collections/blocs/base_collections.bloc.dart';
import 'package:little_light/modules/collections/views/base_collections.view.dart';
import 'package:little_light/modules/collections/widgets/collectible_item.widget.dart';
import 'package:little_light/shared/widgets/presentation_nodes/presentation_node_item.widget.dart';
import 'package:little_light/shared/widgets/presentation_nodes/presentation_node_item_list.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class CollectionsSubcategoryView extends BaseCollectionsView {
  final CollectionsBloc bloc;
  final CollectionsBloc state;
  const CollectionsSubcategoryView(this.bloc, this.state, {Key? key}) : super(key: key);

  @override
  List<int>? get breadcrumbHashes => state.parentNodeHashes;

  @override
  List<DestinyPresentationNodeDefinition>? get tabNodes => bloc.tabNodes;

  @override
  String getTitle(BuildContext context) => state.rootNode?.displayProperties?.name ?? "";

  Widget? buildAppBarLeading(BuildContext context) => null;

  Widget buildTabButton(BuildContext context, DestinyPresentationNodeDefinition node) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(4),
      child: ManifestImageWidget<DestinyPresentationNodeDefinition>(node.hash),
    );
  }

  Widget buildTab(BuildContext context, DestinyPresentationNodeDefinition node, EdgeInsets padding) {
    return PresentationNodeListWidget(
      node.hash,
      collectibles: bloc.overrideCollectibles,
      padding: padding,
      presentationNodeBuilder: (context, entry) => PresentationNodeItemWidget(
        entry.presentationNodeHash,
        progress: state.getProgress(entry.presentationNodeHash),
        characters: state.characters,
        onTap: () => bloc.openPresentationNode(
          entry.presentationNodeHash,
          parentHashes: [node.hash].whereType<int>().toList(),
        ),
      ),
      collectibleBuilder: (context, entry) => CollectibleItemWidget(
        entry.collectibleHash,
        isUnlocked: state.isUnlocked(entry.collectibleHash),
        genericItem: state.getGenericItem(entry.collectibleHash),
        items: state.getInventoryItems(entry.collectibleHash),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.search),
        onPressed: () {
          final tab = DefaultTabController.of(context).index;
          final rootNodeHash = tabNodes?[tab].hash;
          if (rootNodeHash == null) return;
          bloc.openSearch(rootNodeHash);
        },
      ),
      ...(super.buildActions(context) ?? []),
    ];
  }
}
