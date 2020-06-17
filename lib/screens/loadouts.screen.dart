import 'dart:math';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:drag_list/drag_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/screens/edit_loadout.screen.dart';
import 'package:little_light/services/littlelight/loadouts.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/loadouts/loadout_list_item.widget.dart';

class LoadoutsScreen extends StatefulWidget {
  @override
  LoadoutScreenState createState() => new LoadoutScreenState();
}

class LoadoutScreenState extends State<LoadoutsScreen> {
  final Map<String, LoadoutItemIndex> itemIndexes = new Map();
  bool reordering = false;
  bool searchOpen = false;
  List<Loadout> loadouts;
  List<Loadout> filteredLoadouts;
  TextEditingController _searchFieldController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    ProfileService().updateComponents = ProfileComponentGroups.basicProfile;
    _searchFieldController.addListener(() {
      filteredLoadouts = filterLoadouts();
      setState(() {});
    });
    loadLoadouts();
  }

  List<Loadout> filterLoadouts(){
    var text = _searchFieldController.text.toLowerCase();
    return loadouts.where((l){
        if(text.length <=3){
          return l?.name?.toLowerCase()?.startsWith(text);
        }
        return l?.name?.toLowerCase()?.contains(text);
      }).toList();
  }

  void loadLoadouts() async {
    LoadoutsService service = LoadoutsService();
    loadouts = await service.getLoadouts();
    filteredLoadouts = loadouts;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        appBar: buildAppBar(context),
        body: reordering ? buildReorderingBody(context) : buildBody(context),
        bottomNavigationBar: buildFooter(context),
      ),
      InventoryNotificationWidget(key: Key("notification_widget"))
    ]);
  }

  Widget buildAppBar(BuildContext context) {
    return AppBar(
        leading: IconButton(enableFeedback: false,
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        actions: <Widget>[
          buildReorderButton(context),
          buildSearchButton(context)
        ],
        title: buildTitle(context));
  }

  Widget buildTitle(BuildContext context){
    if (searchOpen) {
      return TextField(
        autofocus: true,
        controller: _searchFieldController,
      );
    }
    return reordering  ? TranslatedTextWidget("Reordering Loadouts") : TranslatedTextWidget("Loadouts");
  }

  Widget buildSearchButton(BuildContext context) {
    if(reordering) return Container();
    return IconButton(enableFeedback: false,
        icon: searchOpen ? Icon(FontAwesomeIcons.times) : Icon(FontAwesomeIcons.search),
        onPressed: () async {
          searchOpen = !searchOpen;
          if(!searchOpen){
            _searchFieldController.text = "";
          }
          setState(() {});
        });
  }

  Widget buildReorderButton(BuildContext context) {
    if(searchOpen) return Container();
    return IconButton(enableFeedback: false,
        icon: reordering ? Icon(FontAwesomeIcons.check) : Transform.rotate(
          angle: pi/2,
          child:Icon(FontAwesomeIcons.exchangeAlt)),
        onPressed: () async {
          reordering = !reordering;
          setState(() {});
        });
  }

  void createNew() async {
    var newLoadout = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditLoadoutScreen(),
      ),
    );
    if (newLoadout != null) {
      loadLoadouts();
    }
  }

  Widget buildFooter(BuildContext context) {
    if ((loadouts?.length ?? 0) == 0) {
      return null;
    }
    double paddingBottom = MediaQuery.of(context).padding.bottom;
    return Material(
        color: Theme.of(context).primaryColor,
        elevation: 1,
        child: Container(
          constraints: BoxConstraints(minWidth: double.infinity),
          height: kToolbarHeight + paddingBottom,
          padding: EdgeInsets.symmetric(horizontal: 16)
              .copyWith(top: 8, bottom: 8 + paddingBottom),
          child: RaisedButton(
            child: TranslatedTextWidget("Create Loadout"),
            onPressed: () {
              createNew();
            },
          ),
        ));
  }

  Widget buildReorderingBody(BuildContext context) {
    var screenPadding = MediaQuery.of(context).padding;
    return DragList<Loadout>(
        items: loadouts,
        itemExtent: 56,
        padding: EdgeInsets.all(8).copyWith(left:max(screenPadding.left, 8), right:max(screenPadding.right, 8)),
        handleBuilder: (context) => buildHandle(context),
        onItemReorder: (oldIndex, newIndex) {
          var removed = loadouts.removeAt(oldIndex);
          loadouts.insert(newIndex, removed);
          LoadoutsService().saveLoadoutsOrder(loadouts);
        },
        itemBuilder: (context, parameter, handle) =>
            buildSortItem(context, parameter, handle));
  }

  Widget buildHandle(BuildContext context) {
    return GestureDetector(
        onVerticalDragStart: (_) {},
        onVerticalDragDown: (_) {},
        child: AspectRatio(
            aspectRatio: 1,
            child:
                Container(color: Colors.transparent, child: Icon(Icons.menu))));
  }

  Widget buildSortItem(BuildContext context, Loadout loadout, Widget handle) {
    return Container(
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
                handle,
                Expanded(
                  child: Text(
                    loadout?.name ?? "",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            )
          ],
        ));
  }

  Widget buildBody(BuildContext context) {
    if (loadouts == null) {
      return Container();
    }

    if (loadouts.length == 0) {
      return buildNoLoadoutsBody(context);
    }
    var screenPadding = MediaQuery.of(context).padding;
    return StaggeredGridView.countBuilder(
      padding: EdgeInsets.all(4).copyWith(left:max(screenPadding.left, 4), right:max(screenPadding.right, 4)),
      crossAxisCount: 30,
      itemCount: filteredLoadouts.length,
      itemBuilder: (BuildContext context, int index) => getItem(context, index),
      staggeredTileBuilder: (int index) => getTileBuilder(index),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      physics: const AlwaysScrollableScrollPhysics(),
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
              RaisedButton(
                child: TranslatedTextWidget("Create Loadout"),
                onPressed: createNew,
              )
            ]));
  }

  StaggeredTile getTileBuilder(int index) {
    bool isTablet = MediaQueryHelper(context).tabletOrBigger;
    return StaggeredTile.fit(isTablet ? 15 : 30);
  }

  Widget getItem(BuildContext context, int index) {
    Loadout loadout = filteredLoadouts[index];
    return LoadoutListItemWidget(
      loadout,
      key: Key("loadout_${loadout.assignedId}_$index"),
      itemIndexes: itemIndexes,
      onChange: () {
        this.loadLoadouts();
      },
    );
  }
}
