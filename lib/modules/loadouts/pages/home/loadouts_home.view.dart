import 'dart:math';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/modules/loadouts/pages/edit/edit_loadout.page_route.dart';
import 'package:little_light/modules/loadouts/pages/home/loadouts_home.bloc.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:little_light/modules/loadouts/widgets/loadout_list_item.widget.dart';
import 'package:little_light/services/littlelight/loadouts.consumer.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:provider/provider.dart';

class LoadoutsHomeView extends StatefulWidget {
  @override
  LoadoutsHomeViewState createState() => LoadoutsHomeViewState();
}

class LoadoutsHomeViewState extends State<LoadoutsHomeView> with LoadoutsConsumer, ProfileConsumer {
  TextEditingController _searchFieldController = TextEditingController();
  LoadoutsHomeBloc get _provider => context.read<LoadoutsHomeBloc>();
  LoadoutsHomeBloc get _state => context.watch<LoadoutsHomeBloc>();

  @override
  void initState() {
    super.initState();
    initSearchController();
  }

  initSearchController() {
    _searchFieldController.addListener(() {
      _provider.searchString = _searchFieldController.text;
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
      InventoryNotificationWidget(key: Key("notification_widget"))
    ]);
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        actions: <Widget>[
          buildReorderButton(context),
          buildSearchButton(context),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _provider.loadLoadouts(forceFetch: true),
          )
        ],
        title: buildTitle(context));
  }

  Widget buildTitle(BuildContext context) {
    if (_state.searchOpen) {
      return TextField(
        decoration: InputDecoration(isDense: true),
        autofocus: true,
        controller: _searchFieldController,
      );
    }
    return _state.reordering ? TranslatedTextWidget("Reordering Loadouts") : TranslatedTextWidget("Loadouts");
  }

  Widget buildSearchButton(BuildContext context) {
    if (_state.reordering) return Container();
    return IconButton(
        enableFeedback: false,
        icon: _state.searchOpen ? Icon(FontAwesomeIcons.times) : Icon(FontAwesomeIcons.search),
        onPressed: () => _provider.toggleSearch());
  }

  Widget buildReorderButton(BuildContext context) {
    if (_state.searchOpen) return Container();
    return IconButton(
        enableFeedback: false,
        icon: _state.reordering
            ? Icon(FontAwesomeIcons.check)
            : Transform.rotate(angle: pi / 2, child: Icon(FontAwesomeIcons.exchangeAlt)),
        onPressed: () => _provider.toggleReordering());
  }

  void createNew() async {
    var newLoadout = await Navigator.push(context, CreateLoadoutPageRoute());
    if (newLoadout != null) {
      _provider.loadLoadouts();
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
          constraints: BoxConstraints(minWidth: double.infinity),
          height: kToolbarHeight + paddingBottom,
          padding: EdgeInsets.symmetric(horizontal: 16).copyWith(top: 8, bottom: 8 + paddingBottom),
          child: ElevatedButton(
            child: TranslatedTextWidget("Create Loadout"),
            onPressed: createNew,
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
        padding: EdgeInsets.all(8).copyWith(left: max(screenPadding.left, 8), right: max(screenPadding.right, 8)),
        onReorder: (oldIndex, newIndex) => _provider.reorderLoadouts(oldIndex, newIndex));
  }

  Widget buildHandle(BuildContext context, int index) {
    return ReorderableDragStartListener(
        child: AspectRatio(aspectRatio: 1, child: Container(color: Colors.transparent, child: Icon(Icons.menu))),
        index: index);
  }

  Widget buildSortItem(BuildContext context, int index) {
    final loadout = _state.loadouts![index].loadout;
    return Container(
        key: Key("loadout-${loadout.assignedId}"),
        padding: EdgeInsets.symmetric(vertical: 4),
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
                    style: TextStyle(fontWeight: FontWeight.bold),
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
    bool isTablet = MediaQueryHelper(context).tabletOrBigger;
    return MasonryGridView.count(
      itemCount: loadouts.length,
      crossAxisCount: isTablet ? 2 : 1,
      itemBuilder: (context, index) => getItem(context, index),
    );
  }

  Widget buildNoLoadoutsBody(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(16),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TranslatedTextWidget(
                "You have no loadouts yet. Create your first one.",
                textAlign: TextAlign.center,
              ),
              Container(height: 16),
              ElevatedButton(
                child: TranslatedTextWidget("Create Loadout"),
                onPressed: createNew,
              )
            ]));
  }

  Widget getItem(BuildContext context, int index) {
    final loadout = _state.loadouts![index];
    return LoadoutListItemWidget(
      loadout,
      key: Key("loadout_${loadout.loadout.assignedId}_$index"),
      onAction: (action) => onItemAction(action, loadout),
    );
  }

  void onItemAction(LoadoutListItemAction action, LoadoutItemIndex loadout) async {
    switch (action) {
      case LoadoutListItemAction.Equip:
        // TODO: Handle this case.
        break;
      case LoadoutListItemAction.Edit:
        final id = loadout.loadout.assignedId;
        if (id == null) return;
        Navigator.of(context).push(EditLoadoutPageRoute(loadoutID: id));
        break;
      case LoadoutListItemAction.Delete:
        break;
    }
  }
}
