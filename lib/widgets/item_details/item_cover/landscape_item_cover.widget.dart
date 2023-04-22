// @dart=2.9

import 'dart:math';
import 'dart:ui';

import 'package:bungie_api/enums/destiny_item_type.dart';
import 'package:bungie_api/enums/item_state.dart';
import 'package:bungie_api/enums/tier_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_power_cap_definition.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/shared/utils/extensions/tier_type_data.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/utils/socket_category_hashes.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/item_icon/item_icon.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/masterwork_counter/screenshot_masterwork_counter.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';
import 'package:little_light/widgets/item_sockets/screenshot_armor_tier.widget.dart';
import 'package:little_light/widgets/item_sockets/screenshot_item_intrinsic_perk.widget.dart';
import 'package:little_light/widgets/item_sockets/screenshot_item_mods.widget.dart';
import 'package:little_light/widgets/item_sockets/screenshot_item_perks.widget.dart';
import 'package:little_light/widgets/item_sockets/screenshot_socket_details.widget.dart';
import 'package:little_light/widgets/item_stats/screenshot_item_stats.widget.dart';
import 'package:little_light/widgets/transfer_destinations/screenshot_transfer_destinations.widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class LandscapeItemCoverWidget extends StatelessWidget {
  final String uniqueId;
  final ItemSocketController socketController;
  final bool hideTransferBlock;
  final ItemWithOwner item;
  final DestinyInventoryItemDefinition definition;
  final DestinyItemInstanceComponent instanceInfo;

  const LandscapeItemCoverWidget(
    this.item,
    this.definition,
    this.instanceInfo, {
    this.hideTransferBlock = false,
    this.uniqueId,
    // ItemSocketController socketController,
    this.socketController,
    Key key,
  }) : super(key: key);

  String get tag {
    List<dynamic> params = [item?.item?.itemInstanceId, item?.item?.itemHash ?? definition?.hash, item?.ownerId];
    params.removeWhere((p) => p == null);
    return params.map((p) => "$p").join("_");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double paddingTop = MediaQuery.of(context).padding.top;
    double screenshotHeight = size.width / (16 / 9);
    double minHeight = paddingTop + kToolbarHeight;
    double maxHeight = screenshotHeight.clamp(0, size.height);
    if ((definition?.screenshot?.length ?? 0) == 0) {
      maxHeight = minHeight;
    }
    return SliverPersistentHeader(
        pinned: true,
        delegate: LandscapeItemCoverDelegate(item, definition, instanceInfo, tag, uniqueId,
            socketController: socketController,
            hideTransferBlock: hideTransferBlock,
            minHeight: minHeight,
            maxHeight: maxHeight));
  }
}

class LandscapeItemCoverDelegate extends SliverPersistentHeaderDelegate {
  final ItemWithOwner item;
  final DestinyInventoryItemDefinition definition;
  final DestinyItemInstanceComponent instanceInfo;
  final double minHeight;
  final double maxHeight;
  final String tag;
  final String uniqueId;
  final ItemSocketController socketController;

  bool hideTransferBlock;

