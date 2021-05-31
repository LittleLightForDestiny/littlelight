import 'package:bungie_api/enums/damage_type.dart';
import 'package:bungie_api/enums/destiny_scope.dart';
import 'package:bungie_api/enums/vendor_item_status.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_plug_base.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_sandbox_perk_definition.dart';
import 'package:bungie_api/models/destiny_vendor_item_definition.dart';
import 'package:bungie_api/models/destiny_vendor_sale_item_component.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/screens/item_detail.screen.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/profile/vendors.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/item_icon/item_icon.widget.dart';
import 'package:little_light/widgets/common/item_name_bar/item_name_bar.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/primary_stat.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/common/wishlist_badge.widget.dart';
import 'package:little_light/widgets/item_list/items/base/item_armor_tier.widget.dart';
import 'package:little_light/widgets/item_list/items/base/item_mods.widget.dart';
import 'package:little_light/widgets/item_list/items/base/item_perks.widget.dart';

class PurchasableItemWidget extends StatefulWidget {
  final DestinyVendorItemDefinition item;
  final DestinyVendorSaleItemComponent sale;
  final String characterId;
  final int vendorHash;

  PurchasableItemWidget(
      {this.item, this.sale, this.characterId, this.vendorHash});
  @override
  State<StatefulWidget> createState() {
    return PurchasableItemWidgetState();
  }
}

class PurchasableItemWidgetState extends State<PurchasableItemWidget> {
  DestinyInventoryItemDefinition definition;
  List<DestinyItemSocketState> sockets;
  DestinyItemInstanceComponent instanceInfo;
  bool isUnlocked = false;
  Map<String, List<DestinyItemPlugBase>> reusablePlugs;

  @override
  void initState() {
    super.initState();
    loadDefinitions();
  }

  void loadDefinitions() async {
    definition = await ManifestService()
        .getDefinition<DestinyInventoryItemDefinition>(widget.item.itemHash);
    sockets = await VendorsService().getSaleItemSockets(
        widget.characterId, widget.vendorHash, widget?.item?.vendorItemIndex);
    instanceInfo = await VendorsService().getSaleItemInstanceInfo(
        widget.characterId, widget.vendorHash, widget?.item?.vendorItemIndex);
    reusablePlugs = await VendorsService().getSaleItemReusablePerks(
        widget.characterId, widget.vendorHash, widget?.item?.vendorItemIndex);

    isUnlocked = ProfileService().isCollectibleUnlocked(
        definition.collectibleHash, DestinyScope.Profile);
    if (!isUnlocked) {
      isUnlocked = ProfileService().isCollectibleUnlocked(
          definition.collectibleHash, DestinyScope.Character);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (definition == null)
      return Container(
          color: Colors.grey.shade900, height: iconSize + padding * 2 + 42);
    return Container(
        decoration: BoxDecoration(
            border: Border.all(
          width: 1,
          color: DestinyData.getTierColor(definition.inventory.tierType),
        )),
        child: Stack(children: [
          Column(children: [
            Container(
                height: iconSize + padding * 2 + 8,
                child: Stack(
                    children: <Widget>[
                  background(context),
                  positionedNameBar(context),
                  positionedContent(context),
                  positionedIcon(context),
                ].where((w) => w != null).toList())),
            buildCost(context)
          ]),
          Positioned.fill(child: tapOverlay(context))
        ]));
  }

  Widget tapOverlay(context) {
    bool canBuy = widget.sale.saleStatus == VendorItemStatus.Success;
    return Material(
      color: canBuy ? Colors.transparent : Colors.black.withOpacity(.5),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDetailScreen(
                definition: definition,
                instanceInfo: instanceInfo,
                characterId: widget.characterId,
                socketStates: sockets,
                sale: widget.sale,
                vendorHash: widget.vendorHash,
                vendorItem: widget.item,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget positionedIcon(BuildContext context) {
    return Positioned(
        top: padding,
        left: padding,
        width: iconSize,
        height: iconSize,
        child: itemIconHero(context));
  }

  Widget itemIconHero(BuildContext context) {
    return itemIcon(context);
    // return Hero(
    //   tag: "item_icon_${tag}_$uniqueId",
    //   child: itemIcon(context),
    // );
  }

  itemIcon(BuildContext context) {
    return Stack(children: [
      ItemIconWidget(
        null,
        definition,
        null,
        iconBorderWidth: iconBorderWidth,
      ),
      (widget.item?.quantity ?? 0) > 1
          ? Positioned(
              right: iconBorderWidth,
              bottom: iconBorderWidth,
              child: Container(
                  padding: EdgeInsets.all(4),
                  alignment: Alignment.centerRight,
                  color: Colors.black.withOpacity(.6),
                  child: Text(
                    "x${widget.item.quantity}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  )))
          : Container()
    ]);
  }

  Widget positionedContent(BuildContext context) {
    var top = padding * 3 + titleFontSize;
    return Positioned(
        left: padding * 2 + iconSize,
        top: top,
        bottom: padding,
        right: padding,
        child: content(context));
  }

  Widget content(BuildContext context) {
    if (definition.equippable) {
      return contentEquipment(context);
    }
    if (definition?.inventory?.bucketTypeHash == InventoryBucket.pursuits) {
      return contentQuest(context);
    }
    if (definition.inventory.bucketTypeHash == InventoryBucket.modifications &&
        (definition?.displayProperties?.description?.length ?? 0) == 0) {
      return contentMod(context);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
            child: Text(
          definition.displayProperties.description,
          softWrap: true,
          overflow: TextOverflow.fade,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
        )),
        Container(width: 4),
        buildCount(context)
      ],
    );
  }

  Widget contentEquipment(BuildContext context) {
    var perksCategory = definition.sockets?.socketCategories?.firstWhere(
        (c) =>
            DestinyData.socketCategoryPerkHashes.contains(c.socketCategoryHash),
        orElse: () => null);
    var tierCategory = definition.sockets?.socketCategories?.firstWhere(
        (c) =>
            DestinyData.socketCategoryTierHashes.contains(c.socketCategoryHash),
        orElse: () => null);
    Widget middleContent = Container();
    if (tierCategory != null) {
      middleContent = ItemArmorTierWidget(
        definition: definition,
        itemSockets: sockets,
        iconSize: 24,
        socketCategoryHash: tierCategory?.socketCategoryHash,
      );
    } else if (perksCategory != null) {
      middleContent = ItemPerksWidget(
        definition: definition,
        itemSockets: sockets,
        reusablePlugs: reusablePlugs,
        iconSize: 24,
        showUnusedPerks: true,
        socketCategoryHash: perksCategory?.socketCategoryHash,
      );
    }
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: middleContent),
          Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                PrimaryStatWidget(
                  definition: definition,
                  instanceInfo: instanceInfo,
                ),
                ItemModsWidget(
                  definition: definition,
                  itemSockets: sockets,
                  iconSize: 22,
                ),
              ])
        ]);
  }

