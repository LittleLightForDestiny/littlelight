import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/screens/edit_loadout.screen.dart';
import 'package:little_light/services/littlelight/littlelight.service.dart';
import 'package:little_light/services/littlelight/models/loadout.model.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/loadouts/loadout_list_item.widget.dart';

class LoadoutsScreen extends StatefulWidget {
  final Map<String, LoadoutItemIndex> itemIndexes = new Map();
  @override
  LoadoutScreenState createState() => new LoadoutScreenState();
}

class LoadoutScreenState extends State<LoadoutsScreen> {
  bool reordering = false;
  bool searchOpen = false;
  List<Loadout> loadouts;

  @override
  void initState() {
    super.initState();
    loadLoadouts();
  }

  void loadLoadouts() async {
    LittleLightService service = LittleLightService();
    loadouts = await service.getLoadouts();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        appBar: buildAppBar(),
        body: buildBody(context),
        bottomNavigationBar: buildFooter(context),
      ),
      InventoryNotificationWidget(key: Key("notification_widget"))
    ]);
  }

  Widget buildAppBar() {
    if(reordering){
      return TranslatedTextWidget("Loadouts");
    }
    if(searchOpen){
      TranslatedTextWidget("Add to Loadout");
      TranslatedTextWidget("Equip only");
      TranslatedTextWidget("Add as equipped");
      TranslatedTextWidget("Random Loadout");
      TranslatedTextWidget("Free slots");
    }
    return AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add_circle_outline),
              onPressed: () async {
                createNew();
              })
        ],
        title: TranslatedTextWidget("Loadouts"));
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

  Widget buildBody(BuildContext context) {
    if (loadouts == null) {
      return Container();
    }

    if (loadouts.length == 0) {
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

    return StaggeredGridView.countBuilder(
      padding: EdgeInsets.all(4),
      crossAxisCount: 30,
      itemCount: loadouts.length,
      itemBuilder: (BuildContext context, int index) => getItem(context, index),
      staggeredTileBuilder: (int index) => getTileBuilder(index),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }

  StaggeredTile getTileBuilder(int index) {
    double screenWidth = MediaQuery.of(context).size.width;
    return StaggeredTile.fit(screenWidth > 480 ? 15 : 30);
  }

  Widget getItem(BuildContext context, int index) {
    Loadout loadout = loadouts[index];
    return LoadoutListItemWidget(
      loadout,
      key: Key("loadout_${loadout.assignedId}_$index"),
      itemIndexes: widget.itemIndexes,
      onChange: () {
        this.loadLoadouts();
      },
    );
  }
}
