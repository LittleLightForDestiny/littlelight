import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/selected_page_persistence.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/search/search_list.widget.dart';
import 'package:bungie_api/enums/destiny_item_type_enum.dart';

class SearchScreen extends StatefulWidget {
  @override
  SearchScreenState createState() => new SearchScreenState();
}

class SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  bool searchOpened = false;
  List<String> search = ["", "", ""];
  Map<int, DestinyInventoryItemDefinition> itemDefinitions;
  TextEditingController _searchFieldController = new TextEditingController();

  TabController _tabController;

  @override
  initState() {
    SelectedPagePersistence.saveLatestScreen(SelectedPagePersistence.search);
    super.initState();
    _tabController = new TabController(vsync: this, length: 3);
    _searchFieldController.text = search[_tabController.index];
    _searchFieldController.addListener(() {
      search[_tabController.index] = _searchFieldController.text;
      setState(() {});
    });

    _tabController.addListener(() {
      print(_tabController.indexIsChanging);
      _searchFieldController.text = search[_tabController.index];
      closeSearch();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        body: TabBarView(controller: _tabController, children: [
          SearchListWidget(
            itemTypes: [DestinyItemType.Weapon],
            search: search[0],
          ),
          SearchListWidget(
            itemTypes: [DestinyItemType.Armor],
            search: search[1],
          ),
          SearchListWidget(
            
            search: search[2],
          )
        ]));
  }

  buildAppBar(BuildContext context) {
    return AppBar(
      bottom: TabBar(
                indicatorColor: Colors.white,
                isScrollable: true,
                controller: _tabController,
                tabs: buildTabButtons(context),
              ),
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
            search[_tabController.index] = _searchFieldController.text;
            setState(() {});
          },
        )
      ],
    );
  }

  List<Widget> buildTabButtons(BuildContext context) {
    return ["Weapons", "Armor", "Everything"].map((name) {
      return buildTabButton(context, name);
    }).toList();
  }
  
  Widget buildTabButton(BuildContext context, String name) {
    return Container(
      padding: EdgeInsets.all(8),
      child:TranslatedTextWidget(name, uppercase: true,
      style: TextStyle(fontWeight: FontWeight.bold,))
    );
  }

  closeSearch() {
    searchOpened = false;
    search[_tabController.index] = "";
    setState(() {});
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
}
