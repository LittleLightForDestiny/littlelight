import 'package:bungie_api/enums/destiny_class.dart';
import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/utils/selected_page_persistence.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_list/loadout_search_list.widget.dart';

class SelectLoadoutItemScreen extends StatefulWidget {
  final DestinyInventoryItemDefinition emblemDefinition;
  final DestinyInventoryBucketDefinition bucketDefinition;
  final Iterable<String> idsToAvoid;
  final DestinyClass classType;

  SelectLoadoutItemScreen(
      {this.bucketDefinition,
      this.emblemDefinition,
      this.classType,
      this.idsToAvoid})
      : super();

  @override
  SelectLoadoutItemScreenState createState() =>
      new SelectLoadoutItemScreenState();
}

class SelectLoadoutItemScreenState extends State<SelectLoadoutItemScreen> {
  bool searchOpened = false;
  String search = "";
  Map<int, DestinyInventoryItemDefinition> itemDefinitions;
  TextEditingController _searchFieldController = new TextEditingController();

  @override
  initState() {
    SelectedPagePersistence.saveLatestScreen(SelectedPagePersistence.loadouts);
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
      flexibleSpace: buildAppBarBackground(context),
      title: buildAppBarTitle(context),
      titleSpacing: 0,
      actions: <Widget>[
        IconButton(
          icon: Icon(searchOpened ? Icons.clear : Icons.search),
          onPressed: () {
            searchOpened = !searchOpened;
            search = "";
            setState(() {});
          },
        )
      ],
    );
  }

  buildAppBarTitle(BuildContext context) {
    if (searchOpened) {
      return TextField(
        autofocus: true,
        controller: _searchFieldController,
      );
    }
    return TranslatedTextWidget(
      "Select {bucketName}",
      overflow: TextOverflow.fade,
      replace: {'bucketName': widget.bucketDefinition.displayProperties.name},
    );
  }

  buildAppBarBackground(BuildContext context) {
    if (widget.emblemDefinition == null) return Container();
    return Container(
        constraints: BoxConstraints.expand(),
        child: QueuedNetworkImage(
            imageUrl:
                BungieApiService.url(widget.emblemDefinition.secondarySpecial),
            fit: BoxFit.cover,
            alignment: Alignment(-.8, 0)));
  }

  Widget buildItemList(BuildContext context) {
    return LoadoutSearchListWidget(
        searchText: this.search, bucketType: widget.bucketDefinition.hash,
        classType:widget.classType,
        idsToAvoid:widget.idsToAvoid);
  }
}
