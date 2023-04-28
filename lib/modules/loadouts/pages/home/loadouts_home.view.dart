import 'dart:math';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/modules/loadouts/pages/edit/edit_loadout.page_route.dart';
import 'package:little_light/modules/loadouts/widgets/loadout_list_item.widget.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:provider/provider.dart';

import 'loadouts_home.bloc.dart';

class LoadoutsHomeView extends StatefulWidget {
  const LoadoutsHomeView({Key? key}) : super(key: key);
  @override
  LoadoutsHomeViewState createState() => LoadoutsHomeViewState();
}

class LoadoutsHomeViewState extends State<LoadoutsHomeView> with ProfileConsumer {
  final TextEditingController _searchFieldController = TextEditingController();
  LoadoutsHomeBloc get _bloc => context.read<LoadoutsHomeBloc>();
  LoadoutsHomeBloc get _state => context.watch<LoadoutsHomeBloc>();

  @override
  void initState() {
    super.initState();
    initSearchController();
  }

  initSearchController() {
    _searchFieldController.addListener(() {
      _bloc.searchString = _searchFieldController.text;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchFieldController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        appBar: buildAppBar(context),
        body: _state.reordering ? buildReorderingBody(context) : buildBody(context),
        bottomNavigationBar: buildFooter(context),
      ),
      const InventoryNotificationWidget(key: Key("notification_widget"))
    ]);
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
            icon: const Icon(Icons.refresh),
            onPressed: () => _bloc.reloadLoadouts(),
          )
        ],
        title: buildTitle(context));
  }

  Widget buildTitle(BuildContext context) {
    if (_state.searchOpen) {
      return TextField(
        decoration: const InputDecoration(isDense: true),
        autofocus: true,
        controller: _searchFieldController,
      );
    }
    return _state.reordering
        ? Text(
            "Reordering Loadouts".translate(context),
          )
        : Text(
            "Loadouts".translate(context),
          );
  }

  Widget buildSearchButton(BuildContext context) {
    if (_state.reordering) return Container();
    return IconButton(
        enableFeedback: false,
        icon: _state.searchOpen ? const Icon(FontAwesomeIcons.xmark) : const Icon(FontAwesomeIcons.magnifyingGlass),
        onPressed: () => _bloc.toggleSearch());
  }

  Widget buildReorderButton(BuildContext context) {
    if (_state.searchOpen) return Container();
    return IconButton(
        enableFeedback: false,
        icon: _state.reordering
            ? const Icon(FontAwesomeIcons.check)
            : Transform.rotate(angle: pi / 2, child: const Icon(FontAwesomeIcons.rightLeft)),
        onPressed: () => _bloc.toggleReordering());
  }

  void createNew() async {
    var newLoadout = await Navigator.push(context, EditLoadoutPageRoute.create());
    if (newLoadout != null) {
      _bloc.reloadLoadouts();
    }
  }

  Widget? buildFooter(BuildContext context) {
    if (_state.isEmpty) {
      return null;
    }
    double paddingBottom = MediaQuery.of(context).padding.bottom;
    return Material(
        color: Theme.of(context).bottomAppBarColor,
        elevation: 1,
        child: Container(
          constraints: const BoxConstraints(minWidth: double.infinity),
          height: kToolbarHeight + paddingBottom,
          padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 8, bottom: 8 + paddingBottom),
          child: ElevatedButton(
            onPressed: createNew,
            child: Text("Create Loadout".translate(context)),
          ),
        ));
  }

  Widget buildReorderingBody(BuildContext context) {
    var screenPadding = MediaQuery.of(context).padding;

    return ReorderableList(
        itemCount: _state.loadouts!.length,
        itemBuilder: (context, index) {
          return buildSortItem(context, index);
        },
        itemExtent: 56,
        padding: const EdgeInsets.all(8).copyWith(left: max(screenPadding.left, 8), right: max(screenPadding.right, 8)),
        onReorder: (oldIndex, newIndex) => _bloc.reorderLoadouts(oldIndex, newIndex));
  }

  Widget buildHandle(BuildContext context, int index) {
    return ReorderableDragStartListener(
        index: index,
        child: AspectRatio(aspectRatio: 1, child: Container(color: Colors.transparent, child: const Icon(Icons.menu))));
  }

  Widget buildSortItem(BuildContext context, int index) {
    final loadout = _state.loadouts![index];
    return Container(
        key: Key("loadout-${loadout.assignedId}"),
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
    final loadouts = _state.loadouts;
    if (loadouts == null) {
      return LoadingAnimWidget();
    }
    if (_state.isEmpty) {
      return buildNoLoadoutsBody(context);
    }
    return MasonryGridView.count(
      key: Key("loadouts_grid_${_state.lastUpdated}"),
      itemCount: loadouts.length,
      crossAxisCount: MediaQueryHelper(context).responsiveValue<int>(1, tablet: 2, laptop: 3),
      itemBuilder: (context, index) => getItem(context, index),
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
                onPressed: createNew,
                child: Text("Create Loadout".translate(context)),
              )
            ]));
  }

  Widget getItem(BuildContext context, int index) {
    final loadout = _state.loadouts![index];
    return LoadoutListItemWidget(
      loadout,
      onAction: (action) => _bloc.onItemAction(action, loadout),
    );
  }
}
