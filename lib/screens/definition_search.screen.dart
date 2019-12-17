import 'package:flutter/material.dart';

import 'package:little_light/services/manifest/manifest.service.dart';

import 'package:little_light/services/user_settings/user_settings.service.dart';

import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';

abstract class DefinitionSearchScreen extends StatefulWidget {
  DefinitionSearchScreen({Key key}) : super(key: key);

  @override
  DefinitionSearchScreenState createState();
}

abstract class DefinitionSearchScreenState<T extends DefinitionSearchScreen, DT>
    extends State<T> {
  TextEditingController _searchFieldController = new TextEditingController();
  List<DT> items;

  @override
  initState() {
    super.initState();
    _searchFieldController.addListener(() {
      this.loadItems();
    });

    this.loadItems();
  }

  loadItems() async {
    this.items = (await ManifestService()
            .searchDefinitions<DT>([_searchFieldController.text]))
        .values
        .toList();
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
    return Container();
  }

  buildAppBar(BuildContext context) {
    return AppBar(
      title: buildAppBarTitle(context),
      elevation: 2,
    );
  }

  buildAppBarTitle(BuildContext context) {
    return TextField(
      autofocus: UserSettingsService().autoOpenKeyboard,
      controller: _searchFieldController,
    );
  }
}
