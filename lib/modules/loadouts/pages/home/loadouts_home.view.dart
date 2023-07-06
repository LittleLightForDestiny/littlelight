import 'dart:math';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/loadouts/widgets/loadout_list_item.widget.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sections/intrinsic_height_scrollable_section.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_bottom_gradient.widget.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_line.widget.dart';
import 'package:little_light/shared/widgets/notifications/notifications.widget.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'loadouts_home.bloc.dart';

class LoadoutsHomeView extends StatelessWidget {
  final LoadoutsHomeBloc bloc;
  final LoadoutsHomeBloc state;
  const LoadoutsHomeView(
    this.bloc,
    this.state, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                state.reordering ? buildReorderingBody(context) : buildBody(context),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        child: NotificationsWidget(),
                      ),
                      BusyIndicatorLineWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          buildFooter(context),
        ].whereType<Widget>().toList(),
      ),
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
        actions: <Widget>[
          buildReorderButton(context),
          buildSearchButton(context),
          IconButton(
            icon: const Icon(FontAwesomeIcons.download),
            onPressed: () => bloc.reloadLoadouts(),
          )
        ],
        title: buildTitle(context));
  }

  Widget buildTitle(BuildContext context) {
    if (state.searchOpen) {
      return TextFormField(
        decoration: const InputDecoration(isDense: true),
        autofocus: true,
        onChanged: (value) => bloc.searchString = value,
      );
    }
    return state.reordering
        ? Text(
            "Reordering Loadouts".translate(context),
          )
        : Text(
            "Loadouts".translate(context),
          );
  }

  Widget buildSearchButton(BuildContext context) {
    if (state.reordering) return Container();
    return IconButton(
      enableFeedback: false,
      icon: state.searchOpen ? const Icon(FontAwesomeIcons.xmark) : const Icon(FontAwesomeIcons.magnifyingGlass),
      onPressed: () => bloc.toggleSearch(),
    );
  }

  Widget buildReorderButton(BuildContext context) {
    if (state.searchOpen) return Container();
    return IconButton(
        enableFeedback: false,
        icon: state.reordering
            ? const Icon(FontAwesomeIcons.check)
            : Transform.rotate(angle: pi / 2, child: const Icon(FontAwesomeIcons.rightLeft)),
        onPressed: () => bloc.toggleReordering());
  }

  Widget? buildFooter(BuildContext context) {
    if (state.isEmpty) {
      return null;
    }
    double paddingBottom = context.mediaQuery.padding.bottom;
    return Material(
      elevation: 1,
      color: context.theme.secondarySurfaceLayers,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: EdgeInsets.all(8),
          height: kToolbarHeight,
          child: ElevatedButton(
            onPressed: bloc.createNew,
            child: Text("Create Loadout".translate(context)),
          ),
        ),
        if (paddingBottom > 0) BusyIndicatorBottomGradientWidget(),
      ]),
    );
  }

  Widget buildReorderingBody(BuildContext context) {
    var screenPadding = MediaQuery.of(context).padding;

    return ReorderableList(
        itemCount: state.loadouts?.length ?? 0,
        itemBuilder: (context, index) {
          return buildSortItem(context, index);
        },
        itemExtent: 56,
        padding: const EdgeInsets.all(8).copyWith(left: max(screenPadding.left, 8), right: max(screenPadding.right, 8)),
        onReorder: (oldIndex, newIndex) => bloc.reorderLoadouts(oldIndex, newIndex));
  }

  Widget buildHandle(BuildContext context, int index) {
    return ReorderableDragStartListener(
        index: index,
        child: AspectRatio(aspectRatio: 1, child: Container(color: Colors.transparent, child: const Icon(Icons.menu))));
  }

  Widget buildSortItem(BuildContext context, int index) {
    final loadout = state.loadouts?[index];
    if (loadout == null) return Container();
    return Container(
        key: Key("loadout-${loadout.loadoutId}"),
        padding: const EdgeInsets.symmetric(vertical: 4),
        color: Colors.transparent,
        child: Stack(
          children: <Widget>[
            loadout.emblemHash != null
                ? Positioned.fill(
                    child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                    loadout.emblemHash,
                    urlExtractor: (def) => def.secondarySpecial,
                    fit: BoxFit.cover,
                  ))
                : Container(),
            Row(
              children: <Widget>[
                buildHandle(context, index),
                Expanded(
                  child: Text(
                    loadout.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            )
          ],
        ));
  }

  Widget buildBody(BuildContext context) {
    final loadouts = state.loadouts;
    if (loadouts == null) {
      return LoadingAnimWidget();
    }
    if (state.isEmpty) {
      return buildNoLoadoutsBody(context);
    }
    return MultiSectionScrollView(
      [
        IntrinsicHeightScrollSection(
          itemBuilder: buildLoadout,
          itemsPerRow: MediaQueryHelper(context).responsiveValue<int>(1, tablet: 2, desktop: 3),
          itemCount: loadouts.length,
        ),
      ],
      padding: EdgeInsets.all(4),
    );
  }

  Widget buildNoLoadoutsBody(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "You have no loadouts yet. Create your first one.".translate(context).toUpperCase(),
                textAlign: TextAlign.center,
              ),
              Container(height: 16),
              ElevatedButton(
                onPressed: bloc.createNew,
                child: Text("Create Loadout".translate(context)),
              )
            ]));
  }

  Widget buildLoadout(BuildContext context, int index) {
    final loadout = state.loadouts?[index];
    if (loadout == null) return Container();
    return LoadoutListItemWidget(
      loadout,
      onAction: (action) => bloc.onItemAction(action, loadout),
    );
  }
}
