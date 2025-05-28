import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/loadouts/pages/home/destiny_loadouts.bloc.dart';
import 'package:little_light/modules/loadouts/pages/home/destiny_loadouts.view.dart';
import 'package:little_light/modules/loadouts/pages/home/little_light_loadouts.view.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_bottom_gradient.widget.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_line.widget.dart';
import 'package:little_light/shared/widgets/notifications/notifications.widget.dart';

import 'little_light_loadouts.bloc.dart';

class LoadoutsHomeView extends StatelessWidget {
  final LittleLightLoadoutsBloc littleLightLoadoutsBloc;
  final LittleLightLoadoutsBloc littlelightLoadoutsState;
  final DestinyLoadoutsBloc destinyLoadoutsBloc;
  final DestinyLoadoutsBloc destinyLoadoutsState;
  const LoadoutsHomeView({
    required this.littleLightLoadoutsBloc,
    required this.littlelightLoadoutsState,
    required this.destinyLoadoutsBloc,
    required this.destinyLoadoutsState,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder:
            (context) => Scaffold(
              appBar: buildAppBar(context),
              body: Column(
                children:
                    [
                      Expanded(
                        child: Stack(
                          children: [
                            buildTabs(context),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              left: 0,
                              child: renderOnlyOnLittleLightLoadouts(context, buildNotificationWidget(context)),
                            ),
                          ],
                        ),
                      ),
                      renderOnlyOnLittleLightLoadouts(context, buildFooter(context)),
                    ].whereType<Widget>().toList(),
              ),
            ),
      ),
    );
  }

  Widget buildNotificationWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [Container(padding: EdgeInsets.all(8), child: NotificationsWidget()), BusyIndicatorLineWidget()],
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      actions:
          [
            renderOnlyOnLittleLightLoadouts(context, buildReorderButton(context)),
            renderOnlyOnLittleLightLoadouts(context, buildSearchButton(context)),
            renderOnlyOnLittleLightLoadouts(
              context,
              IconButton(
                icon: const Icon(FontAwesomeIcons.download),
                onPressed: () => littleLightLoadoutsBloc.reloadLoadouts(),
              ),
            ),
          ].whereType<Widget>().toList(),
      bottom: buildTabBar(context),
      title: buildTitle(context),
    );
  }

  PreferredSizeWidget buildTabBar(BuildContext context) {
    final tabbar = TabBar(
      tabs: [
        Container(alignment: Alignment.center, child: Text("Little Light".translate(context))),
        Container(alignment: Alignment.center, child: Text("Destiny".translate(context))),
      ],
    );
    return PreferredSize(
      preferredSize: tabbar.preferredSize,
      child: Material(
        color: context.theme.secondarySurfaceLayers.layer1,
        elevation: 2,
        child: LayoutBuilder(
          builder:
              (context, constraints) => Container(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                height: tabbar.preferredSize.height,
                child: tabbar,
              ),
        ),
      ),
    );
  }

  Widget buildTitle(BuildContext context) {
    if (littlelightLoadoutsState.searchOpen) {
      return TextFormField(
        decoration: const InputDecoration(isDense: true),
        autofocus: true,
        onChanged: (value) => littleLightLoadoutsBloc.searchString = value,
      );
    }
    return littlelightLoadoutsState.reordering
        ? Text("Reordering Loadouts".translate(context))
        : Text("Loadouts".translate(context));
  }

  Widget buildSearchButton(BuildContext context) {
    if (littlelightLoadoutsState.reordering) return Container();
    return IconButton(
      enableFeedback: false,
      icon:
          littlelightLoadoutsState.searchOpen
              ? const Icon(FontAwesomeIcons.xmark)
              : const Icon(FontAwesomeIcons.magnifyingGlass),
      onPressed: () => littleLightLoadoutsBloc.toggleSearch(),
    );
  }

  Widget buildReorderButton(BuildContext context) {
    if (littlelightLoadoutsState.searchOpen) return Container();
    return IconButton(
      enableFeedback: false,
      icon:
          littlelightLoadoutsState.reordering
              ? const Icon(FontAwesomeIcons.check)
              : Transform.rotate(angle: pi / 2, child: const Icon(FontAwesomeIcons.rightLeft)),
      onPressed: () => littleLightLoadoutsBloc.toggleReordering(),
    );
  }

  Widget renderOnlyOnLittleLightLoadouts(BuildContext context, Widget? widget) {
    final tab = DefaultTabController.maybeOf(context);
    if (tab == null) return Container();

    final tabAnimation = tab.animation;
    if (tabAnimation == null) return Container();

    if (widget == null) return Container();

    return AnimatedBuilder(
      animation: tabAnimation,
      builder: (context, _) {
        if (tab.index > 0) return Container();
        return widget;
      },
    );
  }

  Widget? buildFooter(BuildContext context) {
    if (littlelightLoadoutsState.isEmpty) {
      return null;
    }
    double paddingBottom = context.mediaQuery.padding.bottom;
    return Material(
      elevation: 1,
      color: context.theme.secondarySurfaceLayers,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            height: kToolbarHeight,
            child: ElevatedButton(
              onPressed: littleLightLoadoutsBloc.createNew,
              child: Text("Create Loadout".translate(context)),
            ),
          ),
          if (paddingBottom > 0) BusyIndicatorBottomGradientWidget(),
        ],
      ),
    );
  }

  Widget buildTabs(BuildContext context) {
    return TabBarView(
      children: [
        LittleLightLoadoutsView(bloc: littleLightLoadoutsBloc, state: littlelightLoadoutsState),
        DestinyLoadoutsView(bloc: destinyLoadoutsBloc, state: destinyLoadoutsState),
      ],
    );
  }
}
