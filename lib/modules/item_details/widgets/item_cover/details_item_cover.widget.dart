import 'dart:math';
import 'dart:ui';
import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/item_details/blocs/item_details.bloc.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/inventory_item_data.dart';
import 'package:little_light/shared/utils/extensions/tier_type_data.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item_icon.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/shared/utils/extensions/ammo_type_data.dart';
import 'package:provider/provider.dart';
import 'package:tinycolor2/tinycolor2.dart';

class DetailsItemCoverWidget extends StatelessWidget {
  final ItemDetailsBloc state;
  const DetailsItemCoverWidget(
    this.state, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ItemDetailsBloc>();
    final hash = state.itemHash;
    final definition = context.definition<DestinyInventoryItemDefinition>(hash);
    final width = MediaQuery.of(context).size.width;
    final paddingTop = MediaQuery.of(context).padding.top;
    final screenshotHeight = width / (16 / 9);
    final minHeight = paddingTop + kToolbarHeight;
    final hasScreenshot = (definition?.screenshot?.length ?? 0) > 0;
    final maxHeight = hasScreenshot ? kToolbarHeight + screenshotHeight : kToolbarHeight + paddingTop;
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
    double expandRatio = max(0, 1 - shrinkOffset / (maxHeight - minHeight));
    if (maxHeight == minHeight) {
      expandRatio = 0;
    }
    return ItemCoverContentsWidget(state, expandRatio);
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
  final ItemDetailsBloc state;
  final double expandRatio;
  ItemCoverContentsWidget(this.state, this.expandRatio);

  @override
  Widget build(BuildContext context) {
    final definition = context.definition<DestinyInventoryItemDefinition>(state.itemHash);
    Color? backgroundColor = definition?.inventory?.tierType?.getColor(context);
    if (definition?.isSubclass ?? false) {
      backgroundColor = definition?.talentGrid?.hudDamageType?.getColorLayer(context);
    }
    return Container(
        color: backgroundColor,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            buildBackground(context, expandRatio),
            buildBasicStats(context, expandRatio),
            buildNameBar(context, expandRatio),
            buildIcon(context, expandRatio),
            buildBackButton(context, expandRatio),
          ],
        ));
  }

  Widget buildNameBar(BuildContext context, double expandRatio) {
    return Positioned(
      left: 0,
      bottom: 0,
      right: 0,
      height: kToolbarHeight,
      child: buildNamebarContents(context, expandRatio),
    );
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

  Widget buildIcon(BuildContext context, double expandRatio) {
    final item = state.item;
    final size = lerpDouble(kToolbarHeight - 8, 96, expandRatio) ?? 96;
    final bottom = lerpDouble(4, 8, expandRatio) ?? 8;
    final left = lerpDouble(kTextTabBarHeight, 8, expandRatio) ?? 8;
    if (item == null) return Container();
    return Positioned(
      left: left,
      bottom: bottom,
      width: size,
      height: size,
      child: InventoryItemIcon(item),
    );
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
      ),
    );
  }

  Widget buildBackground(BuildContext context, double expandRatio) {
    double width = MediaQuery.of(context).size.width;
    double opacity = expandRatio;

    return Positioned(
        top: 0,
        bottom: kToolbarHeight,
        width: width,
        child: Opacity(opacity: opacity, child: buildBackgroundImage(context)));
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

  Widget buildBasicStats(BuildContext context, double expandRatio) {
    return Positioned(
        bottom: kToolbarHeight + 16,
        right: 16,
        child: Opacity(
            opacity: expandRatio,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                buildPrimaryStat(context),
                buildTracker(context),
              ].whereType<Widget>().toList(),
            )));
  }

  Widget? buildPrimaryStat(BuildContext context) {
    final definition = context.definition<DestinyInventoryItemDefinition>(state.itemHash);
    if (definition?.isSubclass ?? false) return null;
    final item = state.item;
    final statHash = definition?.stats?.primaryBaseStatHash;
    final disableStat = definition?.stats?.disablePrimaryStatDisplay ?? false;
    final value = item?.primaryStatValue;
    final classType = definition?.classType ?? DestinyClass.Unknown;
    final ammoType = definition?.equippingBlock?.ammoType ?? DestinyAmmunitionType.None;
    final damageType = item?.damageType ?? DamageType.None;
    final damageColor = damageType != DamageType.None
        ? damageType.getColorLayer(context).layer2
        : context.textTheme.itemPrimaryStatHighDensity.color;
    final statDef = context.definition<DestinyStatDefinition>(statHash);
    final shouldUsePower = statDef?.aggregationType == DestinyStatAggregationType.Character;
    final label = shouldUsePower ? "Power".translate(context) : statDef?.displayProperties?.name;

    if (statHash == null || disableStat) return null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (classType != DestinyClass.Unknown) //
          Container(child: Icon(classType.icon, size: 28, color: context.theme.onSurfaceLayers.layer2)),
        if (classType != DestinyClass.Unknown && (damageType != DamageType.None || value != null))
          Container(
              height: 27, //
              child: VerticalDivider(thickness: 1, width: 12, color: context.theme.onSurfaceLayers.layer0)),
        if (ammoType != DestinyAmmunitionType.None)
          Container(padding: EdgeInsets.only(right: 10), child: Icon(ammoType.icon, color: ammoType.color, size: 28)),
        if (ammoType != DestinyAmmunitionType.None)
          Container(
              height: 27, //
              child: VerticalDivider(thickness: 1, width: 8, color: context.theme.onSurfaceLayers.layer0)),
        if (damageType != DamageType.None)
          Container(padding: EdgeInsets.only(right: 4), height: 28, child: Icon(damageType.icon, color: damageColor)),
        if (value != null)
          Container(
              child: Text(
            "$value",
            style: context.textTheme.itemPrimaryStatHighDensity.copyWith(fontSize: 32, height: .4, color: damageColor),
          )),
        if (value != null && label != null)
          Container(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              label.toUpperCase(),
              style: context.textTheme.primaryStatName,
            ),
          ),
      ],
    );
  }

  Widget? buildTracker(BuildContext context) {
    final tracker = state.killTracker;
    if (tracker == null) return null;
    return Container(
      padding: EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 12,
            width: 12,
            child: ManifestImageWidget<DestinyObjectiveDefinition>(tracker.objectiveHash),
          ),
          Container(width: 2),
          ManifestText<DestinyObjectiveDefinition>(
            tracker.objectiveHash,
            textExtractor: (def) => def.progressDescription,
            style: context.textTheme.caption,
          ),
          Container(width: 2),
          Text(
            "${tracker.progress}",
            style: context.textTheme.highlight.copyWith(color: context.theme.achievementLayers.layer1),
          ),
        ],
      ),
    );
  }
}
