import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/presentation_nodes/category_breadcrumb.widget.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_bottom_gradient.widget.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_line.widget.dart';
import 'package:little_light/shared/widgets/notifications/notifications.widget.dart';
import 'package:little_light/shared/widgets/selection/selected_items.widget.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:provider/provider.dart';

abstract class BasePresentationNodeView extends StatelessWidget {
  const BasePresentationNodeView({Key? key}) : super(key: key);

  List<DestinyPresentationNodeDefinition>? get tabNodes;
  String getTitle(BuildContext context);

  int getInitialIndex(context) => 0;

  @override
  Widget build(BuildContext context) {
    final hasFooter = context.watch<SelectionBloc>().hasSelection;
    return DefaultTabController(
      initialIndex: getInitialIndex(context),
      length: tabNodes?.length ?? 1,
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            centerTitle: false,
            leading: buildAppBarLeading(context),
            title: Text(getTitle(context)),
            bottom: buildAppBarBottom(context),
          ),
          body: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    buildBody(context, hasFooter: hasFooter),
                    Positioned(
                      child: buildNotifications(context, hasFooter: hasFooter),
                      bottom: 0,
                      left: 0,
                      right: 0,
                    ),
                  ],
                ),
              ),
              buildSelection(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget? buildAppBarLeading(BuildContext context);

  PreferredSizeWidget? buildAppBarBottom(BuildContext context) {
    final tabBar = buildTabBar(context);
    final breadcrumb = buildBreadcrumbs(context);
    if (tabBar != null && breadcrumb != null) {
      return PreferredSize(
        preferredSize: Size.fromHeight(tabBar.preferredSize.height + breadcrumb.preferredSize.height),
        child: Column(children: [tabBar, breadcrumb]),
      );
    }
    if (tabBar != null) return tabBar;
    if (breadcrumb != null) return breadcrumb;
    return null;
  }

  List<int>? get breadcrumbHashes;

  PreferredSizeWidget? buildBreadcrumbs(BuildContext context) {
    final breadcrumbHashes = this.breadcrumbHashes;
    if (breadcrumbHashes == null) return null;
    final tabController = DefaultTabController.of(context);
    return PreferredSize(
        child: AnimatedBuilder(
            animation: tabController,
            builder: (context, _) {
              final current = tabController.index;
              List<int> hashes = [...breadcrumbHashes];
              final nodesLength = tabNodes?.length ?? 0;
              if (nodesLength > current) {
                final hash = tabNodes?[current].hash;
                hashes = [...hashes, if (hash != null) hash];
              }
              return CategoryBreadcrumbWidget(categoryHashes: hashes);
            }),
        preferredSize: Size.fromHeight(32.0));
  }

  PreferredSizeWidget? buildTabBar(BuildContext context) {
    final nodes = tabNodes;
    if (nodes == null || nodes.length <= 1) return null;
    final tabBar = TabBar(
        labelPadding: const EdgeInsets.all(0),
        indicatorColor: context.theme.onSurfaceLayers,
        isScrollable: false,
        tabs: nodes.map((n) => buildTabButton(context, n)).toList());
    return PreferredSize(
        preferredSize: tabBar.preferredSize,
        child: Material(
          color: context.theme.secondarySurfaceLayers.layer1,
          elevation: 2,
          child: Container(height: tabBar.preferredSize.height, child: tabBar),
        ));
  }

  Widget buildTabButton(BuildContext context, DestinyPresentationNodeDefinition node) {
    return Container(
      alignment: Alignment.center,
      child: Text(node.displayProperties?.name ?? ""),
    );
  }

  Widget buildBody(BuildContext context, {bool hasFooter = false}) {
    final mq = context.mediaQuery;
    final nodes = tabNodes;
    if (nodes == null) return LoadingAnimWidget();
    return TabBarView(
      children: nodes
          .map((node) => buildTab(
                context,
                node,
                const EdgeInsets.all(4).copyWith(bottom: 64.0) +
                    EdgeInsets.only(bottom: hasFooter ? 0 : mq.viewPadding.bottom),
              ))
          .toList(),
    );
  }

  Widget buildTab(BuildContext context, DestinyPresentationNodeDefinition node, EdgeInsets padding);

  Widget buildNotifications(BuildContext context, {bool hasFooter = false}) {
    final bottomPadding = context.mediaQuery.viewPadding.bottom;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          child: NotificationsWidget(),
        ),
        bottomPadding > 0 && !hasFooter ? BusyIndicatorBottomGradientWidget() : BusyIndicatorLineWidget(),
      ],
    );
  }

  Widget buildSelection(BuildContext context) {
    final hasSelection = context.watch<SelectionBloc>().hasSelection;
    final bottomPadding = context.mediaQuery.viewPadding.bottom;
    if (!hasSelection) return Container();
    return Column(children: [
      SelectedItemsWidget(),
      if (bottomPadding > 0) BusyIndicatorBottomGradientWidget(),
    ]);
  }
}
