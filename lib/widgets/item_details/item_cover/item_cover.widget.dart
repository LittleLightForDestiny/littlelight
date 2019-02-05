import 'dart:math';
import 'dart:ui';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/bungie_api/enums/item_type.enum.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/destiny_item.widget.dart';
import 'package:little_light/widgets/common/item_icon/item_icon.widget.dart';
import 'package:little_light/widgets/common/item_name_bar/item_name_bar.widget.dart';
import 'package:shimmer/shimmer.dart';

class ItemCoverWidget extends DestinyItemWidget {
  final String uniqueId;

  ItemCoverWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key
      ,String characterId,
      this.uniqueId})
      : super(item, definition, instanceInfo, key: key, characterId:characterId);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double paddingTop = MediaQuery.of(context).padding.top;
    double screenshotHeight = width / (16 / 9);
    return SliverPersistentHeader(
        pinned: true,
        delegate: ItemCoverDelegate(item, definition, instanceInfo,
        tag, uniqueId,
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
  String tag;
  String uniqueId;

  ItemCoverDelegate(this.item, this.definition, this.instanceInfo, this.tag, this.uniqueId,
      {this.minHeight = 50, this.maxHeight = 200})
      : super();

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
      double expandRatio = max(0 , 1 - shrinkOffset/(this.maxHeight - this.minHeight));
    return Container(
        color: DestinyData.getTierColor(definition.inventory.tierType),
        child: Stack(
          overflow: Overflow.visible,
          fit: StackFit.expand,
          children: <Widget>[
            Container(),
            background(context, expandRatio),
            overlay(context, expandRatio),
            nameBar(context, expandRatio),
            icon(context, expandRatio),
            backButton(context, expandRatio),
          ],
        ));
  }

  Widget nameBar(BuildContext context, double expandRatio) {
    double leftOffset = lerpDouble(kToolbarHeight*2 -16, 104, expandRatio);
    return Positioned(
        left: 0,
        bottom: 0,
        right: 0,
        height: kToolbarHeight,
        child: Hero(
            tag: "item_namebar_${tag}_$uniqueId",
            child: ItemNameBarWidget(
              item,
              definition,
              instanceInfo,
              multiline: true,
              padding: EdgeInsets.only(
                  left: leftOffset + 8,
                  right:8,
                  top: (kToolbarHeight - 16) / 2,
                  bottom: (kToolbarHeight - 16) / 2),
              fontSize: 16,
            )));
  }

  Widget icon(BuildContext context, double expandRatio) {
    double size = lerpDouble(kToolbarHeight -8, 96, expandRatio);
    double bottom = lerpDouble(4, 8, expandRatio);
    double left = lerpDouble(kTextTabBarHeight, 8, expandRatio);
    return Positioned(
        left: left,
        bottom: bottom,
        width: size,
        height: size,
        child: Hero(
            tag: "item_icon_${tag}_$uniqueId",
            child: 
            ItemIconWidget.builder(item, definition, instanceInfo,
            iconBorderWidth: lerpDouble(1, 2, expandRatio),
            )));
  }

  Widget backButton(BuildContext context, double expandRatio) {
    double paddingTop = MediaQuery.of(context).padding.top;
    return Positioned(
        left: 0,
        top: paddingTop,
        width: kToolbarHeight,
        height: kToolbarHeight,
        child: BackButton(
            color:Color.lerp(DestinyData.getTierTextColor(definition.inventory.tierType), Colors.grey.shade300, expandRatio)
                ));
  }

  Widget overlay(BuildContext context, double expandRatio) {
    double width = MediaQuery.of(context).size.width;
    double opacity = expandRatio;
    if(definition.itemType != ItemType.subclasses){
      return Container();
    }
    return Positioned(
        bottom: kToolbarHeight,
        width: width/2,
        right:0,
        child: Opacity(
            opacity: opacity,
            child: QueuedNetworkImage(
                imageUrl: BungieApiService.url(definition.secondaryIcon),
                fit: BoxFit.fitWidth,
                )));
  }

  Widget background(BuildContext context, double expandRatio) {
    double width = MediaQuery.of(context).size.width;
    double opacity = expandRatio;
    String imgUrl = definition.screenshot;
    if(definition.itemType == ItemType.emblems){
      imgUrl = definition.secondarySpecial;
    }
    if(imgUrl == null){
      return Container();
    }
    return Positioned(
        top: 0,
        bottom: kToolbarHeight,
        width: width,
        child: Opacity(
            opacity: opacity,
            child: QueuedNetworkImage(
                imageUrl: BungieApiService.url(imgUrl),
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
