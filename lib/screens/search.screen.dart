import 'package:bungie_api/enums/damage_type_enum.dart';
import 'package:bungie_api/enums/destiny_class_enum.dart';
import 'package:bungie_api/enums/tier_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';

import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/user_settings/item_sort_parameter.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/inventory_tabs/selected_items.widget.dart';
import 'package:little_light/widgets/item_list/search_list.widget.dart';
import 'package:little_light/widgets/search/search_filters.widget.dart';
import 'package:bungie_api/enums/destiny_item_type_enum.dart';
import 'package:bungie_api/enums/destiny_item_sub_type_enum.dart';
import 'package:bungie_api/enums/destiny_ammunition_type_enum.dart';

class SearchTabData {
  String searchText = "";
  List<int> itemTypes;
  String ownerId;
  List<int> excludeItemTypes;
  Map<FilterType, FilterItem> filterData;
  List<ItemSortParameter> sortOrder;
  SearchTabData(
      {this.itemTypes, this.excludeItemTypes, this.filterData, this.sortOrder, this.ownerId});

  factory SearchTabData.weapons() => SearchTabData(
        itemTypes: [DestinyItemType.Weapon],
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
      );

  factory SearchTabData.armor([int classType]) => SearchTabData(
        itemTypes: [DestinyItemType.Armor],
        filterData: {
          FilterType.powerLevel: FilterItem(
              [0, DestinyData.maxPowerLevel], [0, DestinyData.maxPowerLevel],
              open: true),
          FilterType.classType: FilterItem([
            DestinyClass.Titan,
            DestinyClass.Hunter,
            DestinyClass.Warlock
          ], classType != null ? [classType] : [], open: true),
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
      );

  factory SearchTabData.pursuits([String ownerId]) => SearchTabData(
          ownerId: ownerId,
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
          ]);

  factory SearchTabData.flair() => SearchTabData(
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
          ]);
}

class SearchScreen extends StatefulWidget {
  final SearchTabData tabData;
  SearchScreen({Key key, this.tabData}) : super(key: key);

  @override
  SearchScreenState createState() => new SearchScreenState();
}

class SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  Map<int, DestinyInventoryItemDefinition> perkDefinitions;
  TextEditingController _searchFieldController = new TextEditingController();

  @override
  initState() {
    super.initState();
    _searchFieldController.text = widget.tabData.searchText;
    _searchFieldController.addListener(() {
      widget.tabData.searchText = _searchFieldController.text;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets screenPadding = MediaQuery.of(context).padding;
    return Scaffold(
        appBar: buildAppBar(context),
        endDrawer: SearchFiltersWidget(
          filterData: widget.tabData.filterData,
          onChange: () {
            setState(() {});
          },
        ),
        body: Stack(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
                child: SearchListWidget(
              tabData: widget.tabData,
            )),
            SelectedItemsWidget(),
            Container(
              height: screenPadding.bottom,
            )
          ]),
          InventoryNotificationWidget(
            key: Key('inventory_notification_widget'),
            barHeight: 0,
          ),
        ]));
  }

  buildAppBar(BuildContext context) {
    return AppBar(
      title: buildAppBarTitle(context),
      elevation: 2,
      actions: <Widget>[
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

  buildAppBarTitle(BuildContext context) {
    return TextField(
      autofocus: UserSettingsService().autoOpenKeyboard,
      controller: _searchFieldController,
    );
  }
}
