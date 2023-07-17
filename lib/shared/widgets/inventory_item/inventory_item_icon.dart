import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/inventory_item_data.dart';
import 'package:little_light/shared/utils/extensions/tier_type_data.dart';
import 'package:little_light/shared/utils/helpers/deepsight_helpers.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:shimmer/shimmer.dart';

class InventoryItemIcon extends StatelessWidget with ManifestConsumer {
  final DestinyItemInfo itemInfo;
  final double borderSize;
  final Color? overrideBorderColor;
  InventoryItemIcon(
    this.itemInfo, {
    this.borderSize = 2,
    this.overrideBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final definition = context.definition<DestinyInventoryItemDefinition>(itemInfo.itemHash);
    if (definition?.isSubclass ?? false) return buildSubclass(context);
    if (definition?.isEngram ?? false) return buildEngram(context);
    if (definition?.isQuestStep ?? false) {
      final customImg = definition?.displayProperties?.iconSequences?.lastOrNull?.frames?.lastOrNull;
      if (customImg != null) {
        return buildQuestStep(context);
      }
    }
    return AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            buildBorder(context),
            Container(
                padding: EdgeInsets.all(borderSize),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    buildBackground(context),
                    buildIconImage(context),
                    buildMasterworkOverlay(context),
                    buildCraftedWeaponOverlay(context),
                    buildSeasonOverlay(context),
                  ].whereType<Widget>().toList(),
                )),
          ].whereType<Widget>().toList(),
        ));
  }

  Widget buildSubclass(BuildContext context) => buildIconImage(context);

  Widget buildQuestStep(BuildContext context) {
    final definition = context.definition<DestinyInventoryItemDefinition>(itemInfo.itemHash);
    final imgUrl = definition?.displayProperties?.iconSequences?.lastOrNull?.frames?.lastOrNull ??
        definition?.displayProperties?.icon;
    return QueuedNetworkImage.fromBungie(imgUrl);
  }

  Widget? buildBorder(BuildContext context) {
    final theme = LittleLightTheme.of(context);
    final definition = context.definition<DestinyInventoryItemDefinition>(itemInfo.itemHash);
    final isDeepSight = this.isDeepsight(context);
    final isMasterwork = itemInfo.state?.contains(ItemState.Masterwork) ?? false;
    if (isDeepSight) {
      return Container(color: theme.highlightedObjectiveLayers.layer0);
    }
    if (isMasterwork) {
      final isExotic = definition?.inventory?.tierType == TierType.Exotic;
      final masterworkLayers = LittleLightTheme.of(context).achievementLayers;
      return Shimmer.fromColors(
        baseColor: isExotic ? theme.achievementLayers.layer1 : theme.achievementLayers.layer2,
        highlightColor: masterworkLayers.layer3,
        period: const Duration(seconds: 5),
        child: Container(color: Colors.white),
      );
    }
    if (definition?.isQuestStep ?? false) {
      final isObjectiveComplete = itemInfo.objectives?.objectives?.every((o) => o.complete ?? false) ?? false;
      if (isObjectiveComplete) return Container(color: theme.achievementLayers.layer1);
    }
    return Container(color: theme.onSurfaceLayers.layer1);
  }

  Widget buildBackground(BuildContext context) {
    return Container(
      color: LittleLightTheme.of(context).surfaceLayers.layer0,
    );
  }

  Widget buildIconImage(BuildContext context) {
    final overrideStyleItemHash = itemInfo.overrideStyleItemHash;
    final definition = context.definition<DestinyInventoryItemDefinition>(itemInfo.itemHash);
    if (overrideStyleItemHash != null) {
      return ManifestImageWidget<DestinyInventoryItemDefinition>(overrideStyleItemHash);
    }
    final iconImage = definition?.displayProperties?.icon;
    if (iconImage != null) {
      return QueuedNetworkImage.fromBungie(iconImage, fit: BoxFit.cover);
    }
    return Container();
  }

  Widget? buildMasterworkOverlay(BuildContext context) {
    final definition = context.definition<DestinyInventoryItemDefinition>(itemInfo.itemHash);
    final isMasterwork = itemInfo.state?.contains(ItemState.Masterwork) ?? false;
    if (!isMasterwork) return null;
    final tierType = definition?.inventory?.tierType;
    if (tierType == null) return null;
    final isExotic = tierType == TierType.Exotic;
    final imgPath = isExotic ? "assets/imgs/masterwork-outline-exotic.png" : "assets/imgs/masterwork-outline.png";
    final masterworkLayers = LittleLightTheme.of(context).achievementLayers;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          imgPath,
          fit: BoxFit.cover,
        ),
        Shimmer.fromColors(
          baseColor: masterworkLayers.withOpacity(.2),
          highlightColor: masterworkLayers.layer3,
          period: const Duration(seconds: 5),
          child: Image.asset(
            imgPath,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Widget? buildSeasonOverlay(BuildContext context) {
    final definition = context.definition<DestinyInventoryItemDefinition>(itemInfo.itemHash);
    final versionNumber = itemInfo.versionNumber;
    final watermarkIcons = definition?.quality?.displayVersionWatermarkIcons;
    String? badgeUrl;
    if (watermarkIcons == null) //
      badgeUrl = definition?.iconWatermark ?? definition?.iconWatermarkShelved;
    else if (versionNumber != null) //
      badgeUrl = watermarkIcons[versionNumber];
    else if (watermarkIcons.length == 1) //
      badgeUrl = watermarkIcons[0];
    if (badgeUrl?.isEmpty ?? true) return null;
    return QueuedNetworkImage.fromBungie(
      badgeUrl,
      fit: BoxFit.fill,
    );
  }

  bool isDeepsight(BuildContext context) {
    final def = context.definition<DestinyInventoryItemDefinition>(itemInfo.itemHash);
    return isItemDeepsight(this.itemInfo, def);
  }

  Widget? buildCraftedWeaponOverlay(BuildContext context) {
    final isCrafted = itemInfo.state?.contains(ItemState.Crafted) ?? false;
    if (!isCrafted) return null;
    return Image.asset(
      "assets/imgs/crafted-icon-overlay.png",
      fit: BoxFit.fill,
    );
  }

  Widget buildEngram(BuildContext context) {
    final definition = context.definition<DestinyInventoryItemDefinition>(itemInfo.itemHash);
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/imgs/engram-border.png",
              color: definition?.inventory?.tierType?.getColor(context),
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(child: Padding(padding: EdgeInsets.all(borderSize), child: buildIconImage(context))),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(borderSize),
              child: Shimmer.fromColors(
                  baseColor: context.theme.onSurfaceLayers.layer0.withOpacity(0),
                  highlightColor: context.theme.onSurfaceLayers.layer0.withOpacity(1),
                  child: Image.asset("assets/imgs/engram-placeholder.png")),
            ),
          ),
        ],
      ),
    );
  }
}
