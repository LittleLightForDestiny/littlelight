import 'package:bungie_api/models/destiny_record_definition.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/pages/triumphs/widgets/record_item.widget.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';

class TriumphsSearchPage extends StatefulWidget {
  const TriumphsSearchPage({Key? key}) : super(key: key);

  @override
  TriumphsSearchPageState createState() => TriumphsSearchPageState();
}

class TriumphsSearchPageState<T extends TriumphsSearchPage> extends State<T>
    with ManifestConsumer, UserSettingsConsumer {
  final TextEditingController _searchFieldController = TextEditingController();
  List<DestinyRecordDefinition>? items;

  @override
  initState() {
    super.initState();
    _searchFieldController.addListener(() {
      loadItems();
    });

    loadItems();
  }

  loadItems() async {
    items = (await manifest.searchDefinitions<DestinyRecordDefinition>([_searchFieldController.text])).values.toList();
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
          const InventoryNotificationWidget(
            key: Key('inventory_notification_widget'),
            barHeight: 0,
          ),
        ]));
  }

  Widget itemBuilder(BuildContext context, int index) {
    var item = items?[index];
    if (item == null) return Container();
    return Stack(children: [
      SizedBox(height: 120, child: RecordItemWidget(key: Key("${item.hash}"), presentationNodeHash: item.hash)),
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
