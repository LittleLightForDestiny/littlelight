import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/core/blocs/profile/profile_component_groups.dart';
import 'package:little_light/modules/collections/pages/collections.page_route.dart';
import 'package:little_light/services/analytics/analytics.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/destiny_settings.consumer.dart';
import 'package:little_light/services/user_settings/little_light_persistent_page.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/widgets/layouts/presentation_nodes_tabs_scaffold.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_list.widget.dart';

class CollectionsRootPage extends PresentationNodesTabsScaffoldWidget {
  CollectionsRootPage() : super();

  @override
  createState() => CollectionsRootPageState();
}

const _page = LittleLightPersistentPage.Collections;

class CollectionsRootPageState extends PresentationNodesTabsScaffoldState<CollectionsRootPage>
    with UserSettingsConsumer, AnalyticsConsumer, ProfileConsumer, DestinySettingsConsumer, ManifestConsumer {
  List<DestinyPresentationNodeDefinition>? rootNodesDefinitions;

  @override
  List<DestinyPresentationNodeDefinition>? get nodes => rootNodesDefinitions;

  @override
  void initState() {
    super.initState();

    profile.includeComponentsInNextRefresh(ProfileComponentGroups.collections);
    profile.refresh();
    userSettings.startingPage = _page;
    analytics.registerPageOpen(_page);

    asyncInit();
  }

  asyncInit() async {
    await Future.delayed(Duration.zero);
    final route = ModalRoute.of(context);
    await Future.delayed(route?.transitionDuration ?? Duration.zero);
    loadRootNodes();
  }

  Future<void> loadRootNodes() async {
    final rootNodes = [
      destinySettings.collectionsRootNode,
      destinySettings.badgesRootNode,
    ];
    final definitions = await manifest.getDefinitions<DestinyPresentationNodeDefinition>(rootNodes);
    setState(() {
      rootNodesDefinitions =
          rootNodes.map((h) => definitions[h]).whereType<DestinyPresentationNodeDefinition>().toList();
    });
  }

  @override
  Widget? buildAppBarLeading(BuildContext context) => IconButton(
        enableFeedback: false,
        icon: const Icon(Icons.menu),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      );

  @override
  List<Widget>? buildAppBarActions(BuildContext context) => [
        IconButton(
          enableFeedback: false,
          icon: const Icon(Icons.search),
          onPressed: () {
            Navigator.of(context).push(CollectionsSearchPageRoute());
          },
        )
      ];

  @override
  Widget buildAppBarTitle(BuildContext context) {
    return Text("Collections".translate(context));
  }

  @override
  Widget buildTabButton(BuildContext context, DestinyPresentationNodeDefinition node) {
    return Container(padding: const EdgeInsets.all(8), child: Text(node.displayProperties?.name ?? ""));
  }

  @override
  Widget buildTab(BuildContext context, DestinyPresentationNodeDefinition node) {
    return PresentationNodeListWidget(
      node: node,
      onItemTap: (nodeHash) async {
        final categoryDef = await manifest.getDefinition<DestinyPresentationNodeDefinition>(nodeHash);
        if (categoryDef?.displayStyle == DestinyPresentationDisplayStyle.Badge) {
          Navigator.of(context)
              .push(CollectionsPageRoute(parentCategoryHashes: [node.hash!, nodeHash], badgeCategoryHash: nodeHash));
          return;
        }
        Navigator.of(context).push(
            CollectionsPageRoute(parentCategoryHashes: [node.hash!, nodeHash], categoryPresentationNodeHash: nodeHash));
      },
    );
  }
}
