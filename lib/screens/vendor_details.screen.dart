import 'package:bungie_api/models/destiny_destination_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_vendor_component.dart';
import 'package:bungie_api/models/destiny_vendor_definition.dart';
import 'package:bungie_api/models/destiny_vendor_category.dart';
import 'package:bungie_api/models/destiny_vendor_item_definition.dart';
import 'package:bungie_api/models/destiny_vendor_sale_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/profile/vendors.service.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/vendors/purchasable_item.widget.dart';

class VendorDetailsScreen extends StatefulWidget {
  final ProfileService profile = ProfileService();
  final ManifestService manifest = ManifestService();

  final String characterId;
  final DestinyVendorComponent vendor;

  VendorDetailsScreen({Key key, this.vendor, this.characterId})
      : super(key: key);

  @override
  VendorDetailsScreenState createState() => new VendorDetailsScreenState();
}

class VendorDetailsScreenState extends State<VendorDetailsScreen> {
  DestinyInventoryItemDefinition emblemDefinition;
  DestinyVendorDefinition definition;
  List<DestinyVendorCategory> _categories;
  Map<String, DestinyVendorSaleItemComponent> _sales;

  @override
  initState() {
    super.initState();
    loadDefinitions();
  }

  Future<void> loadDefinitions() async {
    definition = await widget.manifest
        .getDefinition<DestinyVendorDefinition>(widget.vendor.vendorHash);
    var _service = VendorsService();
    _categories = await _service.getVendorCategories(
        widget.characterId, widget.vendor.vendorHash);
    _sales = await _service.getVendorSales(
        widget.characterId, widget.vendor.vendorHash);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueGrey.shade800,
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
    var location = definition.locations[widget.vendor.vendorLocationIndex];
    return Container(
        child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        QueuedNetworkImage(
          imageUrl: BungieApiService.url(definition.displayProperties.icon),
        ),
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
            ManifestText<DestinyDestinationDefinition>(location.destinationHash,
                style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14)),
          ],
        )
      ],
    ));
  }

  Widget buildBody(BuildContext context) {
    if (definition == null || _categories == null) return Container();
    var categories = _categories.where((c) => shouldCategoryBeVisible(c));
    return ListView(
        padding: EdgeInsets.all(8),
        children: categories.map((c) => buildCategory(context, c)).toList());
  }

  bool shouldCategoryBeVisible(DestinyVendorCategory category) {
    var def = definition.displayCategories[category.displayCategoryIndex];
    if (def.identifier == 'category_preview') {
      return false;
    }
    if (def.identifier.contains('categories.featured')) {
      return false; //eververse weird menus
    }
    return true;
  }

  Widget buildCategory(BuildContext context, DestinyVendorCategory category) {
    var def = definition.displayCategories[category.displayCategoryIndex];
    return Column(children: [
      HeaderWidget(
          alignment: Alignment.centerLeft,
          child: Text(
            def?.displayProperties?.name?.toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
      Container(height:8),
      buildCategoryItems(context, category)
    ]);
  }

  Widget buildCategoryItems(
      BuildContext context, DestinyVendorCategory category) {
    return Wrap(
        runSpacing: 8,
        spacing: 8,
        alignment: WrapAlignment.start,
        children: category.itemIndexes
            .map((index) =>
                buildItem(context, definition.itemList[index], index))
            .toList());
  }

  Widget buildItem(
      BuildContext context, DestinyVendorItemDefinition item, int index) {
    var sale = _sales["$index"];
    return PurchasableItemWidget(item:item, sale:sale, characterId: widget.characterId, vendorHash: definition.hash,);
  }
}