  Widget contentQuest(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
            child: Text(
          definition.displayProperties.description,
          softWrap: true,
          overflow: TextOverflow.fade,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
        )),
      ],
    );
  }

  Widget contentMod(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: definition.perks?.map((p) {
                      return ManifestText<DestinySandboxPerkDefinition>(
                        p.perkHash,
                        textExtractor: (def) =>
                            def?.displayProperties?.description,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w300),
                      );
                    })?.toList() ??
                    [])),
        Container(width: 4),
        buildCount(context)
      ],
    );
  }

  buildCount(BuildContext context) {
    int count = 0;
    if (CurrencyConversion.purchaseables.containsKey(definition.hash)) {
      var conversion = CurrencyConversion.purchaseables[definition.hash];
      if (conversion.type == CurrencyConversionType.Currency) {
        var currencies = ProfileService().getProfileCurrencies();
        var currency =
            currencies.where((curr) => curr.itemHash == conversion.hash);
        count = currency.fold<int>(count, (t, curr) => t + curr.quantity);
      } else {
        var inventory = ProfileService().getProfileInventory();
        var items = inventory.where((i) => i.itemHash == conversion.hash);
        count = items.fold<int>(count, (t, i) => t + i.quantity);
      }
    } else {
      var inventory = ProfileService().getProfileInventory();
      var currencies = ProfileService().getProfileCurrencies();
      var items = inventory.where((i) => i.itemHash == definition.hash);
      count = items.fold<int>(count, (t, i) => t + i.quantity);
      var currency =
          currencies.where((curr) => curr.itemHash == definition.hash);
      count = currency.fold<int>(count, (t, curr) => t + curr.quantity);
    }

    return Container(
        padding: EdgeInsets.all(8),
        color: Colors.grey.shade900,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TranslatedTextWidget(
              "Inventory",
              uppercase: true,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Container(height: 4),
            Text('$count')
          ],
        ));
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
                          color: isEnough ? Colors.white : Colors.red.shade300),
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

  Widget positionedNameBar(BuildContext context) {
    return Positioned(left: 0, right: 0, child: itemHeroNamebar(context));
  }

  Widget itemHeroNamebar(BuildContext context) {
    return nameBar(context);
    // return Hero(tag: "item_namebar_${tag}_$uniqueId", child: nameBar(context));
  }

  Widget nameBar(BuildContext context) {
    return ItemNameBarWidget(null, definition, null,
        fontSize: titleFontSize,
        trailing: badges(context),
        padding: EdgeInsets.only(
          left: iconSize + padding * 2,
          top: padding,
          bottom: padding,
          right: padding,
        ));
  }

  Widget badges(BuildContext context) {
    var list = [
      wishlistTags(context),
      collectedBadge(context),
    ].where((element) => element != null).toList();
    if (list.length == 0) return null;
    var spacedList = list.fold<List<Widget>>(
        <Widget>[],
        (previousValue, element) =>
            previousValue + [element, Container(width: 4)]).toList();
    spacedList.removeLast();
    return Row(children: spacedList);
  }

  Widget wishlistTags(BuildContext context) {
    var wishlistTags = WishlistsService().getWishlistBuildTags(
        itemHash: widget.item?.itemHash,
        reusablePlugs: reusablePlugs,
        sockets: sockets);
    if ((wishlistTags?.length ?? 0) == 0) return null;
    return WishlistBadgeWidget(tags: wishlistTags, size: 22);
  }

  Widget collectedBadge(BuildContext context) {
    if (isUnlocked) {
      return Icon(FontAwesomeIcons.solidCheckCircle,
          color: DestinyData.getTierTextColor(definition?.inventory?.tierType),
          size: 18);
    }
    return null;
  }

  background(BuildContext context) {
    return Positioned(
        top: 0,
        left: 0,
        bottom: 0,
        right: 0,
        child: Container(color: Colors.blueGrey.shade900));
  }

  double get iconSize {
    return 80;
  }

  double get iconBorderWidth {
    return 1;
  }

  double get padding {
    return 8;
  }

  Color get defaultTextColor {
    return DestinyData.getDamageTypeColor(DamageType.Kinetic);
  }

  double get titleFontSize {
    return 12;
  }
}
