import 'package:bungie_api/enums/destiny_presentation_screen_style.dart';
import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/collections/pages/collections.page_route.dart';
import 'package:little_light/modules/collections/widgets/category_breadcrumb.widget.dart';
import 'package:little_light/modules/collections/widgets/category_sets_list.widget.dart';
import 'package:little_light/modules/collections/widgets/collectibles_list.widget.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/destiny_settings.consumer.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/layouts/presentation_nodes_tabs_scaffold.dart';

class CollectionsSubcategoryPage extends PresentationNodesTabsScaffoldWidget {
  CollectionsSubcategoryPage() : super();

  @override
  createState() => CollectionsSubcategoryPageState();
}

class CollectionsSubcategoryPageState extends PresentationNodesTabsScaffoldState<CollectionsSubcategoryPage>
    with DestinySettingsConsumer, ManifestConsumer {
  DestinyPresentationNodeDefinition? categoryDefinition;
  List<DestinyPresentationNodeDefinition>? nodesDefinitions;
  bool isCategorySets = false;

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
    final route = ModalRoute.of(context);
    await Future.delayed(route?.transitionDuration ?? Duration.zero);
    final args = CollectionsPageRouteArguments.of(context);
    final categoryNodeHash = args?.subcategoryPresentationNodeHash;
    final parentNodesDefs =
        await manifest.getDefinitions<DestinyPresentationNodeDefinition>(args?.parentCategoryHashes ?? []);
    isCategorySets =
        parentNodesDefs.values.any((element) => element.screenStyle == DestinyPresentationScreenStyle.CategorySets);
    if (categoryNodeHash == null) return;
    final categoryDefinition = await manifest.getDefinition<DestinyPresentationNodeDefinition>(categoryNodeHash);
    setState(() {
      this.categoryDefinition = categoryDefinition;
    });
  }

  @override
  Widget buildAppBarTitle(BuildContext context) {
    return Text(categoryDefinition?.displayProperties?.name ?? "");
  }

  @override
  Widget buildBody(BuildContext context) {
    final categoryDefinition = this.categoryDefinition;
    if (categoryDefinition == null) return LoadingAnimWidget();
    if (isCategorySets) return CategorySetsListWidget(node: categoryDefinition);
    return CollectibleListWidget(
      node: categoryDefinition,
      onItemTap: (collectibleHash) {},
    );
  }

  @override
  PreferredSizeWidget? buildBreadcrumb(BuildContext context) {
    final nodeHashes = CollectionsPageRouteArguments.of(context)?.parentCategoryHashes;
    if (nodeHashes == null) return null;
    return CategoryBreadcrumbWidget(parentCategoryHashes: nodeHashes);
  }

  @override
  PreferredSizeWidget? buildAppBarBottom(BuildContext context) => buildBreadcrumb(context);

  @override
  Widget buildTab(BuildContext context, DestinyPresentationNodeDefinition node) {
    throw UnimplementedError();
  }

  @override
  Widget buildTabButton(BuildContext context, DestinyPresentationNodeDefinition node) {
    throw UnimplementedError();
  }
}
