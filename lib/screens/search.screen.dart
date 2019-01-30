import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/utils/selected_page_persistence.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_list/items/search_item_wrapper.widget.dart';

class SearchScreen extends StatefulWidget {
  @override
  SearchScreenState createState() => new SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  bool searchOpened = false;
  String search = "";
  List<_ItemWithOwner> items;
  Map<int, DestinyInventoryItemDefinition> itemDefinitions;
  TextEditingController _searchFieldController = new TextEditingController();

  @override
  initState() {
    SelectedPagePersistence.saveLatestScreen(SelectedPagePersistence.search);
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
    allItems.sort(
        (a, b) => InventoryUtils.sortDestinyItems(a.item, b.item, profile));
    Iterable<int> hashes = allItems.map((i) => i.item.itemHash);
    itemDefinitions =
        await manifest.getDefinitions<DestinyInventoryItemDefinition>(hashes);
    items = allItems.where((item) {
      // var def = itemDefinitions[item.item.itemHash];
      return item.item.itemInstanceId != null;
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
      title: buildAppBarTitle(context),
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
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
      "Search",
      overflow: TextOverflow.fade,
    );
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
    return SearchItemWrapperWidget(item.item,
        itemDefinitions[item.item.itemHash]?.inventory?.bucketTypeHash,
        characterId: item.ownerId,
        key: Key("item_${item.item.itemInstanceId}_${item.item.itemHash}"));
  }
}

class _ItemWithOwner {
  DestinyItemComponent item;
  String ownerId;
  _ItemWithOwner(this.item, this.ownerId);
}