  LandscapeItemCoverDelegate(this.item, this.definition, this.instanceInfo, this.tag, this.uniqueId,
      {this.minHeight = 50, this.maxHeight = 200, this.socketController, this.hideTransferBlock})
      : super();

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    double expandRatio = min(1, max(0, 1 - (shrinkOffset) / (maxHeight - minHeight)));
    if (maxHeight == minHeight) {
      expandRatio = 0;
    }
    return Container(
        color: definition?.inventory?.tierType?.getColor(context),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            background(context, expandRatio),
            secondaryIcon(context, expandRatio),
            tierBar(context, expandRatio),
            backButton(context, expandRatio),
            if (socketController != null) leftColumn(context, expandRatio),
            icon(context, expandRatio),
            buildNameAndType(context, expandRatio),
            rightColumn(context, expandRatio)
          ],
        ));
  }

  double topPadding(BuildContext context, double expandRatio) =>
      max(convertSize(48.0, context), MediaQuery.of(context).viewPadding.top);

  double bottomPadding(BuildContext context, double expandRatio) =>
      max(convertSize(48.0, context), MediaQuery.of(context).viewPadding.bottom);

  double leftPadding(BuildContext context, double expandRatio) =>
      max(convertSize(96.0, context), MediaQuery.of(context).viewPadding.left);

  double rightPadding(BuildContext context, double expandRatio) =>
      max(convertSize(96.0, context), MediaQuery.of(context).viewPadding.right);

  Widget rightColumn(BuildContext context, double expandRatio) {
    final height = min(MediaQuery.of(context).size.height, MediaQuery.of(context).size.width * (9 / 16));
    return Positioned(
        top: topPadding(context, expandRatio),
        bottom: bottomPadding(context, expandRatio),
        right: rightPadding(context, expandRatio),
        child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
                height: height - topPadding(context, expandRatio) - bottomPadding(context, expandRatio),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    managementBlock(context, expandRatio),
                    Container(height: convertSize(16.0, context)),
                    Expanded(child: socketController == null ? Container() : socketDetails(context, expandRatio)),
                    Container(height: convertSize(16.0, context)),
                    statsBlock(context, expandRatio)
                  ],
                ))));
  }

  Widget managementBlock(BuildContext context, double expandRatio) {
    return Opacity(opacity: expandRatio, child: transferBlock(context, expandRatio));
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
          definition?.inventory?.tierType?.getColor(context),
          Colors.grey.shade300,
          expandRatio,
        )));
  }

  Widget icon(BuildContext context, double expandRatio) {
    double paddingTop = MediaQuery.of(context).padding.top;
    double openSize = convertSize(96, context);
    double closedSize = kToolbarHeight - 8;
    double size = lerpDouble(closedSize, openSize, expandRatio);
    double top = lerpDouble(paddingTop + 4, convertSize(96, context), expandRatio);
    double left = lerpDouble(kTextTabBarHeight, convertSize(96, context), expandRatio);
    return Positioned(
        left: left,
        top: top,
        width: size,
        height: size,
        child: Hero(
            tag: "item_icon_${tag}_$uniqueId",
            child: ItemIconWidget.builder(
              item: null,
              definition: definition,
              instanceInfo: instanceInfo,
              iconBorderWidth: lerpDouble(1, convertSize(3, context), expandRatio),
            )));
  }

  Widget buildNameAndType(BuildContext context, double expandRatio) {
    double paddingTop = MediaQuery.of(context).padding.top;
    final itemNotes = context.watch<ItemNotesBloc>();
    var customName = itemNotes.customNameFor(item?.item?.itemHash, item?.item?.itemInstanceId)?.toUpperCase();

    return Positioned(
        top: lerpDouble(paddingTop + 8, convertSize(96, context), expandRatio),
        left: lerpDouble(kToolbarHeight * 2, convertSize(96.0 * 2 + 24, context), expandRatio),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
                width: convertSize(1030, context),
                child: Text(
                  customName ?? definition?.displayProperties?.name?.toUpperCase() ?? "",
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: definition?.inventory?.tierType?.getTextColor(context)?.withOpacity(.9),
                      fontSize: lerpDouble(kToolbarHeight * .5, convertSize(74, context), expandRatio),
                      fontWeight: FontWeight.bold,
                      height: .94),
                )),
            Text(
              definition?.itemTypeDisplayName?.toUpperCase() ?? "",
              style: TextStyle(
                  fontSize: lerpDouble(kToolbarHeight * .3, convertSize(34, context), expandRatio),
                  height: .94,
                  color: definition?.inventory?.tierType?.getTextColor(context)?.withOpacity(.8),
                  fontWeight: FontWeight.w500),
            ),
          ],
        ));
  }

  Widget socketDetails(BuildContext context, double expandRatio) {
    return Opacity(
        opacity: expandRatio,
        child: SingleChildScrollView(
            child: SizedBox(
                width: convertSize(600, context),
                child: ScreenshotSocketDetailsWidget(
                    item: item?.item,
                    parentDefinition: definition,
                    pixelSize: pixelSize(context),
                    controller: socketController))));
  }

  Widget leftColumn(BuildContext context, double expandRatio) {
    final leftColumnWidth = convertSize(730, context);
    var perksCategory = definition?.sockets?.socketCategories
        ?.firstWhere((s) => SocketCategoryHashes.perks.contains(s.socketCategoryHash), orElse: () => null);
    var armorTierCategory = definition?.sockets?.socketCategories
        ?.firstWhere((s) => DestinyData.socketCategoryTierHashes.contains(s.socketCategoryHash), orElse: () => null);
    var modsCategory = definition?.sockets?.socketCategories
        ?.firstWhere((s) => SocketCategoryHashes.mods.contains(s.socketCategoryHash), orElse: () => null);
    var shaderCategory = definition?.sockets?.socketCategories?.firstWhere(
        (s) => DestinyData.socketCategoryCosmeticModHashes.contains(s.socketCategoryHash),
        orElse: () => null);
    var exoticIntrinsicPerkCategory = definition?.sockets?.socketCategories?.firstWhere(
        (s) => DestinyData.socketCategoryIntrinsicPerkHashes.contains(s.socketCategoryHash),
        orElse: () => null);
    final topPadding = (this.topPadding(context, expandRatio) + convertSize(180.0, context)) * expandRatio +
        kToolbarHeight * (1 - expandRatio);
    return Positioned(
        top: topPadding,
        left: leftPadding(context, expandRatio),
        bottom: bottomPadding(context, expandRatio),
        child: Opacity(
            opacity: expandRatio,
            child: SingleChildScrollView(
                child: Container(
                    child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (definition?.displayProperties?.description?.isNotEmpty ?? false)
                  Container(
                      width: leftColumnWidth,
                      padding: EdgeInsets.only(
                        bottom: convertSize(16, context),
                      ),
                      child: Text(
                        definition?.displayProperties?.description ?? "",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: convertSize(24, context),
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(.7),
                        ),
                      )),
                Container(
                    width: leftColumnWidth,
                    padding: EdgeInsets.only(
                      bottom: convertSize(16, context),
                    ),
                    child: ScreenShotItemPerksWidget(
                      controller: socketController,
                      category: perksCategory,
                      definition: definition,
                      item: item?.item,
                      pixelSize: pixelSize(context),
                    )),
                Container(
                    width: leftColumnWidth,
                    padding: EdgeInsets.only(
                      bottom: convertSize(16, context),
                    ),
                    child: ScreenShotArmorTierWidget(
                      controller: socketController,
                      category: armorTierCategory,
                      definition: definition,
                      item: item?.item,
                      pixelSize: pixelSize(context),
                    )),
                Container(
                    width: leftColumnWidth,
                    padding: EdgeInsets.only(
                      bottom: convertSize(16, context),
                    ),
                    child: ScreenShotItemModsWidget(
                      controller: socketController,
                      category: modsCategory,
                      definition: definition,
                      item: item?.item,
                      pixelSize: pixelSize(context),
                    )),
                Container(
                    width: leftColumnWidth,
                    padding: EdgeInsets.only(
                      bottom: convertSize(16, context),
                    ),
                    child: ScreenShotItemIntrinsicPerkWidget(
                      controller: socketController,
                      category: exoticIntrinsicPerkCategory,
                      definition: definition,
                      item: item?.item,
                      pixelSize: pixelSize(context),
                    )),
                SizedBox(
                    width: leftColumnWidth,
                    child: ScreenShotItemModsWidget(
                      controller: socketController,
                      category: shaderCategory,
                      definition: definition,
                      item: item?.item,
                      pixelSize: pixelSize(context),
                    )),
              ],
            )))));
  }

  Widget transferBlock(BuildContext context, double expandRatio) {
    if (hideTransferBlock || item == null) return Container();
    return Container(
        child: ScreenshotTransferDestinationsWidget(
      pixelSize: pixelSize(context).clamp(0, .7),
      item: item?.item,
      instanceInfo: instanceInfo,
      definition: definition,
      characterId: item?.ownerId,
    ));
  }

  Widget statsBlock(BuildContext context, double expandRatio) {
    if (socketController == null) return Container();
    return Opacity(
        opacity: expandRatio,
        child: IntrinsicHeight(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            primaryStatHash == null ? Container() : buildPrimaryStat(context),
            primaryStatHash == null || (definition?.stats?.stats?.length ?? 0) == 0
                ? Container()
                : Container(
                    margin: EdgeInsets.symmetric(horizontal: convertSize(16, context)),
                    width: convertSize(2, context),
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(.4)),
            ScreenShotItemStatsWidget(
              socketController: socketController,
              pixelSize: pixelSize(context),
              item: item?.item,
              definition: definition,
            ),
          ],
        )));
  }

  int get primaryStatHash => instanceInfo?.primaryStat?.statHash;
  int get primaryStatValue => instanceInfo?.primaryStat?.value;

  Widget buildPrimaryStat(BuildContext context) {
    final damageType = definition.defaultDamageType;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Flexible(
            flex: 2,
            child: SizedBox(
                height: convertSize(60, context),
                child: Row(children: [
                  if (damageType.icon != null)
                    Container(
                        margin: EdgeInsets.only(right: convertSize(8, context)),
                        height: convertSize(60, context),
                        alignment: Alignment.bottomCenter,
                        child: Icon(damageType.icon,
                            size: convertSize(50, context), color: damageType.getColorLayer(context).layer1)),
                  Text(
                    "$primaryStatValue",
                    style: TextStyle(height: 1, fontSize: convertSize(70, context), fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: convertSize(8, context),
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildPowerCap(context),
                        ManifestText<DestinyStatDefinition>(
                          primaryStatHash,
                          uppercase: true,
                          style: TextStyle(
                            height: .6,
                            fontWeight: FontWeight.w300,
                            fontSize: convertSize(30, context),
                          ),
                        )
                      ]),
                ]))),
        Container(height: convertSize(8, context)),
        buildMasterworkCounter(context)
      ],
    );
  }

  Widget buildPowerCap(BuildContext context) {
    var versionNumber = item?.item?.versionNumber ?? definition?.quality?.currentVersion;
    if (versionNumber == null || definition?.quality?.versions == null) {
      return Container();
    }
    var version = definition?.quality?.versions[versionNumber];
    return DefinitionProviderWidget<DestinyPowerCapDefinition>(version.powerCapHash, (def) {
      if (def.powerCap > 9000) {
        return Container(height: convertSize(40, context));
      }
      return Row(children: [
        Container(
            height: convertSize(26, context),
            width: convertSize(2, context),
            color: Theme.of(context).colorScheme.onSurface),
        Container(
          width: convertSize(4, context),
        ),
        Text("${def.powerCap}",
            style: TextStyle(fontSize: convertSize(24, context), color: LittleLightTheme.of(context).achievementLayers))
      ]);
    });
  }

  Widget buildMasterworkCounter(BuildContext context) {
    return ScreenshotMasterworkCounterWidget(
      item: item?.item,
      pixelSize: pixelSize(context),
    );
  }

  Widget masterworkBackground(BuildContext context, double expandRatio) {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Opacity(
            opacity: expandRatio,
            child: Image.asset(
              "assets/imgs/masterwork_bottom_bg.png",
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomCenter,
            )));
  }

  Widget secondaryIcon(BuildContext context, double expandRatio) {
    double opacity = expandRatio;
    String imgUrl = definition?.secondaryIcon;
    if (imgUrl == null) {
      return Container();
    }
    if (definition?.itemType == DestinyItemType.Subclass) {
      return Positioned(
          bottom: 0,
          right: 0,
          width: convertSize(800, context),
          child: Opacity(
              opacity: opacity * .5,
              child: QueuedNetworkImage(
                imageUrl: BungieApiService.url(imgUrl),
                fit: BoxFit.cover,
              )));
    }
    return Positioned(
        top: -convertSize(1080 / 2, context) + expandRatio * convertSize(1080 / 2, context),
        left: 0,
        width: convertSize(500, context),
        child: Opacity(
            opacity: opacity * .5,
            child: QueuedNetworkImage(
              imageUrl: BungieApiService.url(imgUrl),
              fit: BoxFit.cover,
            )));
  }

  Widget background(BuildContext context, double expandRatio) {
    double opacity = expandRatio;

    return Positioned(
        top: 0, bottom: 0, left: 0, right: 0, child: Opacity(opacity: opacity, child: buildBackgroundImage(context)));
  }

  Widget buildBackgroundImage(BuildContext context) {
    String imgUrl = definition?.screenshot;
    if (definition?.itemType == DestinyItemType.Emblem) {
      imgUrl = definition?.secondarySpecial;
    }
    if (definition?.itemType == DestinyItemType.QuestStep) {
      imgUrl = definition?.secondaryIcon;
    }
    if (imgUrl == null) {
      return Container();
    }
    if (item?.item?.overrideStyleItemHash != null) {
      return DefinitionProviderWidget<DestinyInventoryItemDefinition>(item?.item?.overrideStyleItemHash, (def) {
        if (def?.plug?.isDummyPlug ?? false) {
          return QueuedNetworkImage(
              imageUrl: BungieApiService.url(imgUrl),
              fit: BoxFit.cover,
              placeholder: Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.secondary,
                  highlightColor: Colors.grey.shade300,
                  child: Container(color: Theme.of(context).colorScheme.onSurface)));
        }

        return QueuedNetworkImage(
            imageUrl: BungieApiService.url(def?.screenshot ?? imgUrl),
            fit: BoxFit.cover,
            placeholder: Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.secondary,
                highlightColor: Colors.grey.shade300,
                child: Container(color: Theme.of(context).colorScheme.onSurface)));
      });
    }
    return QueuedNetworkImage(
        imageUrl: BungieApiService.url(imgUrl),
        fit: BoxFit.cover,
        placeholder: Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.secondary,
            highlightColor: Colors.grey.shade300,
            child: Container(color: Theme.of(context).colorScheme.onSurface)));
  }

  Widget tierBar(BuildContext context, double expandRatio) {
    Color tierColor = definition?.inventory?.tierType?.getColor(context);
    ItemState state = item?.item?.state ?? ItemState.None;
    bool isMasterwork = state.contains(ItemState.Masterwork);
    if (isMasterwork && definition?.inventory?.tierType == TierType.Exotic) {}
    if (isMasterwork) {}
    return Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Opacity(
            opacity: expandRatio,
            child: Column(
              children: <Widget>[
                Container(
                    height: topPadding(context, expandRatio) * .6,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                      tierColor.withOpacity(.6),
                      tierColor.withOpacity(.3),
                      Colors.transparent,
                    ], stops: const [
                      0,
                      .7,
                      1
                    ]))),
                Container(
                    height: topPadding(context, expandRatio) * .1,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                      tierColor,
                      tierColor.withOpacity(.3),
                      Colors.transparent,
                    ], stops: const [
                      0,
                      .7,
                      1
                    ]))),
              ],
            )));
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(LandscapeItemCoverDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight || minHeight != oldDelegate.minHeight;
  }

  double convertSize(double value, BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return (value / 1920) * screenWidth;
  }

  double pixelSize(context) {
    return convertSize(1, context);
  }
}
