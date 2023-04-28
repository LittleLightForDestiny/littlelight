import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/collections/widgets/collectible_item.widget.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/views/base_presentation_node.view.dart';
import 'package:little_light/shared/widgets/presentation_nodes/presentation_node_item.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/widgets/multisection_scrollview/sliver_section.dart';

import 'collections_category.bloc.dart';

class CollectionsCategoryView extends BasePresentationNodeView {
  final CollectionsCategoryBloc bloc;
  final CollectionsCategoryBloc state;
  const CollectionsCategoryView(this.bloc, this.state, {Key? key}) : super(key: key);

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
    return MultiSectionScrollView(
      [
        SliverSection(
          itemsPerRow: MediaQueryHelper(context).responsiveValue(1, tablet: 2, desktop: 3),
          itemCount: node.children?.presentationNodes?.length ?? 0,
          itemHeight: 96,
          itemBuilder: (context, index) => buildItem(context, node.children?.presentationNodes?[index]),
        ),
        SliverSection(
          itemsPerRow: MediaQueryHelper(context).responsiveValue(1, tablet: 2, desktop: 3),
          itemCount: node.children?.collectibles?.length ?? 0,
          itemHeight: 96,
          itemBuilder: (context, index) => buildCollectibleItem(context, node.children?.collectibles?[index]),
        )
      ],
      padding: padding,
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
    );
  }

  Widget buildItem(BuildContext context, DestinyPresentationNodeChildEntry? presentationNode) {
    final presentationNodeHash = presentationNode?.presentationNodeHash;
    if (presentationNodeHash == null) return Container();
    return PresentationNodeItemWidget(
      presentationNodeHash,
      progress: state.getProgress(presentationNodeHash),
      characters: state.characters,
      onTap: () => bloc.openPresentationNode(presentationNodeHash),
    );
  }

  Widget buildCollectibleItem(BuildContext context, DestinyPresentationNodeCollectibleChildEntry? collectibleNode) {
    final collectibleHash = collectibleNode?.collectibleHash;
    if (collectibleHash == null) return Container();
    return CollectibleItemWidget(
      collectibleHash,
      // isUnlocked: state.isUnlocked(collectibleHash),
      // genericItem: state.getGenericItem(collectibleHash),
      // items: state.getInventoryItems(collectibleHash),
    );
  }
}
