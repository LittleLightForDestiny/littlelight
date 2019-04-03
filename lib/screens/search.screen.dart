import 'dart:async';

import 'package:bungie_api/enums/damage_type_enum.dart';
import 'package:bungie_api/enums/destiny_class_enum.dart';
import 'package:bungie_api/enums/tier_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_category_definition.dart';
import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/inventory/inventory.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/selection/selection.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/utils/selected_page_persistence.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/inventory_tabs/selected_items.widget.dart';
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
  List<SortParameter> sortOrder;
  SearchTabData(
      {this.itemTypes,
      this.excludeItemTypes,
      this.label,
      this.filterData,
      this.sortOrder = const [
        SortParameter(SortParameterType.bucketHash),
        SortParameter(SortParameterType.power, -1),
      ]});
}

class SearchScreen extends StatefulWidget {
  @override
  SearchScreenState createState() => new SearchScreenState();
}

class SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  bool searchOpened = false;
  Map<int, DestinyInventoryItemDefinition> perkDefinitions;
  TextEditingController _searchFieldController = new TextEditingController();

  TabController _tabController;

  List<SearchTabData> _tabs = [
    //// WEAPONS ////
    SearchTabData(
        itemTypes: [
          DestinyItemType.Weapon
        ],
        sortOrder: [
          SortParameter(SortParameterType.bucketHash),
          SortParameter(SortParameterType.power, -1),
          SortParameter(SortParameterType.tierType, -1),
          SortParameter(SortParameterType.subType),
          SortParameter(SortParameterType.name),
        ],
        filterData: {
          FilterType.powerLevel: FilterItem(
              [0, DestinyData.maxPowerLevel], [0, DestinyData.maxPowerLevel],
              open: true),
          FilterType.bucketType: FilterItem([
            InventoryBucket.kineticWeapons,
            InventoryBucket.energyWeapons,
            InventoryBucket.powerWeapons
          ], [], open: true),
          FilterType.damageType: FilterItem([
            DamageType.Kinetic,
            DamageType.Thermal,
            DamageType.Arc,
            DamageType.Void,
          ], [], open: true),
          FilterType.tierType: FilterItem([
            TierType.Exotic,
            TierType.Superior,
            TierType.Rare,
            TierType.Common,
            TierType.Basic,
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

    /// ARMOR ///
    SearchTabData(
        itemTypes: [
          DestinyItemType.Armor
        ],
        sortOrder: [
          SortParameter(SortParameterType.bucketHash),
          SortParameter(SortParameterType.classType),
          SortParameter(SortParameterType.power, -1),
          SortParameter(SortParameterType.tierType, -1),
          SortParameter(SortParameterType.name),
        ],
        filterData: {
          FilterType.powerLevel: FilterItem(
              [0, DestinyData.maxPowerLevel], [0, DestinyData.maxPowerLevel],
              open: true),
          FilterType.classType: FilterItem([
            DestinyClass.Titan,
            DestinyClass.Hunter,
            DestinyClass.Warlock
          ], [], open: true),
          FilterType.bucketType: FilterItem([
            InventoryBucket.helmet,
            InventoryBucket.gauntlets,
            InventoryBucket.chestArmor,
            InventoryBucket.legArmor,
            InventoryBucket.classArmor,
          ], [], open: true),
          FilterType.tierType: FilterItem([
            TierType.Exotic,
            TierType.Superior,
            TierType.Rare,
            TierType.Common,
            TierType.Basic,
          ], []),
        },
        label: ManifestText<DestinyItemCategoryDefinition>(20,
            uppercase: true,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ))),

    /// QUEST ////
    SearchTabData(
        label: ManifestText<DestinyItemCategoryDefinition>(53,
            uppercase: true,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )),
        filterData: {
          FilterType.itemType: FilterItem([
            DestinyItemType.QuestStep,
            DestinyItemType.Bounty,
          ], [], open: true),
          FilterType.tierType: FilterItem([
            TierType.Exotic,
            TierType.Superior,
            TierType.Rare,
            TierType.Common,
            TierType.Basic,
          ], [], open: true),
        },
        itemTypes: [
          DestinyItemType.Quest,
          DestinyItemType.QuestStep,
          DestinyItemType.Bounty,
        ],
        sortOrder: [
          SortParameter(SortParameterType.type),
          SortParameter(SortParameterType.tierType, -1),
          SortParameter(SortParameterType.name),
        ]),
    //// FLAIR ////
    SearchTabData(
        label: ManifestText<DestinyPresentationNodeDefinition>(3066887728,
            uppercase: true,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )),
        filterData: {
          FilterType.itemType: FilterItem([
            DestinyItemType.Ghost,
            DestinyItemType.Vehicle,
            DestinyItemType.Ship,
            DestinyItemType.Emblem,
          ], [], open: true),
          FilterType.tierType: FilterItem([
            TierType.Exotic,
            TierType.Superior,
            TierType.Rare,
            TierType.Common,
            TierType.Basic,
          ], [], open: true),
        },
        itemTypes: [
          DestinyItemType.Ghost,
          DestinyItemType.Vehicle,
          DestinyItemType.Ship,
          DestinyItemType.Emblem,
        ],
        sortOrder: [
          SortParameter(SortParameterType.type),
          SortParameter(SortParameterType.tierType, -1),
          SortParameter(SortParameterType.name),
        ]),
  ];

  @override
  initState() {
    SelectedPagePersistence.saveLatestScreen(SelectedPagePersistence.search);
    ProfileService().startAutomaticUpdater(Duration(seconds: 30));
    super.initState();
    _tabController = new TabController(vsync: this, length: _tabs.length);
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
    ProfileService().stopAutomaticUpdater();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets screenPadding = MediaQuery.of(context).padding;
    return Scaffold(
        appBar: buildAppBar(context),
        endDrawer: SearchFiltersWidget(
          filterData: currentTabData.filterData,
          onChange: () {
            setState(() {});
          },
        ),
        body: Stack(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
                child: Container(
                    child: TabBarView(
                        controller: _tabController,
                        children: _tabs
                            .map(
                              (tab) => SearchListWidget(
                                    tabData: tab,
                                  ),
                            )
                            .toList()))),
                          SelectedItemsWidget(),
                          Container(height: screenPadding.bottom,)
          ]),
          InventoryNotificationWidget(
            key: Key('inventory_notification_widget'),
            barHeight: 1,
          ),
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
            if (!searchOpened) {
              currentTabData.searchText = "";
            }
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
