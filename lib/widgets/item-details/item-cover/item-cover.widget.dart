import 'dart:math';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie-api/bungie-api.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/destiny-item.widget.dart';
import 'package:little_light/widgets/common/item-icon/item-icon.widget.dart';
import 'package:little_light/widgets/common/item-name-bar/item-name-bar.widget.dart';
import 'package:shimmer/shimmer.dart';

class ItemCoverWidget extends DestinyItemWidget {
  ItemCoverWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key})
      : super(item, definition, instanceInfo, key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double paddingTop = MediaQuery.of(context).padding.top;
    double screenshotHeight = width / (16 / 9);
    return SliverPersistentHeader(
        pinned: true,
        delegate: ItemCoverDelegate(item, definition, instanceInfo,
            minHeight: paddingTop + kToolbarHeight,
            maxHeight: kToolbarHeight + screenshotHeight));
  }
}

class ItemCoverDelegate extends SliverPersistentHeaderDelegate {
  final DestinyItemComponent item;
  final DestinyInventoryItemDefinition definition;
  final DestinyItemInstanceComponent instanceInfo;
  double minHeight;
  double maxHeight;

  ItemCoverDelegate(this.item, this.definition, this.instanceInfo,
      {this.minHeight = 50, this.maxHeight = 200})
      : super();

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        color: DestinyData.getTierColor(definition.inventory.tierType),
        child: Stack(
          overflow: Overflow.visible,
          fit: StackFit.expand,
          children: <Widget>[
            background(context, shrinkOffset),
            nameBar(context, shrinkOffset),
            icon(context, shrinkOffset),
            backButton(context),
          ],
        ));
  }

  Widget nameBar(BuildContext context, double shrinkOffset){
    double leftOffset = 112 + (shrinkOffset/this.maxHeight)*-(112 - kToolbarHeight);
    return Positioned(
        left:0,
        bottom: 0,
        right:0,
        height: kToolbarHeight,
        child: Hero(
            tag: "item_namebar_${item.itemInstanceId}_${item.itemHash}",
            child: ItemNameBarWidget(item, definition, instanceInfo,
            padding:EdgeInsets.only(left:leftOffset + 8, top:(kToolbarHeight -16) /2, bottom: (kToolbarHeight -16) /2),
            fontSize: 16,)));
  }

  Widget icon(BuildContext context, double shrinkOffset) {
    double leftOffset = 8 + (shrinkOffset/this.maxHeight)*-112;
    return Positioned(
        left:8,
        bottom: leftOffset,
        width: 96,
        height: 96,
        child: Hero(
            tag: "item_icon_${item.itemInstanceId}_${item.itemHash}",
            child: ItemIconWidget.builder(item, definition, instanceInfo)));
  }

  Widget backButton(BuildContext context) {
    double paddingTop = MediaQuery.of(context).padding.top;
    return Positioned(
        left: 0,
        top: paddingTop,
        width: kToolbarHeight,
        height: kToolbarHeight,
        child: BackButton(
            color:
                DestinyData.getTierTextColor(definition.inventory.tierType)));
  }

  Widget background(BuildContext context, double shrinkOffset) {
    double width = MediaQuery.of(context).size.width;
    double opacity = max(min(1.5 - (shrinkOffset/this.maxHeight)*2, 1), 0);
    return Positioned(
        top: 0,
        bottom: kToolbarHeight,
        width: width,
        child: Opacity(
            opacity: opacity,
            child: CachedNetworkImage(
                imageUrl: "${BungieApiService.baseUrl}${definition.screenshot}",
                fit: BoxFit.cover,
                placeholder: Shimmer.fromColors(
                    baseColor: Colors.blueGrey.shade500,
                    highlightColor: Colors.grey.shade300,
                    child: Container(color: Colors.white)))));
  }

  @override
  double get maxExtent => this.maxHeight;

  @override
  double get minExtent => this.minHeight;

  @override
  bool shouldRebuild(ItemCoverDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight;
  }
}
