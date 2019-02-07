import 'package:bungie_api/enums/damage_type_enum.dart';
import 'package:bungie_api/enums/tier_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_category_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/selected_page_persistence.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/search/search_filters.widget.dart';
import 'package:little_light/widgets/search/search_list.widget.dart';
import 'package:bungie_api/enums/destiny_item_type_enum.dart';
import 'package:bungie_api/enums/destiny_item_sub_type_enum.dart';
import 'package:bungie_api/enums/destiny_ammunition_type_enum.dart';

class SearchTabData {
  String searchText = "";
  List<int> itemTypes;
  List<int> excludeItemTypes;
  Widget label;
  Map<FilterType, FilterItem> filterData;

  SearchTabData(
      {this.itemTypes, this.excludeItemTypes, this.label, this.filterData});
}

class SearchScreen extends StatefulWidget {
  @override
  SearchScreenState createState() => new SearchScreenState();
}



class SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  bool searchOpened = false;
  Map<int, DestinyInventoryItemDefinition> itemDefinitions;
  TextEditingController _searchFieldController = new TextEditingController();

  TabController _tabController;

  List<SearchTabData> _tabs = [
    SearchTabData(
        itemTypes: [
          DestinyItemType.Weapon
        ],
        filterData: {
          FilterType.powerLevel: FilterItem([0, DestinyData.maxPowerLevel], [0, DestinyData.maxPowerLevel]),
          FilterType.bucketType: FilterItem([
            InventoryBucket.kineticWeapons,
            InventoryBucket.energyWeapons,
            InventoryBucket.powerWeapons
          ], []),
          FilterType.damageType: FilterItem([
            DamageType.Kinetic,
            DamageType.Thermal,
            DamageType.Arc,
            DamageType.Void,
          ], []),
          FilterType.tierType: FilterItem([
            TierType.Basic,
            TierType.Common,
            TierType.Rare,
            TierType.Superior,
            TierType.Exotic,
          ], []),
          FilterType.itemSubType: FilterItem([
            DestinyItemSubType.HandCannon,
            DestinyItemSubType.AutoRifle,
            DestinyItemSubType.PulseRifle,
            DestinyItemSubType.ScoutRifle,
            DestinyItemSubType.Sidearm,
            DestinyItemSubType.SubmachineGun,
            DestinyItemSubType.TraceRifle,
            DestinyItemSubType.Bow,
            DestinyItemSubType.Shotgun,
            DestinyItemSubType.SniperRifle,
            DestinyItemSubType.FusionRifle,
            DestinyItemSubType.FusionRifleLine,
            DestinyItemSubType.GrenadeLauncher,
            DestinyItemSubType.RocketLauncher,
            DestinyItemSubType.Sword,
            DestinyItemSubType.Machinegun,
          ], []),
          FilterType.ammoType: FilterItem([
          DestinyAmmunitionType.Primary,
          DestinyAmmunitionType.Special,
          DestinyAmmunitionType.Heavy
          ], [])
        },
        label: ManifestText<DestinyItemCategoryDefinition>(1,
            uppercase: true,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ))),
    SearchTabData(
        itemTypes: [DestinyItemType.Armor],
        filterData: {},
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
          filterData: {},
        excludeItemTypes: [
          DestinyItemType.Weapon,
          DestinyItemType.Armor,
          DestinyItemType.Subclass
        ]),
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
        endDrawer: SearchFiltersWidget(
          filterData: currentTabData.filterData,
          onChange: (){
            setState(() {});
          },
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Material(
              color: Colors.blueGrey.shade700,
              elevation: 1,
              child: Center(
                  child: TabBar(
                indicatorColor: Colors.white,
                isScrollable: true,
                controller: _tabController,
                tabs: buildTabButtons(context),
              ))),
          Expanded(
              child: TabBarView(
                  controller: _tabController,
                  children: _tabs
                      .map(
                        (tab) => SearchListWidget(
                              tabData: tab,
                            ),
                      )
                      .toList()))
        ]));
  }

  buildAppBar(BuildContext context) {
    return AppBar(
      title: buildAppBarTitle(context),
      elevation: 2,
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
            builder: (context) => IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ))
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
