import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_unlock_definition.dart';
import 'package:bungie_api/models/destiny_vendor_definition.dart';
import 'package:bungie_api/models/destiny_vendor_sale_item_component.dart';
import 'package:bungie_api/enums/vendor_item_status.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class ItemVendorInfoWidget extends StatefulWidget {
  final DestinyInventoryItemDefinition definition;
  final DestinyVendorSaleItemComponent sale;
  final int vendorHash;

  ItemVendorInfoWidget({Key key, this.sale, this.vendorHash, this.definition})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ItemVendorInfoState();
  }
}

class ItemVendorInfoState extends State<ItemVendorInfoWidget> {
  DestinyVendorDefinition vendorDefinition;

  @override
  void initState() {
    super.initState();
    loadDefinition();
  }

  loadDefinition() async {
    vendorDefinition = await ManifestService()
        .getDefinition<DestinyVendorDefinition>(widget.vendorHash);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (vendorDefinition == null) return Container();
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [buildFailures(context), buildCost(context)]);
  }

  buildCost(BuildContext context) {
    var costs = widget.sale.costs;
    var inventory = ProfileService().getProfileInventory();
    var currencies = ProfileService().getProfileCurrencies();
    return Container(
        color: Colors.grey.shade900,
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: TranslatedTextWidget(
              "Cost:",
              uppercase: true,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ))
          ].followedBy(costs.map((c) {
            var items = inventory.where((i) => i.itemHash == c.itemHash);
            var itemsTotal = items.fold<int>(0, (t, i) => t + i.quantity);
            var currency =
                currencies.where((curr) => curr.itemHash == c.itemHash);
            var total =
                currency.fold<int>(itemsTotal, (t, curr) => t + curr.quantity);
            bool isEnough = total >= c.quantity;
            return Container(
                padding: EdgeInsets.only(left: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "${c.quantity}/$total",
                      style: TextStyle(
                          fontSize: 12,
                          color: isEnough ? Theme.of(context).colorScheme.onSurface : Colors.red.shade300),
                    ),
                    Container(
                      width: 4,
                    ),
                    Container(
                        width: 18,
                        height: 18,
                        child:
                            ManifestImageWidget<DestinyInventoryItemDefinition>(
                                c.itemHash)),
                  ],
                ));
          })).toList(),
        ));
  }

  Widget buildFailures(BuildContext context) {
    if (widget.sale.saleStatus == VendorItemStatus.Success) return Container();
    List<Widget> messages = [];
    widget.sale?.failureIndexes?.forEach((i) {
      String string = vendorDefinition.failureStrings[i];
      if (string.length > 0) messages.add(Text(string));
    });

    if (messages.length == 0) {
      widget.sale?.requiredUnlocks?.forEach((hash) {
        messages.add(ManifestText<DestinyUnlockDefinition>(hash));
      });
    }

    if (messages.length == 0) {
      messages.addAll(buildCustomFailureMessage(context));
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: messages.map((message) {
          return Container(
              color: DestinyData.negativeFeedback,
              padding: EdgeInsets.all(8),
              child: message);
        }).toList());
  }

  List<Widget> buildCustomFailureMessage(BuildContext context) {
    List<Widget> messages = [];
    if (widget.sale.saleStatus.contains(VendorItemStatus.NoInventorySpace)) {
      messages.add(TranslatedTextWidget("Not enough space"));
    }
    if (widget.sale.saleStatus.contains(VendorItemStatus.NoFunds)) {
      // messages.add(TranslatedTextWidget("Not enough resources"));
    }
    if (widget.sale.saleStatus.contains(VendorItemStatus.NoProgression)) {}
    if (widget.sale.saleStatus.contains(VendorItemStatus.NoUnlock)) {
      // messages.add(TranslatedTextWidget("No Unlock"));
    }
    if (widget.sale.saleStatus.contains(VendorItemStatus.NoQuantity)) {
      //no message for now
    }
    if (widget.sale.saleStatus
        .contains(VendorItemStatus.OutsidePurchaseWindow)) {
      messages.add(TranslatedTextWidget("Outside Purchase Window"));
    }
    if (widget.sale.saleStatus.contains(VendorItemStatus.NotAvailable)) {
      messages.add(TranslatedTextWidget("Not Available"));
    }
    if (widget.sale.saleStatus.contains(VendorItemStatus.UniquenessViolation)) {
      messages.add(TranslatedTextWidget("Can only hold one at a time"));
    }
    if (widget.sale.saleStatus.contains(VendorItemStatus.UnknownError)) {
      messages.add(TranslatedTextWidget("UnknownError"));
    }
    if (widget.sale.saleStatus.contains(VendorItemStatus.AlreadySelling)) {
      messages.add(TranslatedTextWidget("Already Selling"));
    }
    if (widget.sale.saleStatus.contains(VendorItemStatus.Unsellable)) {
      messages.add(TranslatedTextWidget("Unsellable"));
    }
    if (widget.sale.saleStatus.contains(VendorItemStatus.SellingInhibited)) {
      messages.add(TranslatedTextWidget("Selling Inhibited"));
    }
    if (widget.sale.saleStatus.contains(VendorItemStatus.AlreadyOwned)) {
      messages.add(TranslatedTextWidget("Already Owned"));
    }
    if (widget.sale.saleStatus.contains(VendorItemStatus.DisplayOnly)) {
      messages.add(TranslatedTextWidget("Display Only"));
    }
    return messages;
  }
}
