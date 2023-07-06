// // @dart=2.9

// import 'package:bungie_api/enums/vendor_item_status.dart';
// import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
// import 'package:bungie_api/models/destiny_unlock_definition.dart';
// import 'package:bungie_api/models/destiny_vendor_definition.dart';
// import 'package:bungie_api/models/destiny_vendor_sale_item_component.dart';
// import 'package:flutter/material.dart';
// import 'package:little_light/core/blocs/language/language.consumer.dart';
// import 'package:little_light/core/theme/littlelight.theme.dart';
// import 'package:little_light/services/manifest/manifest.consumer.dart';
// import 'package:little_light/core/blocs/profile/profile.consumer.dart';
// import 'package:little_light/widgets/common/manifest_image.widget.dart';
// import 'package:little_light/widgets/common/manifest_text.widget.dart';

// class ItemVendorInfoWidget extends StatefulWidget {
//   final DestinyInventoryItemDefinition definition;
//   final DestinyVendorSaleItemComponent sale;
//   final int vendorHash;

//   const ItemVendorInfoWidget({Key key, this.sale, this.vendorHash, this.definition}) : super(key: key);

//   @override
//   State<StatefulWidget> createState() {
//     return ItemVendorInfoState();
//   }
// }

// class ItemVendorInfoState extends State<ItemVendorInfoWidget> with ProfileConsumer, ManifestConsumer {
//   DestinyVendorDefinition vendorDefinition;

//   @override
//   void initState() {
//     super.initState();
//     loadDefinition();
//   }

//   loadDefinition() async {
//     vendorDefinition = await manifest.getDefinition<DestinyVendorDefinition>(widget.vendorHash);
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (vendorDefinition == null) return Container();
//     return Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch, children: [buildFailures(context), buildCost(context)]);
//   }

//   buildCost(BuildContext context) {
//     var costs = widget.sale.costs;
//     // var inventory = profile.getProfileInventory();
//     // var currencies = profile.getProfileCurrencies();
//     return Container(
//         color: Colors.grey.shade900,
//         padding: const EdgeInsets.all(8),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: <Widget>[
//             Expanded(
//                 child: Text(
//               "Cost:".translate(context).toUpperCase(),
//               style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//             ))
//           ].followedBy(costs.map((c) {
//             // var items = inventory.where((i) => i.itemHash == c.itemHash);
//             // var itemsTotal = items.fold<int>(0, (t, i) => t + i.quantity);
//             // var currency =
//             //     currencies.where((curr) => curr.itemHash == c.itemHash);
//             // var total =
//             //     currency.fold<int>(itemsTotal, (t, curr) => t + curr.quantity);
//             // bool isEnough = total >= c.quantity;
//             return Container(
//                 padding: const EdgeInsets.only(left: 8),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: <Widget>[
//                     // Text(
//                     //   "${c.quantity}/$total",
//                     //   style: TextStyle(
//                     //       fontSize: 12,
//                     //       color: isEnough ? Theme.of(context).colorScheme.onSurface : Colors.red.shade300),
//                     // ),
//                     Container(
//                       width: 4,
//                     ),
//                     SizedBox(
//                         width: 18, height: 18, child: ManifestImageWidget<DestinyInventoryItemDefinition>(c.itemHash)),
//                   ],
//                 ));
//           })).toList(),
//         ));
//   }

//   Widget buildFailures(BuildContext context) {
//     if (widget.sale.saleStatus == VendorItemStatus.Success) return Container();
//     List<Widget> messages = [];
//     for (var i in widget.sale?.failureIndexes) {
//       String string = vendorDefinition.failureStrings[i];
//       if (string.isNotEmpty) messages.add(Text(string));
//     }

//     if (messages.isEmpty) {
//       for (var hash in widget.sale?.requiredUnlocks) {
//         messages.add(ManifestText<DestinyUnlockDefinition>(hash));
//       }
//     }

//     if (messages.isEmpty) {
//       messages.addAll(buildCustomFailureMessage(context));
//     }

//     return Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: messages.map((message) {
//           return Container(
//               color: LittleLightTheme.of(context).errorLayers, padding: const EdgeInsets.all(8), child: message);
//         }).toList());
//   }

//   List<Widget> buildCustomFailureMessage(BuildContext context) {
//     List<Widget> messages = [];
//     if (widget.sale.saleStatus.contains(VendorItemStatus.NoInventorySpace)) {
//       messages.add(Text("Not enough space".translate(context)));
//     }
//     if (widget.sale.saleStatus.contains(VendorItemStatus.NoFunds)) {
//       // messages.add(Text("Not enough resources".translate(context)));
//     }
//     if (widget.sale.saleStatus.contains(VendorItemStatus.NoProgression)) {}
//     if (widget.sale.saleStatus.contains(VendorItemStatus.NoUnlock)) {
//       // messages.add(Text("No Unlock".translate(context)));
//     }
//     if (widget.sale.saleStatus.contains(VendorItemStatus.NoQuantity)) {
//       //no message for now
//     }
//     if (widget.sale.saleStatus.contains(VendorItemStatus.OutsidePurchaseWindow)) {
//       messages.add(Text("Outside Purchase Window".translate(context)));
//     }
//     if (widget.sale.saleStatus.contains(VendorItemStatus.NotAvailable)) {
//       messages.add(Text("Not Available".translate(context)));
//     }
//     if (widget.sale.saleStatus.contains(VendorItemStatus.UniquenessViolation)) {
//       messages.add(Text("Can only hold one at a time".translate(context)));
//     }
//     if (widget.sale.saleStatus.contains(VendorItemStatus.UnknownError)) {
//       messages.add(Text("UnknownError".translate(context)));
//     }
//     if (widget.sale.saleStatus.contains(VendorItemStatus.AlreadySelling)) {
//       messages.add(Text("Already Selling".translate(context)));
//     }
//     if (widget.sale.saleStatus.contains(VendorItemStatus.Unsellable)) {
//       messages.add(Text("Unsellable".translate(context)));
//     }
//     if (widget.sale.saleStatus.contains(VendorItemStatus.SellingInhibited)) {
//       messages.add(Text("Selling Inhibited".translate(context)));
//     }
//     if (widget.sale.saleStatus.contains(VendorItemStatus.AlreadyOwned)) {
//       messages.add(Text("Already Owned".translate(context)));
//     }
//     if (widget.sale.saleStatus.contains(VendorItemStatus.DisplayOnly)) {
//       messages.add(Text("Display Only".translate(context)));
//     }
//     return messages;
//   }
// }
