import 'package:bungie_api/models/destiny_collectible_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/widgets/presentation_nodes/collectible_item.widget.dart';

class CollectionsSearchPage extends StatefulWidget {
  CollectionsSearchPage({Key? key}) : super(key: key);

  @override
  CollectionsSearchPageState createState() => CollectionsSearchPageState();
}

class CollectionsSearchPageState<T extends CollectionsSearchPage> extends State<T>
    with ManifestConsumer, UserSettingsConsumer {
  TextEditingController _searchFieldController = new TextEditingController();
  List<DestinyCollectibleDefinition>? items;

  @override
  initState() {
    super.initState();
    _searchFieldController.addListener(() {
      this.loadItems();
    });

    this.loadItems();
  }

  loadItems() async {
    this.items =
        (await manifest.searchDefinitions<DestinyCollectibleDefinition>([_searchFieldController.text])).values.toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        body: Stack(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
                child: ListView.builder(
              addAutomaticKeepAlives: true,
              itemBuilder: itemBuilder,
              itemCount: items?.length ?? 0,
            )),
          ]),
          InventoryNotificationWidget(
            key: Key('inventory_notification_widget'),
            barHeight: 0,
          ),
        ]));
  }

  Widget itemBuilder(BuildContext context, int index) {
    var item = items?[index];
    if (item == null) return Container();
    return Stack(children: [
      Container(height: 96, child: CollectibleItemWidget(key: Key("${item.hash}"), hash: item.hash)),
    ]);
  }

  buildAppBar(BuildContext context) {
    return AppBar(
      title: buildAppBarTitle(context),
      elevation: 2,
    );
  }

  buildAppBarTitle(BuildContext context) {
    return TextField(
      autofocus: userSettings.autoOpenKeyboard,
      controller: _searchFieldController,
    );
  }
}
