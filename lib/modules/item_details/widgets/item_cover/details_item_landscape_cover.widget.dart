import 'dart:math';
import 'dart:ui';
import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/item_details/blocs/item_details.bloc.dart';
import 'package:little_light/modules/item_details/widgets/item_cover/details_item_cover_energy_meter.widget.dart';
import 'package:little_light/modules/item_details/widgets/item_cover/details_item_cover_intrinsic_perk.widget.dart';
import 'package:little_light/modules/item_details/widgets/item_cover/details_item_cover_perks.widget.dart';
import 'package:little_light/modules/item_details/widgets/item_cover/details_item_cover_plug_info.widget.dart';
import 'package:little_light/modules/item_details/widgets/item_cover/details_item_cover_stats.widget.dart';
import 'package:little_light/modules/item_details/widgets/item_cover/details_item_cover_supers.widget.dart';
import 'package:little_light/modules/item_details/widgets/item_cover/details_item_cover_transfer_block.widget.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/utils/extensions/inventory_item_data.dart';
import 'package:little_light/shared/utils/extensions/tier_type_data.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item_icon.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:provider/provider.dart';
import 'package:tinycolor2/tinycolor2.dart';
import 'details_item_cover_mods.widget.dart';

const _powerStatHash = 1935470627;

extension on BuildContext {
  double topPadding(double expandRatio, double pixelSize) => max(48.0 * pixelSize, this.mediaQuery.viewPadding.top);

  double bottomPadding(double expandRatio, double pixelSize) =>
      max(48.0 * pixelSize, this.mediaQuery.viewPadding.bottom);

  double leftPadding(double expandRatio, double pixelSize) => max(96.0 * pixelSize, this.mediaQuery.viewPadding.left);

  double rightPadding(double expandRatio, double pixelSize) => max(96.0 * pixelSize, this.mediaQuery.viewPadding.right);
}

class DetailsItemLandscapeCoverWidget extends StatelessWidget {
  final ItemDetailsBloc state;
  final SocketControllerBloc socketState;
  const DetailsItemLandscapeCoverWidget(
    this.state,
    this.socketState, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hash = state.itemHash;
    final definition = context.definition<DestinyInventoryItemDefinition>(hash);
    final width = MediaQuery.of(context).size.width;
    final paddingTop = MediaQuery.of(context).padding.top;
    final screenshotHeight = width / (16 / 9);
    final minHeight = paddingTop + kToolbarHeight;
    final hasScreenshot = (definition?.screenshot?.length ?? 0) > 0;
    final maxHeight = hasScreenshot ? screenshotHeight : kToolbarHeight + paddingTop;
    return SliverPersistentHeader(
      pinned: true,
      key: Key("item_cover_${state.itemHash}_${state.styleHash}"),
      delegate: DetailsItemCoverDelegate(
        minHeight: minHeight,
        maxHeight: maxHeight,
      ),
    );
  }
}

class DetailsItemCoverDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;

  String? get tag => null;
  String? get uniqueId => null;

  DateTime? lastUpdated;

  DetailsItemCoverDelegate({
    this.minHeight = 50,
    this.maxHeight = 200,
  })  : lastUpdated = DateTime.now(),
        super();

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final state = context.watch<ItemDetailsBloc>();
    final bloc = context.read<ItemDetailsBloc>();
    final socketState = context.watch<SocketControllerBloc>();
    double expandRatio = max(0, 1 - shrinkOffset / (maxHeight - minHeight));
    if (maxHeight == minHeight) {
      expandRatio = 0;
    }
    return ItemCoverContentsWidget(bloc, state, socketState, expandRatio);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(DetailsItemCoverDelegate oldDelegate) {
    return true;
  }
}

class ItemCoverContentsWidget extends StatelessWidget {
  final ItemDetailsBloc bloc;
  final ItemDetailsBloc state;
  final SocketControllerBloc socketState;
  final double expandRatio;
  ItemCoverContentsWidget(this.bloc, this.state, this.socketState, this.expandRatio);

  @override
  Widget build(BuildContext context) {
    final definition = context.definition<DestinyInventoryItemDefinition>(state.itemHash);
    final pixelSize = (1 / 1920) * context.mediaQuery.size.width;
    Color? backgroundColor = definition?.inventory?.tierType?.getColor(context);
    if (definition?.isSubclass ?? false) {
      backgroundColor = definition?.talentGrid?.hudDamageType?.getColorLayer(context);
    }
    return Container(
        color: backgroundColor,
        child: Stack(
          fit: StackFit.expand,
          children: [
            buildBackground(context, expandRatio),
            buildSecondaryIcon(context, expandRatio, pixelSize),
            buildTierBar(context, expandRatio, pixelSize),
            buildBackButton(context, expandRatio),
            buildLeftColumn(context, expandRatio, pixelSize),
            buildIcon(context, expandRatio, pixelSize),
            buildNameAndType(context, expandRatio, pixelSize),
            buildRightColumn(context, expandRatio, pixelSize),
          ].whereType<Widget>().toList(),
        ));
  }

