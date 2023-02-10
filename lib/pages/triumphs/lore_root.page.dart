import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/collections/widgets/category_breadcrumb.widget.dart';

import 'package:little_light/pages/triumphs/lore.page_route.dart';
import 'package:little_light/pages/triumphs/widgets/triumph_list.widget.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_list.widget.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/destiny_settings.consumer.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/layouts/presentation_nodes_tabs_scaffold.dart';

import 'triumphs.page_route.dart';

class LoreRootPage extends PresentationNodesTabsScaffoldWidget {
  LoreRootPage() : super();

  @override
  createState() => LoreRootPageState();
}

class LoreRootPageState extends PresentationNodesTabsScaffoldState<LoreRootPage>
    with DestinySettingsConsumer, ManifestConsumer {
  DestinyPresentationNodeDefinition? rootNode;
  List<DestinyPresentationNodeDefinition>? nodesDefinitions;
  int? initialIndex;

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
    await loadNodes();
  }

  Future<int?> getLoreNodeHash() async {
    int? loreNodeHash = destinySettings.loreRootNode;
    if (loreNodeHash == null) return null;
    final loreNodeDef = await manifest.getDefinition<DestinyPresentationNodeDefinition>(loreNodeHash);
    final loreFirstChildHash = loreNodeDef?.children?.presentationNodes?.first.presentationNodeHash;
    final loreFirstChildDef = await manifest.getDefinition<DestinyPresentationNodeDefinition>(loreFirstChildHash);
    final loreNodeName = loreNodeDef?.displayProperties?.name;
    final loreFirstChildName = loreFirstChildDef?.displayProperties?.name;
    if (loreNodeName == loreFirstChildName) return loreFirstChildHash;
    return loreNodeHash;
  }

  Future<void> loadNodes() async {
    await Future.delayed(Duration.zero);
    final rootNode = await getLoreNodeHash();
    final rootCategoryDefinition = await manifest.getDefinition<DestinyPresentationNodeDefinition>(rootNode);
    final nodeHashes = rootCategoryDefinition?.children?.presentationNodes?.map((e) => e.presentationNodeHash).toList();
    if (nodeHashes == null) return;
    final categoryHash = LorePageRouteArguments.of(context)?.categoryPresentationNodeHash;
    initialIndex = nodeHashes.indexOf(categoryHash);
    final nodesDefinitions = await manifest.getDefinitions<DestinyPresentationNodeDefinition>(nodeHashes);
    setState(() {
      this.rootNode = rootCategoryDefinition;
      this.nodesDefinitions =
          nodeHashes.map((h) => nodesDefinitions[h]).whereType<DestinyPresentationNodeDefinition>().toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabCount = nodes?.length;
    if (tabCount == null) {
      return buildScaffold(context);
    }
    return DefaultTabController(
      initialIndex: initialIndex ?? 0,
      length: tabCount,
      child: buildScaffold(context),
    );
  }

  @override
  PreferredSizeWidget? buildTabBar(BuildContext context) {
    if ((nodesDefinitions?.length ?? 0) == 0) return null;
    return super.buildTabBar(context);
  }

  @override
  Widget buildAppBarTitle(BuildContext context) {
    return Text(rootNode?.displayProperties?.name ?? "");
  }

  @override
  Widget buildTabButton(BuildContext context, DestinyPresentationNodeDefinition node) {
    final iconName = node.displayProperties?.icon;
    if (iconName == null) return Container();
    return Container(padding: const EdgeInsets.all(8), width: 48, height: 48, child: QueuedNetworkImage.fromBungie(iconName));
  }

  @override
  PreferredSizeWidget? buildBreadcrumb(BuildContext context) {
    final nodeHashes = LorePageRouteArguments.of(context)?.parentCategoryHashes;
    if (nodeHashes == null) return null;
    return CategoryBreadcrumbWidget(parentCategoryHashes: nodeHashes);
  }

  @override
  Widget buildBody(BuildContext context) {
    if ((nodesDefinitions?.length ?? 0) == 0) {
      return buildTablessBody(context);
    }
    return super.buildBody(context);
  }

  Widget buildTablessBody(BuildContext context) {
    final categoryDefinition = rootNode;
    if (categoryDefinition == null) return LoadingAnimWidget();
    return TriumphListWidget(node: categoryDefinition);
  }

  @override
  Widget buildTab(BuildContext context, DestinyPresentationNodeDefinition node) {
    final parentNodeHashes = TriumphsPageRouteArguments.of(context)?.parentCategoryHashes ?? [];
    return PresentationNodeListWidget(
      node: node,
      onItemTap: (nodeHash) {
        Navigator.of(context).push(TriumphsPageRoute(
            parentCategoryHashes: parentNodeHashes + [node.hash!, nodeHash], categoryPresentationNodeHash: nodeHash));
      },
    );
  }
}
