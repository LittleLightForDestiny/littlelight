import 'package:flutter/material.dart';
import 'package:little_light/screens/edit_loadout.screen.dart';
import 'package:little_light/services/littlelight/littlelight.service.dart';
import 'package:little_light/services/littlelight/models/loadout.model.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/loadouts/loadout_list_item.widget.dart';

class LoadoutsScreen extends StatefulWidget {
  final Map<String, LoadoutItemIndex> itemIndexes = new Map();
  @override
  LoadoutScreenState createState() => new LoadoutScreenState();
}

class LoadoutScreenState extends State<LoadoutsScreen> {
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
    return Scaffold(
        appBar: AppBar(
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
            title: TranslatedTextWidget("Loadouts")),
        body: buildBody(context),
        bottomNavigationBar: buildFooter(context),);
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
    return Material(
        color: Theme.of(context).primaryColor,
        elevation: 1,
        child: Container(
          constraints: BoxConstraints(minWidth: double.infinity),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
    return ListView.builder(
      itemCount: loadouts.length,
      itemBuilder: getItem,
      addAutomaticKeepAlives: true,
    );
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
