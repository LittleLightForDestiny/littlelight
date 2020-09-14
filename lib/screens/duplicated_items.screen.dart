import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_category_definition.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/services/bungie_api/enums/destiny_item_category.enum.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/refresh_button.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/inventory_tabs/selected_items.widget.dart';
import 'package:little_light/widgets/item_list/duplicated_item_list.widget.dart';

class DuplicatedItemsScreen extends StatefulWidget {
  @override
  DuplicatedItemsScreenState createState() => new DuplicatedItemsScreenState();
}

class DuplicatedItemsScreenState extends State<DuplicatedItemsScreen>
    with SingleTickerProviderStateMixin {
  bool searchOpen = false;
  TextEditingController _searchFieldController = new TextEditingController();
  Map<int, DestinyInventoryItemDefinition> perkDefinitions;
  TabController _tabController;

  List<DuplicatedItemsListData> _tabsData = [
    DuplicatedItemsListData(DestinyItemCategory.Weapon, [
      InventoryBucket.kineticWeapons,
      InventoryBucket.energyWeapons,
      InventoryBucket.powerWeapons
    ]),
    DuplicatedItemsListData(DestinyItemCategory.Armor, [
      InventoryBucket.helmet,
      InventoryBucket.gauntlets,
      InventoryBucket.chestArmor,
      InventoryBucket.legArmor,
      InventoryBucket.classArmor
    ]),
    DuplicatedItemsListData(DestinyItemCategory.Inventory, [
      InventoryBucket.ghost,
      InventoryBucket.vehicle,
      InventoryBucket.ships,
    ]),
  ];

  @override
  initState() {
    super.initState();
    ProfileService().updateComponents = ProfileComponentGroups.basicProfile;
    _tabController = new TabController(vsync: this, length: _tabsData.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenPadding = MediaQuery.of(context).padding;
    return Scaffold(
        appBar: buildAppBar(context),
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
                child: TabBarView(
                    controller: _tabController,
                    children: _tabsData
                        .map(
                          (tab) => DuplicatedItemListWidget(
                            data: tab,
                          ),
                        )
                        .toList())),
            SelectedItemsWidget(),
            Container(height: screenPadding.bottom)
          ]),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.blueGrey.shade900,
                  borderRadius: BorderRadius.circular(18)),
              width: 36,
              height: 36,
              child: RefreshButtonWidget(),
            ),
          ),
        ]));
  }

  buildAppBar(BuildContext context) {
    return AppBar(
      title: buildAppBarTitle(context),
      elevation: 2,
      leading: IconButton(
        enableFeedback: false,
        icon: Icon(Icons.menu),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      actions: [buildSearchButton(context)],
      titleSpacing: 0,
    );
  }

  Widget buildSearchButton(BuildContext context) {
    return IconButton(
        enableFeedback: false,
        icon: searchOpen
            ? Icon(FontAwesomeIcons.times)
            : Icon(FontAwesomeIcons.search),
        onPressed: () async {
          searchOpen = !searchOpen;
          if (!searchOpen) {
            _searchFieldController.text = "";
          }
          setState(() {});
        });
  }

  List<Widget> buildTabButtons(BuildContext context) {
    return _tabsData.map((tab) {
      return buildTabButton(
          context,
          ManifestText<DestinyItemCategoryDefinition>(tab.category,
              style: TextStyle(fontWeight: FontWeight.w700)));
    }).toList();
  }

  Widget buildTabButton(BuildContext context, Widget label) {
    return Container(padding: EdgeInsets.all(8), child: label);
  }

  buildAppBarTitle(BuildContext context) {
    if (searchOpen) {
      return TextField(
        autofocus: true,
        controller: _searchFieldController,
      );
    }
    return TranslatedTextWidget(
      "Duplicated Items",
      overflow: TextOverflow.fade,
    );
  }
}
