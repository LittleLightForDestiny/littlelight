import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/collections/pages/collections.page_route.dart';
import 'package:little_light/modules/collections/widgets/category_breadcrumb.widget.dart';
import 'package:little_light/modules/collections/widgets/collectibles_list.widget.dart';

import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/destiny_settings.consumer.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/layouts/presentation_nodes_tabs_scaffold.dart';

class CollectionsBadgePage extends PresentationNodesTabsScaffoldWidget {
  CollectionsBadgePage() : super();

  @override
  createState() => CollectionsBadgePageState();
}

class CollectionsBadgePageState
    extends PresentationNodesTabsScaffoldState<CollectionsBadgePage>
    with DestinySettingsConsumer, ManifestConsumer {
  DestinyPresentationNodeDefinition? categoryDefinition;
  List<DestinyPresentationNodeDefinition>? nodesDefinitions;

  @override
  List<DestinyPresentationNodeDefinition>? get nodes => nodesDefinitions;

  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  asyncInit() async {
    await Future.delayed(Duration.zero);
    final route = ModalRoute.of(context);
    await Future.delayed(route?.transitionDuration ?? Duration.zero);
    loadNodes();
  }

  Future<void> loadNodes() async {
    await Future.delayed(Duration.zero);
    final args = CollectionsPageRouteArguments.of(context);
    final categoryNodeHash = args?.badgeCategoryHash;
    if (categoryNodeHash == null) return;
    final categoryDefinition = await manifest
        .getDefinition<DestinyPresentationNodeDefinition>(categoryNodeHash);
    final nodeHashes = categoryDefinition?.children?.presentationNodes
        ?.map((e) => e.presentationNodeHash);
    if (nodeHashes == null) return;
    final nodesDefinitions = await manifest
        .getDefinitions<DestinyPresentationNodeDefinition>(nodeHashes);
    setState(() {
      this.categoryDefinition = categoryDefinition;
      this.nodesDefinitions = nodesDefinitions.values.toList();
    });
  }

  @override
  Widget buildAppBarTitle(BuildContext context) {
    return Text(categoryDefinition?.displayProperties?.name ?? "");
  }

  @override
  Widget buildTabButton(
      BuildContext context, DestinyPresentationNodeDefinition node) {
    final iconName = node.displayProperties?.icon;
    if (iconName == null) return Container();
    return Container(
        padding: const EdgeInsets.all(8),
        width: 48,
        height: 48,
        child: QueuedNetworkImage.fromBungie(iconName));
  }

  @override
  PreferredSizeWidget? buildBreadcrumb(BuildContext context) {
    final nodeHashes =
        CollectionsPageRouteArguments.of(context)?.parentCategoryHashes;
    if (nodeHashes == null) return null;
    return CategoryBreadcrumbWidget(parentCategoryHashes: nodeHashes);
  }

  @override
  Widget buildTab(
      BuildContext context, DestinyPresentationNodeDefinition node) {
    return CollectibleListWidget(
      node: node,
      onItemTap: (collectibleHash) {},
    );
  }
}
