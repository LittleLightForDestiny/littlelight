import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/vendors/pages/home/vendor_data.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

class VendorsListItemWidget extends StatelessWidget {
  final VendorData data;
  final VoidCallback? onTap;

  const VendorsListItemWidget(this.data, {Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: buildBackground(context),
      ),
      Container(
        decoration: BoxDecoration(border: Border.all(color: context.theme.surfaceLayers.layer3, width: 1)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            buildHeader(context),
            Expanded(child: buildContent(context)),
          ],
        ),
      ),
      Positioned.fill(
          child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
        ),
      ))
    ]);
  }

  Widget buildBackground(BuildContext context) {
    final definition = context.definition<DestinyVendorDefinition>(data.vendor.vendorHash);
    final url = definition?.locations?.first.backgroundImagePath ?? definition?.displayProperties?.largeIcon;
    return Stack(fit: StackFit.passthrough, children: [
      QueuedNetworkImage(
        fit: BoxFit.fitWidth,
        alignment: Alignment.topLeft,
        imageUrl: BungieApiService.url(url),
      ),
      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                context.theme.surfaceLayers.layer0,
                context.theme.surfaceLayers.layer0.withOpacity(.2),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.center,
            ),
          ),
        ),
      )
    ]);
  }

  Widget buildHeader(BuildContext context) {
    final definition = context.definition<DestinyVendorDefinition>(data.vendor.vendorHash);
    final locationIndex = data.vendor.vendorLocationIndex ?? 9999999;
    final destinationHash = definition?.locations?.elementAtOrNull(locationIndex)?.destinationHash;
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            child: QueuedNetworkImage(
              imageUrl: BungieApiService.url(definition?.displayProperties?.smallTransparentIcon),
            ),
          ),
          Container(
            width: 4,
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: context.theme.surfaceLayers.layer0.withOpacity(.7), borderRadius: BorderRadius.circular(4)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    definition?.displayProperties?.name?.toUpperCase() ?? "",
                    style: context.textTheme.highlight,
                  ),
                  Container(height: 2),
                  if (destinationHash != null)
                    ManifestText<DestinyDestinationDefinition>(
                      destinationHash,
                      style: context.textTheme.caption,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    var categories = data.categories;
    if (categories == null || categories.isEmpty) return Container();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: categories
            .map(
              (c) => Flexible(
                child: buildCategory(context, c),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget buildCategory(BuildContext context, DestinyVendorCategory category) {
    final definition = context.definition<DestinyVendorDefinition>(data.vendor.vendorHash);
    final categoryIndex = category.displayCategoryIndex;
    if (categoryIndex == null) return Container();
    var catDefinition = definition?.displayCategories?[categoryIndex];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              catDefinition?.displayProperties?.name?.toUpperCase() ?? "",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            )),
        Flexible(child: buildCategoryItems(context, category)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget buildCategoryItems(BuildContext context, DestinyVendorCategory category) {
    final definition = context.definition<DestinyVendorDefinition>(data.vendor.vendorHash);
    final indexes = category.itemIndexes?.reversed;
    if (indexes == null) return Container();
    return SizedBox(
        height: 36,
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: indexes.map((index) => buildItem(context, definition?.itemList?[index], index)).toList())));
  }

  Widget buildItem(BuildContext context, DestinyVendorItemDefinition? item, int index) {
    final sale = data.sales?["$index"];
    if (sale == null) return Container();
    return Container(
      margin: EdgeInsets.only(right: 4),
      decoration: BoxDecoration(border: Border.all(color: context.theme.onSurfaceLayers, width: 1)),
      child: Stack(children: [
        Container(
          height: 36,
          constraints: BoxConstraints(minWidth: 36, maxWidth: 64),
          child: ManifestImageWidget<DestinyInventoryItemDefinition>(
            item?.itemHash,
            key: Key("item_${item?.itemHash}"),
            fit: BoxFit.cover,
            placeholder: Container(width: 32, child: DefaultLoadingShimmer()),
          ),
        ),
        if (sale.saleStatus != VendorItemStatus.Success)
          Positioned.fill(
            child: Container(
              color: context.theme.surfaceLayers.withOpacity(.6),
            ),
          )
      ]),
    );
  }
}
