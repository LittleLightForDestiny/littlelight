import 'dart:math';
import 'dart:ui';

import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/utils/logger/logger.wrapper.dart';
import 'package:little_light/modules/item_details/blocs/item_details.bloc.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/tier_type_data.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/item_icon/item_icon.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ItemDetailsCoverWidget extends StatelessWidget {
  const ItemDetailsCoverWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ItemDetailsBloc>();
    final hash = state.itemHash;
    final definition = context.definition<DestinyInventoryItemDefinition>(hash);
    final styleDefinition = context.definition<DestinyInventoryItemDefinition>(state.styleHash);
    final width = MediaQuery.of(context).size.width;
    final paddingTop = MediaQuery.of(context).padding.top;
    final screenshotHeight = width / (16 / 9);
    final minHeight = paddingTop + kToolbarHeight;
    final hasScreenshot = (definition?.screenshot?.length ?? 0) > 0;
    final maxHeight = hasScreenshot ? kToolbarHeight + screenshotHeight : 0.0;
    return SliverPersistentHeader(
      pinned: true,
      delegate: ItemDetailsCoverDelegate(
        styleDefinition: styleDefinition,
        itemDefinition: definition,
        minHeight: minHeight,
        maxHeight: maxHeight,
      ),
    );
  }
}

class ItemDetailsCoverDelegate extends SliverPersistentHeaderDelegate {
  final DestinyInventoryItemDefinition? styleDefinition;
  final DestinyInventoryItemDefinition? itemDefinition;
  final DestinyItemInstanceComponent? instanceInfo;
  final double minHeight;
  final double maxHeight;

  String? get tag => null;
  String? get uniqueId => null;

  ItemDetailsCoverDelegate({
    this.itemDefinition,
    this.instanceInfo,
    this.minHeight = 50,
    this.maxHeight = 200,
    DestinyInventoryItemDefinition? this.styleDefinition,
  }) : super();

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    double expandRatio = max(0, 1 - shrinkOffset / (maxHeight - minHeight));
    if (maxHeight == minHeight) {
      expandRatio = 0;
    }
    return Container(
        color: itemDefinition?.inventory?.tierType?.getColor(context),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            background(context, expandRatio),
            overlay(context, expandRatio),
            // masterworkCounter(context, expandRatio),
            // nameBar(context, expandRatio),
            icon(context, expandRatio),
            backButton(context, expandRatio),
          ],
        ));
  }

  Widget nameBar(BuildContext context, double expandRatio) {
    double leftOffset = lerpDouble(kToolbarHeight * 2 - 16, 104, expandRatio) ?? 0;
    return Positioned(left: 0, bottom: 0, right: 0, height: kToolbarHeight, child: Container());
  }

  Widget icon(BuildContext context, double expandRatio) {
    double size = lerpDouble(kToolbarHeight - 8, 96, expandRatio) ?? 96;
    double bottom = lerpDouble(4, 8, expandRatio) ?? 8;
    double left = lerpDouble(kTextTabBarHeight, 8, expandRatio) ?? 8;
    return Positioned(
        left: left,
        bottom: bottom,
        width: size,
        height: size,
        child: ItemIconWidget.builder(
          definition: styleDefinition ?? itemDefinition,
          instanceInfo: instanceInfo,
          iconBorderWidth: lerpDouble(1, 2, expandRatio) ?? 2,
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
            color: Color.lerp(itemDefinition?.inventory?.tierType?.getTextColor(context), Colors.grey.shade300,
                expandRatio.clamp(0, 1))));
  }

  Widget shareButton(BuildContext context, double expandRatio) {
    if (instanceInfo == null) return Container();
    var acceptedItemTypes = [
      DestinyItemType.Armor,
      DestinyItemType.Weapon,
      DestinyItemType.Ghost,
      DestinyItemType.Ship,
      DestinyItemType.Vehicle
    ];
    if (!acceptedItemTypes.contains(itemDefinition?.itemType)) return Container();
    return Positioned(
        right: 0,
        bottom: 0 + kToolbarHeight * expandRatio,
        width: kToolbarHeight,
        height: kToolbarHeight,
        child: Material(
            color: Colors.transparent,
            child: IconButton(
              enableFeedback: false,
              onPressed: () async {},
              icon: Icon(Icons.share,
                  color: Color.lerp(
                    itemDefinition?.inventory?.tierType?.getTextColor(context),
                    Colors.grey.shade300,
                    expandRatio,
                  )),
            )));
  }

  Widget overlay(BuildContext context, double expandRatio) {
    double width = MediaQuery.of(context).size.width;
    double opacity = expandRatio;
    if (itemDefinition?.itemType != DestinyItemType.Subclass) {
      return Container();
    }
    return Positioned(
        bottom: kToolbarHeight,
        width: width / 2,
        right: 0,
        child: Opacity(
            opacity: opacity,
            child: QueuedNetworkImage.fromBungie(
              itemDefinition?.secondaryIcon,
              fit: BoxFit.fitWidth,
            )));
  }

  Widget background(BuildContext context, double expandRatio) {
    double width = MediaQuery.of(context).size.width;
    double opacity = expandRatio;

    return Positioned(
        top: 0,
        bottom: kToolbarHeight,
        width: width,
        child: Opacity(opacity: opacity, child: buildBackgroundImage(context)));
  }

  Widget buildBackgroundImage(BuildContext context) {
    final definition = styleDefinition ?? this.itemDefinition;
    String? imgUrl = definition?.screenshot;
    if (definition?.itemType == DestinyItemType.Emblem) {
      imgUrl = definition?.secondarySpecial;
    }
    if (definition?.itemType == DestinyItemType.QuestStep) {
      imgUrl = definition?.secondaryIcon;
    }
    if (imgUrl == null) {
      return Container();
    }
    var overrideStyleItemHash = styleDefinition?.hash;
    if (overrideStyleItemHash != null) {
      return DefinitionProviderWidget<DestinyInventoryItemDefinition>(overrideStyleItemHash, (def) {
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

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(ItemDetailsCoverDelegate oldDelegate) {
    final isDifferentHeight = maxHeight != oldDelegate.maxHeight || minHeight != oldDelegate.minHeight;
    final isDifferentStyle = styleDefinition?.hash != oldDelegate.styleDefinition?.hash;
    logger.debug("currentHash: ${styleDefinition?.hash} previousHash:${oldDelegate.styleDefinition?.hash}");
    return isDifferentHeight || isDifferentStyle;
  }
}
