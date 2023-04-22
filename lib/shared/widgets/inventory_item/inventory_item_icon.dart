import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/inventory_item_data.dart';
import 'package:little_light/widgets/common/corner_badge.decoration.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:little_light/shared/utils/extensions/tier_type_data.dart';

class InventoryItemIcon extends StatelessWidget with ManifestConsumer {
  final DestinyInventoryItemDefinition definition;
  final DestinyItemInfo itemInfo;
  final double borderSize;
  final Color? overrideBorderColor;
  InventoryItemIcon(
    this.itemInfo, {
    required this.definition,
    this.borderSize = 2,
    this.overrideBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    if (definition.isSubclass) return buildSubclass(context);
    if (definition.isEngram) return buildEngram(context);
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
                    buildDeepsightOverlay(context),
                    buildSeasonOverlay(context),
                  ].whereType<Widget>().toList(),
                )),
          ].whereType<Widget>().toList(),
        ));
  }

  Widget buildSubclass(BuildContext context) => buildIconImage(context);

  Widget? buildBorder(BuildContext context) {
    final theme = LittleLightTheme.of(context);
    final isDeepSight = itemInfo.state?.contains(ItemState.HighlightedObjective) ?? false;
    final isMasterwork = itemInfo.state?.contains(ItemState.Masterwork) ?? false;
    if (isDeepSight) {
      return Container(color: theme.highlightedObjectiveLayers.layer0);
    }
    if (isMasterwork) {
      final isExotic = definition.inventory?.tierType == TierType.Exotic;
      final masterworkLayers = LittleLightTheme.of(context).achievementLayers;
      return Shimmer.fromColors(
        baseColor: isExotic ? theme.achievementLayers.layer1 : theme.achievementLayers.layer2,
        highlightColor: masterworkLayers.layer3,
        period: const Duration(seconds: 5),
        child: Container(color: Colors.white),
      );
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
    if (overrideStyleItemHash != null) {
      return ManifestImageWidget<DestinyInventoryItemDefinition>(overrideStyleItemHash);
    }
    final iconImage = definition.displayProperties?.icon;
    if (iconImage != null) {
      return QueuedNetworkImage.fromBungie(iconImage, fit: BoxFit.cover);
    }
    return Container();
  }

  Widget? buildMasterworkOverlay(BuildContext context) {
    final isMasterwork = itemInfo.state?.contains(ItemState.Masterwork) ?? false;
    if (!isMasterwork) return null;
    final tierType = definition.inventory?.tierType;
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
    final versionNumber = itemInfo.versionNumber;
    if (versionNumber == null) return null;
    final badgeUrl = definition.quality?.displayVersionWatermarkIcons?[versionNumber];
    if (badgeUrl?.isEmpty ?? true) return null;
    return QueuedNetworkImage.fromBungie(
      badgeUrl,
      fit: BoxFit.fill,
    );
  }

  Widget? buildDeepsightOverlay(BuildContext context) {
    final isDeepSight = itemInfo.state?.contains(ItemState.HighlightedObjective) ?? false;
    if (!isDeepSight) return null;
    final color = LittleLightTheme.of(context).highlightedObjectiveLayers;
    return LayoutBuilder(
        builder: (context, constraints) => Container(
              child: Stack(
                children: [
                  Container(
                      decoration: CornerBadgeDecoration(
                    colors: [color],
                    badgeSize: constraints.maxWidth * .4,
                    position: CornerPosition.BottomLeft,
                  )),
                  Positioned(
                    bottom: 0,
                    left: constraints.maxWidth * .07,
                    child: FutureBuilder(
                      future: isDeepsightObjectiveCompleted(context),
                      builder: (context, snapshot) => snapshot.data == true
                          ? Text(
                              "!",
                              style: LittleLightTheme.of(context)
                                  .textTheme
                                  .button
                                  .copyWith(fontSize: constraints.maxWidth * .2),
                            )
                          : Container(),
                    ),
                  ),
                ],
              ),
            ));
  }

  Future<bool> isDeepsightObjectiveCompleted(BuildContext context) async {
    final plugObjectives = itemInfo.plugObjectives;
    if (plugObjectives == null) return false;
    final completedObjectiveHashes = plugObjectives.values
        .map((progressList) => progressList
            .where((p) => p.complete == true) //
            .map((e) => e.objectiveHash)
            .whereType<int>()
            .toList())
        .fold<List<int>>([], (list, element) => list + element);
    if (completedObjectiveHashes.isEmpty) return false;
    final defs = await manifest.getDefinitions<DestinyObjectiveDefinition>(completedObjectiveHashes);
    return defs.values.any((def) => def.uiStyle == DestinyObjectiveUiStyle.Highlighted);
  }

  Widget? buildCraftedWeaponOverlay(BuildContext context) {
    final isCrafted = itemInfo.state?.contains(ItemState.Crafted) ?? false;
    if (!isCrafted) return null;
    return Image.asset(
      "assets/imgs/crafted-icon-overlay.png",
      fit: BoxFit.fill,
    );
  }

  Widget buildEngram(BuildContext context) => AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/imgs/engram-border.png",
                color: definition.inventory?.tierType?.getColor(context),
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
