import 'package:flutter/material.dart';
import 'package:little_light/services/littlelight/littlelight_api.service.dart';
import 'package:little_light/services/littlelight/models/loadout.model.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/loadouts/loadout_list_item.widget.dart';

class LoadoutsScreen extends StatefulWidget {
  final Map<String, LoadoutItemIndex> itemIndexes = new Map();
  @override
  LoadoutScreenState createState() => new LoadoutScreenState();
}

class LoadoutScreenState extends State<LoadoutsScreen>{
  List<Loadout> loadouts;

  @override
  void initState() {
    super.initState();
    loadLoadouts();
  }

  void loadLoadouts() async {
    LittleLightApiService service = LittleLightApiService();
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
            title: TranslatedTextWidget("Loadouts")),
        body: buildBody(context));
  }

  Widget buildBody(BuildContext context) {
    if (loadouts == null) {
      return Container();
    }
    return ListView.builder(
      itemCount: loadouts.length,
      itemBuilder: getItem,
      addAutomaticKeepAlives: true,
      );
  }

  Widget getItem(BuildContext context, int index) {
    return LoadoutListItemWidget(loadouts[index], key:Key("loadout_$index"), itemIndexes: widget.itemIndexes,);
  }
}
