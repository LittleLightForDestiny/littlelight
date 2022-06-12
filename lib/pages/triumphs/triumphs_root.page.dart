import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/pages/triumphs/lore.page_route.dart';
import 'package:little_light/pages/triumphs/triumphs.page_route.dart';
import 'package:little_light/pages/triumphs/widgets/seal_item.widget.dart';
import 'package:little_light/services/analytics/analytics.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/destiny_settings.consumer.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/services/profile/profile_component_groups.dart';
import 'package:little_light/services/user_settings/little_light_persistent_page.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/layouts/presentation_nodes_tabs_scaffold.dart';
import 'package:little_light/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/widgets/multisection_scrollview/sliver_section.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_item.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_list.widget.dart';

typedef OnPresentationNodeSelect = void Function(DestinyPresentationNodeChildEntry node);

class TriumphsRootPage extends PresentationNodesTabsScaffoldWidget {
  TriumphsRootPage() : super();

  @override
  createState() => TriumphsRootPageState();
}

const _page = LittleLightPersistentPage.Triumphs;

class TriumphsRootPageState extends PresentationNodesTabsScaffoldState<TriumphsRootPage>
    with UserSettingsConsumer, AnalyticsConsumer, ProfileConsumer, DestinySettingsConsumer, ManifestConsumer {
  List<DestinyPresentationNodeDefinition>? rootNodesDefinitions;

  @override
  List<DestinyPresentationNodeDefinition>? get nodes => rootNodesDefinitions;

  Map<int, DestinyPresentationNodeDefinition>? nodeDefinitions;

  int? loreNodeHash;

  @override
  void initState() {
    super.initState();

    profile.updateComponents = ProfileComponentGroups.triumphs;
    profile.fetchProfileData();
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

  @override
  List<Widget>? buildAppBarActions(BuildContext context) => [
        IconButton(
          enableFeedback: false,
          icon: Icon(Icons.search),
          onPressed: () {
            Navigator.of(context).push(TriumphsSearchPageRoute());
          },
        )
      ];

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

  Future<void> loadRootNodes() async {
    int? loreNodeHash = await getLoreNodeHash();
    this.loreNodeHash = loreNodeHash;

    final rootNodes = [
      destinySettings.triumphsRootNode,
      destinySettings.sealsRootNode,
      loreNodeHash,
    ];
    final subNodeHashes = [
      destinySettings.legacyTriumphsRootNode,
      destinySettings.legacySealsRootNode,
      destinySettings.loreRootNode,
      destinySettings.catalystsRootNode
    ];
    final definitions = await manifest.getDefinitions<DestinyPresentationNodeDefinition>(rootNodes + subNodeHashes);
    setState(() {
      nodeDefinitions = definitions;
      rootNodesDefinitions =
          rootNodes.map((h) => definitions[h]).whereType<DestinyPresentationNodeDefinition>().toList();
    });
  }

  @override
  Widget? buildAppBarLeading(BuildContext context) => Scaffold.of(context).hasDrawer
      ? IconButton(
          enableFeedback: false,
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        )
      : null;

  @override
  Widget buildAppBarTitle(BuildContext context) {
    return TranslatedTextWidget("Triumphs");
  }

  @override
  Widget buildTabButton(BuildContext context, DestinyPresentationNodeDefinition node) {
    return Container(padding: EdgeInsets.all(8), child: Text(node.displayProperties?.name ?? ""));
  }

  @override
  Widget buildTab(BuildContext context, DestinyPresentationNodeDefinition node) {
    final activeHash = destinySettings.triumphsRootNode;
    final sealsHash = destinySettings.sealsRootNode;
    if (node.hash == activeHash) {
      return buildTriumphCategories(context);
    }
    if (node.hash == sealsHash) {
      return buildSealCategories(context);
    }
    if (node.hash == loreNodeHash) {
      return PresentationNodeListWidget(
        node: node,
        onItemTap: (hash) {
          onLoreCategorySelect(context, hash);
        },
      );
    }

    return PresentationNodeListWidget(node: node);
  }

  Widget buildTriumphCategories(BuildContext context) {
    final triumphsHash = destinySettings.triumphsRootNode;
    final legacy = destinySettings.legacyTriumphsRootNode;
    final catalystsHash = destinySettings.catalystsRootNode;
    return MultiSectionScrollView(
      [
        if (triumphsHash != null)
          buildCategoryList(
              triumphsHash,
              (node) => onTriumphSelect(
                    node,
                    pathHashes: [triumphsHash, node.presentationNodeHash],
                  )),
        if (triumphsHash != null) buildSpacer(),
        if (catalystsHash != null) buildCategoryTitle(catalystsHash),
        if (catalystsHash != null)
          buildCategoryList(
              catalystsHash,
              (node) => onTriumphSelect(
                    node,
                    pathHashes: [catalystsHash, node.presentationNodeHash],
                  )),
        if (catalystsHash != null) buildSpacer(),
        if (legacy != null) buildCategoryTitle(legacy),
        if (legacy != null)
          buildCategoryList(
              legacy,
              (node) => onTriumphSelect(
                    node,
                    pathHashes: [legacy, node.presentationNodeHash],
                  )),
      ],
      padding: EdgeInsets.all(4) + MediaQuery.of(context).viewPadding.copyWith(top: 0),
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
    );
  }

  void onTriumphSelect(DestinyPresentationNodeChildEntry node, {List<int?>? pathHashes}) async {
    Navigator.of(context).push(
      TriumphsPageRoute(
          categoryPresentationNodeHash: node.presentationNodeHash,
          parentCategoryHashes: pathHashes?.whereType<int>().toList()),
    );
  }

  void onLoreCategorySelect(BuildContext context, int hash) {
    Navigator.of(context).push(
      LorePageRoute(
          categoryPresentationNodeHash: hash,
          parentCategoryHashes: [
            destinySettings.triumphsRootNode,
            loreNodeHash,
          ].whereType<int>().toList()),
    );
  }

  Widget buildSealCategories(BuildContext context) {
    final sealsHash = destinySettings.sealsRootNode;
    final legacySealsHash = destinySettings.legacySealsRootNode;
    return MultiSectionScrollView(
      [
        if (sealsHash != null)
          buildSealCategoryList(
              sealsHash,
              (node) => onTriumphSelect(
                    node,
                    pathHashes: [sealsHash, node.presentationNodeHash],
                  )),
        if (sealsHash != null) buildSpacer(),
        if (legacySealsHash != null) buildCategoryTitle(legacySealsHash),
        if (legacySealsHash != null)
          buildSealCategoryList(
              legacySealsHash,
              (node) => onTriumphSelect(
                    node,
                    pathHashes: [legacySealsHash, node.presentationNodeHash],
                  ))
      ],
      padding: EdgeInsets.all(4) + MediaQuery.of(context).viewPadding.copyWith(top: 0),
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
    );
  }

  void onSealSelect(DestinyPresentationNodeChildEntry node, {List<int>? pathHashes}) {
    Navigator.of(context).push(
      TriumphsPageRoute(
          categoryPresentationNodeHash: node.presentationNodeHash,
          parentCategoryHashes: pathHashes?.whereType<int>().toList()),
    );
  }

  SliverSection buildSpacer() {
    return SliverSection(
      itemsPerRow: 1,
      itemCount: 1,
      itemHeight: 80,
      itemBuilder: (context, index) => Container(),
    );
  }

  SliverSection buildCategoryTitle(int categoryHash) {
    return SliverSection(
      itemsPerRow: 1,
      itemCount: 1,
      itemHeight: 40,
      itemBuilder: (context, index) =>
          HeaderWidget(child: ManifestText<DestinyPresentationNodeDefinition>(categoryHash)),
    );
  }

  SliverSection buildCategoryList(int categoryHash, OnPresentationNodeSelect? onSelect) {
    final node = nodeDefinitions?[categoryHash];
    final children = node?.children?.presentationNodes?.whereType<DestinyPresentationNodeChildEntry>().toList();
    if (children == null) return SliverSection(itemCount: 0, itemBuilder: (context, index) => Container());
    return SliverSection(
      itemsPerRow: MediaQueryHelper(context).responsiveValue(1, tablet: 2, desktop: 3),
      itemCount: children.length,
      itemHeight: 80,
      itemBuilder: (context, index) {
        final childNode = children[index];
        return buildPresentationNode(context, childNode, onSelect: onSelect);
      },
    );
  }

  SliverSection buildSealCategoryList(int categoryHash, OnPresentationNodeSelect? onSelect) {
    final node = nodeDefinitions?[categoryHash];
    final children = node?.children?.presentationNodes?.whereType<DestinyPresentationNodeChildEntry>().toList();
    if (children == null) return SliverSection(itemCount: 0, itemBuilder: (context, index) => Container());
    return SliverSection(
      itemsPerRow: MediaQueryHelper(context).responsiveValue(1, tablet: 2, desktop: 3),
      itemCount: children.length,
      itemHeight: 92,
      itemBuilder: (context, index) {
        final childNode = children[index];
        return buildSealNodeItem(context, childNode, onSelect: onSelect);
      },
    );
  }

  Widget buildPresentationNode(BuildContext context, DestinyPresentationNodeChildEntry node,
      {OnPresentationNodeSelect? onSelect}) {
    return PresentationNodeItemWidget(
        hash: node.presentationNodeHash,
        onPressed: () {
          onSelect?.call(node);
        });
  }

  Widget buildSealNodeItem(BuildContext context, DestinyPresentationNodeChildEntry node,
      {OnPresentationNodeSelect? onSelect}) {
    return SealItemWidget(
        hash: node.presentationNodeHash,
        onPressed: () {
          onSelect?.call(node);
        });
  }
}
