import 'dart:math';
import 'dart:ui';
import 'package:bungie_api/enums/destiny_item_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/rendering.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateless_item.widget.dart';
import 'package:little_light/widgets/common/item_icon/item_icon.widget.dart';
import 'package:little_light/widgets/item_sockets/screenshot_item_mods.widget.dart';
import 'package:little_light/widgets/item_sockets/screenshot_item_perks.widget.dart';
import 'package:little_light/widgets/item_stats/screenshot_item_stats.widget.dart';
import 'package:shimmer/shimmer.dart';

class LandscapeItemCoverWidget extends DestinyItemWidget {
  final String uniqueId;
  final Map<int, DestinyInventoryItemDefinition> plugDefinitions;
  final Map<int, int> selectedPerkHashes;

  LandscapeItemCoverWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      String characterId,
      this.uniqueId,
      this.selectedPerkHashes,
      this.plugDefinitions})
      : super(item, definition, instanceInfo,
            key: key, characterId: characterId);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double paddingTop = MediaQuery.of(context).padding.top;
    double screenshotHeight = width / (16 / 9);
    double minHeight = paddingTop + kToolbarHeight;
    double maxHeight = screenshotHeight;
    if ((definition?.screenshot?.length ?? 0) == 0) {
      maxHeight = minHeight;
    }
    return SliverPersistentHeader(
        pinned: true,
        delegate: LandscapeItemCoverDelegate(
            item, definition, instanceInfo, tag, uniqueId,
            plugDefinitions: plugDefinitions,
            selectedPerkHashes: selectedPerkHashes,
            minHeight: minHeight,
            maxHeight: maxHeight));
  }
}

class LandscapeItemCoverDelegate extends SliverPersistentHeaderDelegate {
  final DestinyItemComponent item;
  final DestinyInventoryItemDefinition definition;
  final DestinyItemInstanceComponent instanceInfo;
  final double minHeight;
  final double maxHeight;
  final String tag;
  final String uniqueId;
  final Map<int, DestinyInventoryItemDefinition> plugDefinitions;
  final Map<int, int> selectedPerkHashes;

  LandscapeItemCoverDelegate(
      this.item, this.definition, this.instanceInfo, this.tag, this.uniqueId,
      {this.minHeight = 50,
      this.maxHeight = 200,
      this.plugDefinitions,
      this.selectedPerkHashes})
      : super();

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    double expandRatio =
        max(0, 1 - shrinkOffset / (this.maxHeight - this.minHeight));
    if (maxHeight == minHeight) {
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
            icon(context, expandRatio),
            buildNameAndType(context, expandRatio),
            basicInfo(context, expandRatio),
            itemStats(context, expandRatio),
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

  Widget icon(BuildContext context, double expandRatio) {
    double openSize = convertSize(96, context);
    double closedSize = kToolbarHeight - 8;
    double size = lerpDouble(closedSize, openSize, expandRatio);
    double top = lerpDouble(4, convertSize(96, context), expandRatio);
    double left =
        lerpDouble(kTextTabBarHeight, convertSize(96, context), expandRatio);
    return Positioned(
        left: left,
        top: top,
        width: size,
        height: size,
        child: Hero(
            tag: "item_icon_${tag}_$uniqueId",
            child: ItemIconWidget.builder(
              item,
              definition,
              instanceInfo,
              iconBorderWidth:
                  lerpDouble(1, convertSize(3, context), expandRatio),
            )));
  }

  Widget buildNameAndType(BuildContext context, double expandRatio) {
    return Positioned(
        top: convertSize(96, context),
        left: convertSize(96.0 * 2 + 24, context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              definition.displayProperties.name.toUpperCase(),
              style: TextStyle(
                  fontSize: convertSize(74, context),
                  fontWeight: FontWeight.bold,
                  height: .94),
            ),
            Text(
              definition.itemTypeDisplayName.toUpperCase(),
              style: TextStyle(
                  height: .94,
                  color: Colors.white.withOpacity(.6),
                  fontSize: convertSize(34, context),
                  fontWeight: FontWeight.w400),
            ),
          ],
        ));
  }

  Widget basicInfo(BuildContext context, double expandRatio) {
    var perksCategory = definition.sockets.socketCategories.firstWhere((s) =>
        DestinyData.socketCategoryPerkHashes.contains(s.socketCategoryHash));
    var modsCategory = definition.sockets.socketCategories.firstWhere((s) =>
        !DestinyData.socketCategoryPerkHashes.contains(s.socketCategoryHash));
    return Positioned(
        top: convertSize(96.0 * 2.4, context),
        left: convertSize(96.0, context),
        width: convertSize(730, context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              definition.displayProperties?.description ?? "",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: convertSize(24, context),
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(.7),
              ),
            ),
            Container(
              height: convertSize(32, context),
            ),
            ScreenShotItemPerksWidget(
              category: perksCategory,
              definition: definition,
              item: item,
              pixelSize: pixelSize(context),
            ),
            Container(
              height: convertSize(16, context),
            ),
            ScreenShotItemModsWidget(
              category: modsCategory,
              definition: definition,
              item: item,
              pixelSize: pixelSize(context),
            ),
          ],
        ));
  }

  Widget itemStats(BuildContext context, double expandRatio) {
    return Positioned(
        bottom: convertSize(96.0, context),
        right: convertSize(96.0, context),
        width: convertSize(730, context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ScreenShotItemStatsWidget(
                item: item, definition: definition, instanceInfo: instanceInfo),
          ],
        ));
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
    if (1 == 2) {
      return Positioned(
          top: 0,
          bottom: 0,
          width: width,
          child: Image.asset(
            'assets/imgs/example_screenshot.png',
            fit: BoxFit.cover,
          ));
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

  double convertSize(double value, BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return (value / 1920) * screenWidth;
  }

  double pixelSize(context) {
    return convertSize(1, context);
  }
}