  Widget? buildSecondaryIcon(BuildContext context, double expandRatio, double pixelSize) {
    final definition = context.definition<DestinyInventoryItemDefinition>(state.itemHash);
    final opacity = expandRatio;
    final imgUrl = definition?.secondaryIcon;
    if (imgUrl == null) {
      return null;
    }
    return Positioned(
        top: -540 * pixelSize * (1 - expandRatio),
        left: 0,
        width: 500 * pixelSize,
        child: Opacity(
            opacity: opacity * .5,
            child: QueuedNetworkImage(
              imageUrl: BungieApiService.url(imgUrl),
              fit: BoxFit.cover,
            )));
  }

  Widget buildTierBar(BuildContext context, double expandRatio, double pixelSize) {
    final definition = context.definition<DestinyInventoryItemDefinition>(state.itemHash);
    if (definition?.isSubclass ?? false) return Container();
    final tierColor = definition?.inventory?.tierType?.getColor(context) ?? Colors.transparent;
    final topPadding = context.topPadding(expandRatio, pixelSize);
    return Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Opacity(
            opacity: expandRatio,
            child: Column(
              children: <Widget>[
                Container(
                  height: topPadding * .6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        tierColor.withOpacity(.6),
                        tierColor.withOpacity(.3),
                        Colors.transparent,
                      ],
                      stops: const [0, .7, 1],
                    ),
                  ),
                ),
                Container(
                    height: topPadding * .1,
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

  Widget buildNamebarContents(BuildContext context, double expandRatio) {
    final definition = context.definition<DestinyInventoryItemDefinition>(state.itemHash);
    final item = state.item;
    double nameLeftOffset = lerpDouble(kToolbarHeight * 2 - 16, 104, expandRatio) ?? 0;
    final name = state.customName ?? definition?.displayProperties?.name ?? "";
    final isMasterwork = item?.state?.contains(ItemState.Masterwork) ?? false;
    bool isExotic = definition?.inventory?.tierType == TierType.Exotic;
    return Container(
      decoration: isMasterwork
          ? BoxDecoration(
              image: DecorationImage(
                repeat: ImageRepeat.repeatX,
                alignment: Alignment.topCenter,
                image: ExactAssetImage(
                  isExotic ? "assets/imgs/masterwork-top-exotic.png" : "assets/imgs/masterwork-top.png",
                ),
              ),
              border: Border(
                  bottom: BorderSide(
                color: context.theme.achievementLayers.layer2,
                width: 3.5,
              )),
            )
          : null,
      padding: EdgeInsets.only(left: nameLeftOffset + 8),
      alignment: Alignment.centerLeft,
      child: Text(
        name.toUpperCase(),
        style: context.textTheme.itemNameHighDensity.copyWith(fontSize: 16),
      ),
    );
  }

  Widget buildIcon(BuildContext context, double expandRatio, double pixelSize) {
    final paddingTop = context.mediaQuery.viewPadding.top;
    final item = state.item;
    final size = lerpDouble(kToolbarHeight - 8, 96 * pixelSize, expandRatio);
    final top = lerpDouble(paddingTop + 4, 96 * pixelSize, expandRatio) ?? 8;
    final left = lerpDouble(kTextTabBarHeight, 96 * pixelSize, expandRatio) ?? 8;
    if (item == null) return Container();
    return Positioned(
      left: left,
      top: top,
      width: size,
      height: size,
      child: InventoryItemIcon(item),
    );
  }

  Widget buildNameAndType(BuildContext context, double expandRatio, double pixelSize) {
    final definition = context.definition<DestinyInventoryItemDefinition>(state.itemHash);
    double paddingTop = MediaQuery.of(context).padding.top;
    final name = state.customName ?? definition?.displayProperties?.name ?? "";
    Color? textColor = definition?.inventory?.tierType?.getTextColor(context);
    if (definition?.isSubclass ?? false) {
      textColor = context.theme.onSurfaceLayers;
    }
    return Positioned(
        top: lerpDouble(paddingTop + 8, 96 * pixelSize, expandRatio),
        left: lerpDouble(kToolbarHeight * 2, pixelSize * (96.0 * 2 + 24), expandRatio),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
                width: pixelSize * 1030,
                child: Text(
                  name.toUpperCase(),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.itemNameScreenshot.copyWith(
                    color: textColor?.withOpacity(.9),
                    fontSize: lerpDouble(kToolbarHeight * .5, pixelSize * 74, expandRatio),
                  ),
                )),
            Text(
              definition?.itemTypeDisplayName?.toUpperCase() ?? "",
              style: context.textTheme.itemTypeScreenshot.copyWith(
                fontSize: lerpDouble(kToolbarHeight * .3, pixelSize * 34, expandRatio),
                color: textColor?.withOpacity(.8),
              ),
            ),
          ],
        ));
  }

  Widget buildRightColumn(BuildContext context, double expandRatio, double pixelSize) {
    final height = min(
      context.mediaQuery.size.height,
      pixelSize * 1080,
    );
    final top = context.topPadding(expandRatio, pixelSize);
    final bottom = context.bottomPadding(expandRatio, pixelSize);
    return Positioned(
        top: top,
        bottom: context.bottomPadding(expandRatio, pixelSize),
        right: context.rightPadding(expandRatio, pixelSize),
        child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
                height: height - top - bottom,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    buildManagementBlock(context, expandRatio, pixelSize),
                    Expanded(
                        child: DetailsItemCoverPlugInfoWidget(
                      pixelSize: pixelSize,
                    )),
                    buildStatsBlock(context, expandRatio, pixelSize)
                  ],
                ))));
  }

  Widget buildStatsBlock(BuildContext context, double expandRatio, double pixelSize) {
    final definition = context.definition<DestinyInventoryItemDefinition>(state.itemHash);
    if (definition?.isSubclass ?? false) return Container();
    final hasPrimaryStatType = definition?.stats?.primaryBaseStatHash != null;
    final hasStats = definition?.investmentStats?.isNotEmpty ?? false;
    if (!hasPrimaryStatType && !hasStats) return Container();
    return Opacity(
        opacity: expandRatio,
        child: IntrinsicHeight(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasPrimaryStatType) buildPrimaryStat(context, expandRatio, pixelSize),
            if (hasPrimaryStatType && hasStats)
              Container(
                width: 1 * pixelSize,
                color: context.theme.onSurfaceLayers.layer0,
                margin: EdgeInsets.symmetric(horizontal: 32 * pixelSize),
              ),
            if (hasStats) DetailsItemCoverStatsWidget(pixelSize: pixelSize),
          ].whereType<Widget>().toList(),
        )));
  }

  Widget buildBackButton(BuildContext context, double expandRatio) {
    double paddingTop = MediaQuery.of(context).padding.top;
    final definition = context.definition<DestinyInventoryItemDefinition>(state.itemHash);
    final isSubclass = definition?.isSubclass ?? false;
    final openColor = context.theme.onSurfaceLayers.layer0;
    final closedColor = isSubclass ? openColor : definition?.inventory?.tierType?.getTextColor(context) ?? openColor;
    return Positioned(
        left: 0,
        top: paddingTop,
        width: kToolbarHeight,
        height: kToolbarHeight,
        child: BackButton(
          color: closedColor.mix(openColor, (expandRatio * 100).ceil().clamp(0, 100)),
        ));
  }

  Widget buildLeftColumn(BuildContext context, double expandRatio, double pixelSize) {
    final definition = context.definition<DestinyInventoryItemDefinition>(state.itemHash);
    final width = 730 * pixelSize;
    final categories = socketState.getSocketCategories(null) ?? [];
    final openTopPadding = (context.topPadding(expandRatio, pixelSize) + 180 * pixelSize) * expandRatio;
    final closedTopPadding = kToolbarHeight * (1 - expandRatio);
    final topPadding = openTopPadding + closedTopPadding;
    return Positioned(
        top: topPadding,
        width: width,
        left: context.leftPadding(expandRatio, pixelSize),
        bottom: context.bottomPadding(expandRatio, pixelSize),
        child: SingleChildScrollView(
          primary: true,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 20 * pixelSize),
                alignment: Alignment.centerLeft,
                child: Text(
                  definition?.flavorText ?? "",
                  style: context.textTheme.quote.copyWith(fontSize: 20 * pixelSize),
                ),
              ),
              ...categories.map((c) => buildSocketCategory(context, expandRatio, pixelSize, c)),
            ],
          ),
        ));
  }

  Widget buildSocketCategory(
      BuildContext context, double expandRatio, double pixelSize, DestinyItemSocketCategoryDefinition category) {
    final categoryDef = context.definition<DestinySocketCategoryDefinition>(category.socketCategoryHash);
    final categoryStyle = categoryDef?.categoryStyle;
    if (categoryStyle == null) return Container();
    switch (categoryStyle) {
      case DestinySocketCategoryStyle.Reusable:
        return DetailsItemCoverPerksWidget(category, pixelSize: pixelSize);
      case DestinySocketCategoryStyle.LargePerk:
      case DestinySocketCategoryStyle.Intrinsic:
        return DetailsItemCoverIntrinsicPerkWidget(category, pixelSize: pixelSize);
      case DestinySocketCategoryStyle.EnergyMeter:
        return DetailsItemCoverEnergyMeterWidget(category, pixelSize: pixelSize);
      case DestinySocketCategoryStyle.Supers:
        return DetailsItemCoverSupersWidget(category, pixelSize: pixelSize);
      case DestinySocketCategoryStyle.Consumable:
      case DestinySocketCategoryStyle.Abilities:
      case DestinySocketCategoryStyle.Unlockable:
      case DestinySocketCategoryStyle.Unknown:
      case DestinySocketCategoryStyle.ProtectedInvalidEnumValue:
        return DetailsItemCoverModsWidget(category, pixelSize: pixelSize);
    }
  }

  Widget buildBackground(BuildContext context, double expandRatio) {
    double width = MediaQuery.of(context).size.width;
    double opacity = expandRatio;

    return Positioned(
        top: 0, bottom: 0, width: width, child: Opacity(opacity: opacity, child: buildBackgroundImage(context)));
  }

  Widget buildBackgroundImage(BuildContext context) {
    final definition = context.definition<DestinyInventoryItemDefinition>(state.itemHash);
    final styleDefinition = context.definition<DestinyInventoryItemDefinition>(state.styleHash) ?? definition;

    String? imgUrl = styleDefinition?.screenshot;

    if (definition?.isEmblem ?? false) {
      imgUrl = styleDefinition?.secondarySpecial;
    }
    if (definition?.isQuestStep ?? false) {
      imgUrl = styleDefinition?.secondaryIcon;
    }

    if (imgUrl == null) {
      return Container();
    }
    return Container(
      key: Key("${styleDefinition?.hash}"),
      child: QueuedNetworkImage(
        imageUrl: BungieApiService.url(imgUrl),
        fit: BoxFit.cover,
        placeholder: DefaultLoadingShimmer(),
      ),
    );
  }

  Widget buildPrimaryStat(BuildContext context, double expandRatio, double pixelSize) {
    final definition = context.definition<DestinyInventoryItemDefinition>(state.itemHash);
    final damageType = definition?.defaultDamageType;
    final icon = damageType?.icon;
    final primaryStatValue = state.item?.primaryStatValue;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (primaryStatValue != null)
          Container(
            margin: EdgeInsets.only(right: 8 * pixelSize, bottom: 4 * pixelSize),
            child: ManifestText<DestinyStatDefinition>(
              _powerStatHash,
              uppercase: true,
              style: context.textTheme.primaryStatTypeScreenshot.copyWith(
                fontSize: 30 * pixelSize,
              ),
            ),
          ),
        Flexible(
          flex: 2,
          child: SizedBox(
            height: 60 * pixelSize,
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              if (icon != null)
                Container(
                  margin: EdgeInsets.only(right: 8 * pixelSize, top: 4 * pixelSize),
                  alignment: Alignment.bottomCenter,
                  child: Icon(
                    icon,
                    size: 60 * pixelSize,
                    color: damageType?.getColorLayer(context).layer1,
                  ),
                ),
              if (primaryStatValue != null)
                Text(
                  "$primaryStatValue",
                  style: context.textTheme.primaryStatValueScreenshot.copyWith(
                    fontSize: 70 * pixelSize,
                  ),
                ),
            ]),
          ),
        ),
        buildTracker(context, expandRatio, pixelSize)
      ].whereType<Widget>().toList(),
    );
  }

  Widget? buildTracker(BuildContext context, double expandRatio, double pixelSize) {
    final tracker = state.killTracker;
    if (tracker == null) return null;
    return Container(
      padding: EdgeInsets.only(top: 32 * pixelSize, right: 4 * pixelSize),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: pixelSize * 24,
            width: pixelSize * 24,
            child: ManifestImageWidget<DestinyObjectiveDefinition>(tracker.objectiveHash),
          ),
          Container(width: 8 * pixelSize),
          ManifestText<DestinyObjectiveDefinition>(
            tracker.objectiveHash,
            textExtractor: (def) => def.progressDescription,
            style: context.textTheme.caption.copyWith(fontSize: pixelSize * 20),
          ),
          Container(width: 8 * pixelSize),
          Text(
            "${tracker.progress}",
            style: context.textTheme.highlight.copyWith(fontSize: pixelSize * 20),
          ),
        ],
      ),
    );
  }

  Widget buildManagementBlock(BuildContext context, double expandRatio, double pixelSize) {
    final item = state.item;
    if (item == null) return Container();
    return Opacity(
      opacity: (expandRatio * 2).clamp(0, 1),
      child: DetailsItemCoverTransferBlockWidget(
        item,
        transferDestinations: state.transferDestinations,
        equipDestinations: state.equipDestinations,
        onAction: (type, destination) => bloc.onTransferAction(type, destination, 1),
        pixelSize: pixelSize,
      ),
    );
  }
}
