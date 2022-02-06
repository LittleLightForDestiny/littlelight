import 'dart:async';

import 'package:bungie_api/enums/vendor_item_status.dart';
import 'package:bungie_api/models/destiny_faction_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_vendor_category.dart';
import 'package:bungie_api/models/destiny_vendor_component.dart';
import 'package:bungie_api/models/destiny_vendor_definition.dart';
import 'package:bungie_api/models/destiny_vendor_item_definition.dart';
import 'package:bungie_api/models/destiny_vendor_sale_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/pages/vendors/vendor_details.screen.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/notification/notification.package.dart';
import 'package:little_light/services/profile/vendors.service.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

class VendorsListItemWidget extends StatefulWidget {
  final String characterId;

  final DestinyVendorComponent vendor;

  VendorsListItemWidget({Key key, this.characterId, this.vendor}) : super(key: key);

  VendorsListItemWidgetState createState() => VendorsListItemWidgetState();
}

class VendorsListItemWidgetState<T extends VendorsListItemWidget> extends State<T>
    with AutomaticKeepAliveClientMixin, ManifestConsumer, NotificationConsumer {
  DestinyVendorDefinition definition;
  StreamSubscription<NotificationEvent> subscription;
  List<DestinyVendorCategory> _categories;
  Map<String, DestinyVendorSaleItemComponent> _sales;

  int get hash => widget.vendor.vendorHash;

  @override
  void initState() {
    super.initState();
    loadDefinitions();
    subscription = notifications.listen((event) {
      if (event.type == NotificationType.receivedUpdate && mounted) {}
    });
  }

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future<void> loadDefinitions() async {
    definition = await manifest.getDefinition<DestinyVendorDefinition>(widget.vendor.vendorHash);
    var _service = VendorsService();
    _categories = await _service.getVendorCategories(widget.characterId, widget.vendor.vendorHash);
    _sales = await _service.getVendorSales(widget.characterId, widget.vendor.vendorHash);
    if (mounted) {
      setState(() {});
    }
  }

  bool shouldCategoryBeVisible(DestinyVendorCategory category) {
    var def = definition.displayCategories[category.displayCategoryIndex];
    if (def.identifier == 'category_class_misc') {
      return false; //planetary emblems
    }
    if (def.identifier == 'category_preview') {
      return false; //weird items
    }
    if (def.identifier.contains('multipurchase')) {
      return false; //eververse weird bright engrams
    }
    if (def.identifier.contains('categories.featured') && !def.identifier.contains('bright_dust')) {
      return false; //eververse weird menus
    }
    if (def.identifier.contains('categories.campaigns')) {
      return false; //eververse weird menus
    }
    if (def.identifier.contains('categories.seasonal')) {
      return false; //eververse silver stuff
    }
    if (def.identifier.contains('categories.archive')) {
      return false; //eververse silver stuff
    }
    if (def.identifier.contains('categories.events')) {
      return false; //eververse silver stuff
    }

    if (def.identifier.contains('category.ba_materials')) {
      return false; //ada 1 black armory materials
    }

    if (def.identifier.contains('synth_recycle')) {
      return false; //drifter synth recicle
    }

    if (def.identifier.contains('category_pursuits')) {
      return false; //pursuits in general
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (definition == null) {
      return Container(height: 200, color: Theme.of(context).colorScheme.secondaryVariant);
    }
    return Stack(children: [
      Container(
        decoration: BoxDecoration(
            color: LittleLightTheme.of(context).surfaceLayers.layer1,
            border: Border.all(color: LittleLightTheme.of(context).surfaceLayers.layer3, width: 1)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, children: [buildHeader(context), buildContent(context)]),
      ),
      Positioned.fill(
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            VendorDetailsScreen(vendor: widget.vendor, characterId: widget.characterId)),
                  );
                },
              )))
    ]);
  }

  Widget buildHeader(BuildContext context) {
    return Container(
        color: Colors.black,
        height: 72,
        child: Stack(
          children: <Widget>[
            Positioned(top: 0, right: 0, bottom: 0, child: buildHeaderBackground(context)),
            buildHeaderInfo(context)
          ],
        ));
  }

  Widget buildHeaderBackground(BuildContext context) {
    return Stack(fit: StackFit.passthrough, children: [
      QueuedNetworkImage(
        fit: BoxFit.fitHeight,
        imageUrl: BungieApiService.url(definition.displayProperties.largeIcon),
      ),
      Positioned.fill(
          child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: <Color>[Colors.black, Colors.black38],
                      begin: Alignment.centerLeft,
                      end: Alignment.center))))
    ]);
  }

  Widget buildHeaderInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: QueuedNetworkImage(
              imageUrl: BungieApiService.url(definition.displayProperties.mapIcon),
            ),
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
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(height: 2),
              ManifestText<DestinyFactionDefinition>(definition?.factionHash,
                  style: TextStyle(fontWeight: FontWeight.w300)),
            ],
          )
        ],
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    var categories = _categories.where((c) => shouldCategoryBeVisible(c));
    if (categories.length == 0) return Container();
    return Container(
        padding: EdgeInsets.all(8),
        child: Wrap(spacing: 16, runSpacing: 16, children: categories.map((c) => buildCategory(context, c)).toList()));
  }

  Widget buildCategory(BuildContext context, DestinyVendorCategory category) {
    var catDefinition = definition.displayCategories[category.displayCategoryIndex];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          padding: EdgeInsets.only(bottom: 4),
          child: Text(
            catDefinition.displayProperties.name.toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          )),
      Container(height: 8, width: 1),
      buildCategoryItems(context, category)
    ]);
  }

  Widget buildCategoryItems(BuildContext context, DestinyVendorCategory category) {
    return Wrap(
        runSpacing: 4,
        spacing: 4,
        alignment: WrapAlignment.start,
        children: category.itemIndexes.reversed
            .map((index) => buildItem(context, definition.itemList[index], index))
            .toList());
  }

  Widget buildItem(BuildContext context, DestinyVendorItemDefinition item, int index) {
    var sale = _sales["$index"];
    return Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300, width: 1)),
        width: 36,
        height: 36,
        child: Stack(
          children: <Widget>[
            ManifestImageWidget<DestinyInventoryItemDefinition>(item.itemHash, key: Key("item_${item.itemHash}")),
            sale.saleStatus != VendorItemStatus.Success
                ? Positioned.fill(child: Container(color: Colors.black.withOpacity(.6)))
                : Container()
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
