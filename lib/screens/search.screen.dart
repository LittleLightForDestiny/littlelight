import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_category_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/selected_page_persistence.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/search/search_filters.widget.dart';
import 'package:little_light/widgets/search/search_list.widget.dart';
import 'package:bungie_api/enums/destiny_item_type_enum.dart';

class SearchScreen extends StatefulWidget {
  @override
  SearchScreenState createState() => new SearchScreenState();
}

class SearchTabData {
  String searchText = "";
  List<int> itemTypes;
  List<int> excludeItemTypes;
  Widget label;

  SearchTabData(
      {this.itemTypes,
      this.excludeItemTypes,
      this.label});
}

class SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  bool searchOpened = false;
  Map<int, DestinyInventoryItemDefinition> itemDefinitions;
  TextEditingController _searchFieldController = new TextEditingController();

  TabController _tabController;

  List<SearchTabData> _tabs = [
    SearchTabData(
        itemTypes: [DestinyItemType.Weapon],
        label: ManifestText<DestinyItemCategoryDefinition>(1,
            uppercase: true,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ))),
    SearchTabData(
        itemTypes: [DestinyItemType.Armor],
        label: ManifestText<DestinyItemCategoryDefinition>(20,
            uppercase: true,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ))),
    SearchTabData(
        label: TranslatedTextWidget("Other",
            uppercase: true,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )),
        excludeItemTypes: [DestinyItemType.Weapon, DestinyItemType.Armor, DestinyItemType.Subclass]),
  ];

  @override
  initState() {
    SelectedPagePersistence.saveLatestScreen(SelectedPagePersistence.search);
    super.initState();
    _tabController = new TabController(vsync: this, length: 3);
    _searchFieldController.text = currentTabData.searchText;
    _searchFieldController.addListener(() {
      currentTabData.searchText = _searchFieldController.text;
      setState(() {});
    });

    _tabController.addListener(() {
      _searchFieldController.text = currentTabData.searchText;
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
        endDrawer: SearchFiltersWidget(),
        body: TabBarView(controller: _tabController, children: _tabs.map((tab)=>
          SearchListWidget(
            itemTypes: tab.itemTypes,
            excludeTypes: tab.excludeItemTypes,
            search: tab.searchText,
          ),
        ).toList()));
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
            currentTabData.searchText = _searchFieldController.text;
            setState(() {});
          },
        ),
        Builder(
          builder:(context)=>IconButton(icon: Icon(Icons.filter_list),
        onPressed: (){
          Scaffold.of(context).openEndDrawer();
        },))
      ],
    );
  }

  List<Widget> buildTabButtons(BuildContext context) {
    return _tabs.map((tab) {
      return buildTabButton(context, tab.label);
    }).toList();
  }

  Widget buildTabButton(BuildContext context, Widget label) {
    return Container(padding: EdgeInsets.all(8), child: label);
  }

  closeSearch() {
    searchOpened = false;
    currentTabData.searchText = "";
    setState(() {});
  }

  SearchTabData get currentTabData => _tabs[_tabController.index];

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
