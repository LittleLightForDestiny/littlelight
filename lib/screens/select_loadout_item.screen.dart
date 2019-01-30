import 'package:bungie_api/enums/destiny_class_enum.dart';
import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/utils/selected_page_persistence.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_list/items/loadout_search_item_wrapper.widget.dart';

class SelectLoadoutItemScreen extends StatefulWidget {
  final DestinyInventoryItemDefinition emblemDefinition;
  final DestinyInventoryBucketDefinition bucketDefinition;
  final Iterable<String> idsToAvoid;
  final int classType;

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
  List<_ItemWithOwner> items;
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
    loadItems();
  }

  loadItems() async {
    List<_ItemWithOwner> allItems = [];
    ProfileService profile = ProfileService();
    ManifestService manifest = ManifestService();
    Iterable<String> charIds =
        profile.getCharacters().map((char) => char.characterId);
    charIds.forEach((charId) {
      allItems.addAll(profile
          .getCharacterEquipment(charId)
          .map((item) => _ItemWithOwner(item, charId)));
      allItems.addAll(profile
          .getCharacterInventory(charId)
          .map((item) => _ItemWithOwner(item, charId)));
    });
    allItems.addAll(profile
        .getProfileInventory()
        .map((item) => _ItemWithOwner(item, null)));
    allItems.removeWhere((i) =>
        i.item.itemInstanceId == null ||
        widget.idsToAvoid.contains(i.item.itemInstanceId));
    allItems.sort((a, b)=>InventoryUtils.sortDestinyItems(a.item, b.item, profile));
    Iterable<int> hashes = allItems.map((i) => i.item.itemHash);
    itemDefinitions =
        await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes);
    items = allItems.where((item) {
      var def = itemDefinitions[item.item.itemHash];
      if (widget.classType != null &&
          widget.classType != def.classType &&
          def.classType != DestinyClass.Unknown) {
        return false;
      }
      if (def.inventory.bucketTypeHash != widget.bucketDefinition.hash) {
        return false;
      }
      return true;
    }).toList();
    setState(() {});
  }

  sortItems() {}

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
        child: CachedNetworkImage(
            imageUrl:
                BungieApiService.url(widget.emblemDefinition.secondarySpecial),
            fit: BoxFit.cover,
            alignment: Alignment(-.8, 0)));
  }

  Widget buildItemList(BuildContext context) {
    return StaggeredGridView.countBuilder(
      padding: EdgeInsets.all(4),
      crossAxisCount: 6,
      itemCount: filteredItems?.length ?? 0,
      itemBuilder: (BuildContext context, int index) => getItem(context, index),
      staggeredTileBuilder: (int index) => getTileBuilder(context, index),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }

  List<_ItemWithOwner> get filteredItems {
    if (search.length == 0) {
      return items;
    }
    if (search.length < 5) {
      return items.where((item) {
        var def = itemDefinitions[item.item.itemHash];
        return def.displayProperties.name
            .toLowerCase()
            .startsWith(search.toLowerCase());
      }).toList();
    }
    return items.where((item) {
      var def = itemDefinitions[item.item.itemHash];
      return def.displayProperties.name
          .toLowerCase()
          .contains(search.toLowerCase());
    }).toList();
  }

  StaggeredTile getTileBuilder(BuildContext context, int index) {
    return StaggeredTile.extent(6, 96);
  }

  Widget getItem(BuildContext context, int index) {
    var item = filteredItems[index];
    return LoadoutSearchItemWrapperWidget(item.item, widget.bucketDefinition.hash,
        characterId: item.ownerId, key:Key("item_${item.item.itemInstanceId}"));
  }
}

class _ItemWithOwner {
  DestinyItemComponent item;
  String ownerId;
  _ItemWithOwner(this.item, this.ownerId);
}
