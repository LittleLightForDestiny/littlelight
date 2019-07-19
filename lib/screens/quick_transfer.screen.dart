import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/item_list/quick_transfer_search_list.widget.dart';


class QuickTransferScreen extends StatefulWidget {
  final DestinyInventoryBucketDefinition bucketDefinition;
  final Iterable<String> idsToAvoid;
  final int classType;

  QuickTransferScreen({this.bucketDefinition, this.classType, this.idsToAvoid})
      : super();

  @override
  QuickTransferScreenState createState() => new QuickTransferScreenState();
}

class QuickTransferScreenState extends State<QuickTransferScreen> {
  String search = "";
  Map<int, DestinyInventoryItemDefinition> itemDefinitions;
  TextEditingController _searchFieldController = new TextEditingController();

  @override
  initState() {
    _searchFieldController.text = search;
    _searchFieldController.addListener(() {
      search = _searchFieldController.text;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildItemList(context),
    );
  }

  buildAppBar(BuildContext context) {
    return AppBar(
      title: buildAppBarTitle(context),
      titleSpacing: 0,
      actions: <Widget>[Container(width: 24,)],
    );
  }

  buildAppBarTitle(BuildContext context) {
    return TextField(
      controller: _searchFieldController,
      autofocus: true,
    );
  }

  Widget buildItemList(BuildContext context) {
    return QuickTransferSearchListWidget(
        searchText: this.search,
        bucketType: widget.bucketDefinition.hash,
        classType: widget.classType,
        idsToAvoid: widget.idsToAvoid);
  }
}
