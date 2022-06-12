import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';

abstract class PresentationNodesTabsScaffoldWidget extends StatefulWidget {
  @override
  PresentationNodesTabsScaffoldState createState();
}

abstract class PresentationNodesTabsScaffoldState<T extends PresentationNodesTabsScaffoldWidget> extends State<T> {
  List<DestinyPresentationNodeDefinition>? get nodes;

  @override
  Widget build(BuildContext context) {
    final tabCount = nodes?.length;
    if (tabCount == null) {
      return buildScaffold(context);
    }
    return DefaultTabController(
      length: tabCount,
      child: buildScaffold(context),
    );
  }

  Widget buildScaffold(BuildContext context) => Scaffold(
        appBar: buildAppBar(context),
        body: buildBody(context),
      );

  PreferredSizeWidget buildAppBar(BuildContext context) => AppBar(
        elevation: 4,
        leading: buildAppBarLeading(context),
        actions: buildAppBarActions(context),
        title: buildAppBarTitle(context),
        bottom: buildAppBarBottom(context),
      );

  Widget? buildAppBarLeading(BuildContext context) => null;
  List<Widget>? buildAppBarActions(BuildContext context) => null;
  Widget buildAppBarTitle(BuildContext context);

  PreferredSizeWidget? buildAppBarBottom(BuildContext context) {
    final tabBar = buildTabBar(context);
    final breadcrumb = buildBreadcrumb(context);
    if (tabBar == null && breadcrumb == null) return null;
    if (breadcrumb == null) {
      return tabBar;
    }
    if (tabBar == null) {
      return breadcrumb;
    }
    return PreferredSize(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            tabBar,
            breadcrumb,
          ],
        ),
        preferredSize: Size.fromHeight(tabBar.preferredSize.height + breadcrumb.preferredSize.height));
  }

  PreferredSizeWidget? buildTabBar(BuildContext context) {
    final nodes = this.nodes;
    if (nodes == null) return null;
    final tabBar = TabBar(
        labelPadding: EdgeInsets.all(0),
        indicatorColor: Theme.of(context).colorScheme.onSurface,
        isScrollable: false,
        tabs: nodes.map((n) => buildTabButton(context, n)).toList());
    return PreferredSize(
        child: Material(
          child: tabBar,
          color: LittleLightTheme.of(context).surfaceLayers.layer1,
          elevation: 2,
        ),
        preferredSize: tabBar.preferredSize);
  }

  PreferredSizeWidget? buildBreadcrumb(BuildContext context) => null;
  Widget buildTabButton(BuildContext context, DestinyPresentationNodeDefinition node);

  Widget buildBody(BuildContext context) {
    final nodes = this.nodes;
    if (nodes == null) return LoadingAnimWidget();
    return TabBarView(
      children: nodes.map((node) => buildTab(context, node)).toList(),
    );
  }

  Widget buildTab(BuildContext context, DestinyPresentationNodeDefinition node);
}
