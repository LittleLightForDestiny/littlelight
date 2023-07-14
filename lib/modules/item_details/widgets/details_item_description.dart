import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/inventory_item_data.dart';
import 'package:little_light/shared/widgets/inventory_item/item_expiration_date.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class DetailsItemDescriptionWidget extends StatelessWidget {
  final int itemHash;
  final DestinyItemInfo? item;

  DetailsItemDescriptionWidget(this.itemHash, {DestinyItemInfo? this.item});

  Widget build(BuildContext context) {
    final definition = context.definition<DestinyInventoryItemDefinition>(itemHash);
    if (definition == null) return Container();
    final type = definition.itemTypeAndTierDisplayName;
    final description = definition.displayProperties?.description;
    final flavorText = definition.flavorText;
    return Container(
        padding: EdgeInsets.all(8).copyWith(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                child: Text(
                  type ?? "",
                  style: context.textTheme.caption,
                ),
              ),
              buildExpirationDate(context)
            ]),
            if (description != null && description.isNotEmpty)
              Container(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  description,
                  style: context.textTheme.body,
                ),
              ),
            if (flavorText != null && flavorText.isNotEmpty)
              Container(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  flavorText,
                  style: context.textTheme.body,
                ),
              ),
            if (definition.isEmblem) buildEmblemPreviews(context),
            Container(
              margin: EdgeInsets.only(top: 16, bottom: 8),
              color: context.theme.onSurfaceLayers,
              height: .5,
            ),
          ],
        ));
  }

  Widget buildEmblemPreviews(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            Container(
              height: 96,
              width: 96,
              child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                itemHash,
              ),
            ),
            SizedBox(
              width: 8,
            ),
            Container(
              height: 96,
              child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                itemHash,
                urlExtractor: (def) => def.secondaryIcon,
              ),
            ),
          ]),
        ),
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            height: 132,
            child: Stack(children: [
              Container(
                height: 96,
                child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                  itemHash,
                  urlExtractor: (def) => def.secondarySpecial,
                ),
              ),
              Positioned(
                top: 36,
                left: 36,
                height: 96,
                child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                  itemHash,
                  urlExtractor: (def) => def.secondaryOverlay,
                ),
              )
            ]),
          ),
        ),
      ],
    );
  }

  Widget buildExpirationDate(BuildContext context) {
    final expirationDate = item?.expirationDate;
    if (expirationDate == null) return Container();
    final isDate = DateTime.tryParse(expirationDate) != null;
    if (!isDate) return Container();
    final isObjectiveComplete = item?.objectives?.objectives?.every((o) => o.complete ?? false) ?? false;
    if (isObjectiveComplete) return Container();
    return ExpiryDateWidget(expirationDate);
  }
}
