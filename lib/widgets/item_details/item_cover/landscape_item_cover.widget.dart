import 'dart:math';
import 'dart:ui';
import 'package:bungie_api/enums/destiny_item_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/rendering.dart';
import 'package:little_light/screens/share_preview.screen.dart';
import 'package:little_light/widgets/common/masterwork_counter.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/destiny_item.widget.dart';
import 'package:little_light/widgets/common/item_icon/item_icon.widget.dart';
import 'package:little_light/widgets/common/item_name_bar/item_name_bar.widget.dart';
import 'package:shimmer/shimmer.dart';

class LandscapeItemCoverWidget extends DestinyItemWidget {
  final String uniqueId;

  LandscapeItemCoverWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      String characterId,
      this.uniqueId})
      : super(item, definition, instanceInfo,
            key: key, characterId: characterId);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double paddingTop = MediaQuery.of(context).padding.top;
    double screenshotHeight = width / (16 / 9);
    double minHeight = paddingTop + kToolbarHeight;
    double maxHeight = screenshotHeight;
    if((definition?.screenshot?.length ?? 0) == 0){
      maxHeight = minHeight;
    }
    return SliverPersistentHeader(
        pinned: true,
        delegate: LandscapeItemCoverDelegate(
            item, definition, instanceInfo, tag, uniqueId,
            minHeight: minHeight,
            maxHeight: maxHeight));
  }
}

class LandscapeItemCoverDelegate extends SliverPersistentHeaderDelegate {
  final DestinyItemComponent item;
  final DestinyInventoryItemDefinition definition;
  final DestinyItemInstanceComponent instanceInfo;
  double minHeight;
  double maxHeight;
  String tag;
  String uniqueId;

  LandscapeItemCoverDelegate(
      this.item, this.definition, this.instanceInfo, this.tag, this.uniqueId,
      {this.minHeight = 50, this.maxHeight = 200})
      : super();

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    double expandRatio =
        max(0, 1 - shrinkOffset / (this.maxHeight - this.minHeight));
    if(maxHeight == minHeight){
      expandRatio = 0;
    }
    return Container(
        color: DestinyData.getTierColor(definition.inventory.tierType),
        child: Stack(
          overflow: Overflow.visible,
          fit: StackFit.expand,
          children: <Widget>[
            Container(),
            background(context, expandRatio),
            overlay(context, expandRatio),
            icon(context, expandRatio),
            backButton(context, expandRatio),
          ],
        ));
  }

  Widget backButton(BuildContext context, double expandRatio) {
    double paddingTop = MediaQuery.of(context).padding.top;
    return Positioned(
        left: 0,
        top: paddingTop,
        width: kToolbarHeight,
        height: kToolbarHeight,
        child: BackButton(
            color: Color.lerp(
                DestinyData.getTierTextColor(definition.inventory.tierType),
                Colors.grey.shade300,
                expandRatio)));
  }

  Widget masterworkCounter(BuildContext context, double expandRatio) {
    double leftOffset = lerpDouble(kToolbarHeight * 2 - 16, 104, expandRatio);
    return Positioned(
        left: leftOffset,
        bottom: kToolbarHeight * expandRatio*.8,
        right:kToolbarHeight,
        child: MasterworkCounterWidget(item));
  }

  Widget overlay(BuildContext context, double expandRatio) {
    double width = MediaQuery.of(context).size.width;
    double opacity = expandRatio;
    if (definition.itemType != DestinyItemType.Subclass) {
      return Container();
    }
    return Positioned(
        bottom: kToolbarHeight,
        width: width / 2,
        right: 0,
        child: Opacity(
            opacity: opacity,
            child: QueuedNetworkImage(
              imageUrl: BungieApiService.url(definition.secondaryIcon),
              fit: BoxFit.fitWidth,
            )));
  }

  Widget icon(BuildContext context, double expandRatio) {
    double openSize = proportional(90, context);
    double closedSize = kToolbarHeight - 8;
    double size = lerpDouble(closedSize, openSize, expandRatio);
    double bottom = lerpDouble(4, 8, expandRatio);
    double left = lerpDouble(kTextTabBarHeight, 8, expandRatio);
    return Positioned(
        left: left,
        bottom: bottom,
        width: size,
        height: size,
        child: Hero(
            tag: "item_icon_${tag}_$uniqueId",
            child: ItemIconWidget.builder(
              item,
              definition,
              instanceInfo,
              iconBorderWidth: lerpDouble(1, 2, expandRatio),
            )));
  }

  Widget background(BuildContext context, double expandRatio) {
    double width = MediaQuery.of(context).size.width;
    double opacity = expandRatio;
    String imgUrl = definition.screenshot;
    if (definition.itemType == DestinyItemType.Emblem) {
      imgUrl = definition.secondarySpecial;
    }
    if (definition.itemType == DestinyItemType.QuestStep) {
      imgUrl = definition.secondaryIcon;
    }
    if (imgUrl == null) {
      return Container();
    }
    return Positioned(
        top: 0,
        bottom: 0,
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
  bool shouldRebuild(LandscapeItemCoverDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight;
  }

  double proportional(int value, BuildContext context){
    var screenWidth = MediaQuery.of(context).size.width;
    return (value/1920)*screenWidth;
  }
}
