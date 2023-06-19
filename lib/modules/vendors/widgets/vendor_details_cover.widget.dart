import 'dart:math';
import 'dart:ui';

import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/vendors/pages/vendor_details/vendor_details.bloc.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

class VendorDetailsCoverWidget extends StatelessWidget {
  final VendorDetailsBloc state;

  const VendorDetailsCoverWidget(
    this.state, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final paddingTop = MediaQuery.of(context).padding.top;
    final screenshotHeight = width / (16 / 9);
    final minHeight = paddingTop + kToolbarHeight;
    final maxHeight = screenshotHeight;
    return SliverPersistentHeader(
      pinned: true,
      delegate: VendorDetailsCoverDelegate(
        state,
        minHeight: minHeight,
        maxHeight: maxHeight,
      ),
    );
  }
}

class VendorDetailsCoverDelegate extends SliverPersistentHeaderDelegate {
  final VendorDetailsBloc state;

  final double minHeight;
  final double maxHeight;

  String? get tag => null;
  String? get uniqueId => null;

  DateTime? lastUpdated;

  VendorDetailsCoverDelegate(
    this.state, {
    this.minHeight = 50,
    this.maxHeight = 200,
  })  : lastUpdated = DateTime.now(),
        super();

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    double expandRatio = max(0, 1 - shrinkOffset / (maxHeight - minHeight));
    if (maxHeight == minHeight) {
      expandRatio = 0;
    }
    return VendorDetailsCoverContents(state, expandRatio);
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
    final definition = context.definition<DestinyVendorDefinition>(state.vendorHash);
    double nameLeftOffset = lerpDouble(kToolbarHeight * 2 - 16, kToolbarHeight, expandRatio) ?? 0;
    return Container(
      color: context.theme.surfaceLayers.layer2.withOpacity(.6),
      padding: EdgeInsets.only(left: nameLeftOffset + 8),
      alignment: Alignment.centerLeft,
      child: Text(
        definition?.displayProperties?.name?.toUpperCase() ?? "",
        style: context.textTheme.itemNameHighDensity.copyWith(fontSize: 16),
      ),
    );
  }

  Widget buildIcon(BuildContext context, double expandRatio) {
    final size = kToolbarHeight - 8;
    final bottom = 4.0;
    final left = lerpDouble(kTextTabBarHeight, 8, expandRatio) ?? 8;
    return Positioned(
      left: left,
      bottom: bottom,
      width: size,
      height: size,
      child: ManifestImageWidget<DestinyVendorDefinition>(
        state.vendorHash,
        urlExtractor: (def) {
          return def.displayProperties?.smallTransparentIcon ?? def.displayProperties?.icon;
        },
        fit: BoxFit.cover,
      ),
    );
  }

  Widget buildBackButton(BuildContext context, double expandRatio) {
    double paddingTop = MediaQuery.of(context).padding.top;
    return Positioned(
      left: 0,
      top: paddingTop,
      width: kToolbarHeight,
      height: kToolbarHeight,
      child: BackButton(color: context.theme.onSurfaceLayers),
    );
  }

  Widget buildBackground(BuildContext context, double expandRatio) {
    double width = MediaQuery.of(context).size.width;
    double opacity = expandRatio;

    return Positioned(
        top: 0, bottom: 0, width: width, child: Opacity(opacity: opacity, child: buildBackgroundImage(context)));
  }

  Widget buildBackgroundImage(BuildContext context) {
    final definition = context.definition<DestinyVendorDefinition>(state.vendorHash);
    final imgUrl = definition?.locations?.first.backgroundImagePath ?? definition?.displayProperties?.originalIcon;

    if (imgUrl == null) {
      return Container();
    }
    return Container(
      child: QueuedNetworkImage(
        imageUrl: BungieApiService.url(imgUrl),
        fit: BoxFit.cover,
        placeholder: DefaultLoadingShimmer(),
      ),
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(VendorDetailsCoverDelegate oldDelegate) => false;
}

class VendorDetailsCoverContents extends StatelessWidget {
  final double expandRatio;
  final VendorDetailsBloc state;
  VendorDetailsCoverContents(this.state, this.expandRatio, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: context.theme.surfaceLayers.layer0,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            buildBackground(context, expandRatio),
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
    final definition = context.definition<DestinyVendorDefinition>(state.vendorHash);
    double nameLeftOffset = lerpDouble(kToolbarHeight * 2 - 16, kToolbarHeight, expandRatio) ?? 0;
    return Container(
      color: context.theme.surfaceLayers.layer2.withOpacity(.6),
      padding: EdgeInsets.only(left: nameLeftOffset + 8),
      alignment: Alignment.centerLeft,
      child: Text(
        definition?.displayProperties?.name?.toUpperCase() ?? "",
        style: context.textTheme.itemNameHighDensity.copyWith(fontSize: 16),
      ),
    );
  }

  Widget buildIcon(BuildContext context, double expandRatio) {
    final size = kToolbarHeight - 8;
    final bottom = 4.0;
    final left = lerpDouble(kTextTabBarHeight, 8, expandRatio) ?? 8;
    return Positioned(
      left: left,
      bottom: bottom,
      width: size,
      height: size,
      child: ManifestImageWidget<DestinyVendorDefinition>(
        state.vendorHash,
        urlExtractor: (def) {
          return def.displayProperties?.smallTransparentIcon ?? def.displayProperties?.icon;
        },
        fit: BoxFit.cover,
      ),
    );
  }

  Widget buildBackButton(BuildContext context, double expandRatio) {
    double paddingTop = MediaQuery.of(context).padding.top;
    return Positioned(
      left: 0,
      top: paddingTop,
      width: kToolbarHeight,
      height: kToolbarHeight,
      child: BackButton(color: context.theme.onSurfaceLayers),
    );
  }

  Widget buildBackground(BuildContext context, double expandRatio) {
    double width = MediaQuery.of(context).size.width;
    double opacity = expandRatio;

    return Positioned(
        top: 0, bottom: 0, width: width, child: Opacity(opacity: opacity, child: buildBackgroundImage(context)));
  }

  Widget buildBackgroundImage(BuildContext context) {
    final definition = context.definition<DestinyVendorDefinition>(state.vendorHash);
    final imgUrl = definition?.locations?.first.backgroundImagePath ?? definition?.displayProperties?.originalIcon;

    if (imgUrl == null) {
      return Container();
    }
    return Container(
      child: QueuedNetworkImage(
        imageUrl: BungieApiService.url(imgUrl),
        fit: BoxFit.cover,
        placeholder: DefaultLoadingShimmer(),
      ),
    );
  }
}
