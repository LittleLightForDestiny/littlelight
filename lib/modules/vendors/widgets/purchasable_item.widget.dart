import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/blocs/vendors/vendor_item_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/tier_type_data.dart';
import 'package:little_light/shared/widgets/inventory_item/high_density_inventory_item.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:provider/provider.dart';

const _titleBarHeight = 32.0;

class PurchasableItemWidget extends HighDensityInventoryItem {
  final VendorItemInfo item;

  const PurchasableItemWidget(this.item) : super(item);

  @override
  Widget buildForeground(BuildContext context, DestinyInventoryItemDefinition? definition) {
    return Column(children: [
      Container(height: 96.0, child: super.buildForeground(context, definition)),
      Expanded(child: buildCost(context)),
    ]);
  }

  @override
  Widget buildTitleBarContents(BuildContext context, DestinyInventoryItemDefinition? definition) {
    return SizedBox(
      height: _titleBarHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: buildItemName(context, definition)),
          buildHeaderWishlistIcons(context, definition),
          buildCollectedBadge(context),
        ].whereType<Widget>().toList(),
      ),
    );
  }

  Widget? buildCollectedBadge(BuildContext context) {
    final definition = context.definition<DestinyInventoryItemDefinition>(item.itemHash);
    final collectibleHash = definition?.collectibleHash;
    final collectibleDefinition = context.definition<DestinyCollectibleDefinition>(definition?.collectibleHash);
    final scope = collectibleDefinition?.scope;
    if (collectibleHash == null || scope == null) return null;
    final isUnlocked = context.watch<ProfileBloc>().isCollectibleUnlocked(collectibleHash, scope);
    if (isUnlocked) {
      return Container(
        margin: EdgeInsets.only(right: 4),
        child: Icon(
          FontAwesomeIcons.solidCircleCheck,
          color: definition?.inventory?.tierType?.getTextColor(context),
          size: 18,
        ),
      );
    }
    return null;
  }

  Widget? buildEngramMainInfo(BuildContext context, DestinyInventoryItemDefinition definition) {
    final item = this.item;
    final itemLevel = item.instanceInfo?.itemLevel;
    final quality = item.instanceInfo?.quality ?? 0;
    if (itemLevel == null) return null;
    final level = itemLevel * 10 + quality;
    final textStyle = context.textTheme.itemPrimaryStatHighDensity;
    return Text(
      "$level",
      style: textStyle,
    );
  }

  Widget tapOverlay(context) {
    return Container();
    // bool canBuy = sale.saleStatus == VendorItemStatus.Success;
    // return Material(
    //   color: canBuy ? Colors.transparent : Colors.black.withOpacity(.5),
    //   child: InkWell(
    //     onTap: () {
    //       Navigator.push(
    //         context,
    //         ItemDetailsPageRoute.fromVendor(
    //           instanceInfo: instanceInfo,
    //           characterId: characterId,
    //           vendorHash: vendorHash,
    //           vendorItem: sale,
    //         ),
    //       );
    //     },
    //   ),
    // );
  }

  Widget buildCost(BuildContext context) {
    final costs = item.costs;
    // final inventory = profile.getProfileInventory();
    // var currencies = profile.getProfileCurrencies();
    return Container(
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers,
      ),
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.all(4),
      child: costs != null && costs.isNotEmpty
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                  Text(
                    "Cost:".translate(context).toUpperCase(),
                    style: context.textTheme.highlight,
                  ),
                  buildCostCurrencies(context),
                ])
          : null,
    );
  }

  Widget buildCostCurrencies(BuildContext context) {
    final costs = item.costs;
    if (costs == null) return Container();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        for (final c in costs)
          Container(
            margin: EdgeInsets.only(left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  child: ManifestImageWidget<DestinyInventoryItemDefinition>(c.itemHash),
                ),
                Text("${c.quantity}"),
              ],
            ),
          )
      ]),
    );
  }

  // .followedBy(costs.map((c) {
  //           var items = inventory.where((i) => i.itemHash == c.itemHash);
  //           var itemsTotal = items.fold<int>(0, (t, i) => t + i.quantity);
  //           var currency = currencies.where((curr) => curr.itemHash == c.itemHash);
  //           var total = currency.fold<int>(itemsTotal, (t, curr) => t + curr.quantity);
  //           bool isEnough = total >= c.quantity;
  //           return Container(
  //               padding: const EdgeInsets.only(left: 8),
  //               child: Row(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: <Widget>[
  //                   Text(
  //                     "${c.quantity}/$total",
  //                     style: TextStyle(
  //                         fontSize: 12,
  //                         color: isEnough ? Theme.of(context).colorScheme.onSurface : Colors.red.shade300),
  //                   ),
  //                   Container(
  //                     width: 4,
  //                   ),
  //                   SizedBox(
  //                       width: 18, height: 18, child: ManifestImageWidget<DestinyInventoryItemDefinition>(c.itemHash)),
  //                 ],
  //               ));
  //         })).toList(),
}
