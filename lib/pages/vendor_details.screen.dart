import 'dart:math';

import 'package:bungie_api/models/destiny_faction_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_vendor_category.dart';
import 'package:bungie_api/models/destiny_vendor_component.dart';
import 'package:bungie_api/models/destiny_vendor_definition.dart';
import 'package:bungie_api/models/destiny_vendor_item_definition.dart';
import 'package:bungie_api/models/destiny_vendor_sale_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/vendors.service.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/vendors/purchasable_item.widget.dart';

class VendorDetailsScreen extends StatefulWidget {

  
  final String characterId;
  final DestinyVendorComponent vendor;

  VendorDetailsScreen({Key key, this.vendor, this.characterId})
      : super(key: key);

  @override
  VendorDetailsScreenState createState() => new VendorDetailsScreenState();
}

class VendorDetailsScreenState extends State<VendorDetailsScreen> with ManifestConsumer{
  DestinyInventoryItemDefinition emblemDefinition;
  DestinyVendorDefinition definition;
  List<DestinyVendorCategory> _categories;
  Map<String, DestinyVendorSaleItemComponent> _sales;
  final categoryIdsPriority = ["bright_dust"];

  @override
  initState() {
    super.initState();
    loadDefinitions();
  }

  Future<void> loadDefinitions() async {
    definition = await manifest
        .getDefinition<DestinyVendorDefinition>(widget.vendor.vendorHash);
    var _service = VendorsService();
    _categories = await _service.getVendorCategories(
        widget.characterId, widget.vendor.vendorHash);
    _categories = _categories.where((c) => shouldCategoryBeVisible(c)).toList();
    _categories.sort((a, b) {
      var defA = definition.displayCategories[a.displayCategoryIndex];
      var defB = definition.displayCategories[b.displayCategoryIndex];
      var priorityA = categoryIdsPriority
          .indexWhere((element) => defA.identifier.contains(element));
      var priorityB = categoryIdsPriority
          .indexWhere((element) => defB.identifier.contains(element));
      if (priorityA == -1) priorityA = 9999;
      if (priorityB == -1) priorityB = 9999;
      var compare = priorityA.compareTo(priorityB);
      if (compare != 0) return compare;
      return defA.sortOrder.index.compareTo(defB.sortOrder.index);
    });
    _sales = await _service.getVendorSales(
        widget.characterId, widget.vendor.vendorHash);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            titleSpacing: 0,
            title: buildAppBarTitle(context),
            flexibleSpace: buildAppBarBackground(context)),
        body: buildBody(context));
  }

  buildAppBarBackground(BuildContext context) {
    if (definition == null) return Container();
    return Container(
        color: Colors.black,
        alignment: Alignment.centerRight,
        child: Stack(fit: StackFit.loose, children: [
          QueuedNetworkImage(
            fit: BoxFit.fitHeight,
            imageUrl:
                BungieApiService.url(definition.displayProperties.largeIcon),
          ),
          Positioned.fill(
              child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: <Color>[Colors.black, Colors.black38],
                          begin: Alignment.centerLeft,
                          end: Alignment.center))))
        ]));
  }

  buildAppBarTitle(BuildContext context) {
    if (definition == null) return Container();
    return Container(
        child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
            padding: EdgeInsets.all(8),
            child: AspectRatio(
              aspectRatio: 1,
              child: QueuedNetworkImage(
                imageUrl:
                    BungieApiService.url(definition.displayProperties.mapIcon),
              ),
            )),
        Container(
          width: 8,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              definition?.displayProperties?.name?.toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Container(height: 2),
            ManifestText<DestinyFactionDefinition>(definition?.factionHash,
                style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14)),
          ],
        ),
      ],
    ));
  }

  Widget buildBody(BuildContext context) {
    if (definition == null || _categories == null) return Container();
    var screenPadding = MediaQuery.of(context).padding;
    return ListView(
        padding: EdgeInsets.all(8).copyWith(
            left: max(screenPadding.left, 8),
            right: max(screenPadding.right, 8),
            bottom: screenPadding.bottom + 8),
        children: _categories.map((c) => buildCategory(context, c)).toList());
  }

  bool shouldCategoryBeVisible(DestinyVendorCategory category) {
    var def = definition.displayCategories[category.displayCategoryIndex];
    if (def.identifier == 'category_preview') {
      return false;
    }
    if (def.identifier.contains('categories.featured') &&
        !def.identifier.contains('bright_dust')) {
      return false; //eververse weird menus
    }
    return true;
  }

  Widget buildCategory(BuildContext context, DestinyVendorCategory category) {
    var def = definition.displayCategories[category.displayCategoryIndex];
    return Column(children: [
      HeaderWidget(
          child: Text(
        def?.displayProperties?.name?.toUpperCase(),
      )),
      Container(height: 8),
      buildCategoryItems(context, category)
    ]);
  }

  Widget buildCategoryItems(
      BuildContext context, DestinyVendorCategory category) {
    return Wrap(
        runSpacing: 8,
        spacing: 8,
        alignment: WrapAlignment.start,
        children: category.itemIndexes.reversed
            .map((index) =>
                buildItem(context, definition.itemList[index], index))
            .toList());
  }

  Widget buildItem(
      BuildContext context, DestinyVendorItemDefinition item, int index) {
    var sale = _sales["$index"];
    return PurchasableItemWidget(
      item: item,
      sale: sale,
      characterId: widget.characterId,
      vendorHash: definition.hash,
    );
  }
}
