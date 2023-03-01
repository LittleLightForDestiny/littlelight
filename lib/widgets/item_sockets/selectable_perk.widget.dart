// @dart=2.9

import 'package:bungie_api/enums/tier_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/item_sockets/plug_wishlist_tag_icons.mixin.dart';

class SelectablePerkWidget extends StatelessWidget
    with PlugWishlistTagIconsMixin {
  final DestinyInventoryItemDefinition itemDefinition;
  final DestinyInventoryItemDefinition plugDefinition;
  final bool equipped;
  final bool selectedOnSocket;
  final bool selected;
  final bool canRoll;
  final int plugHash;
  final Function onTap;
  final double scale;
  final double wishlistScale;

  const SelectablePerkWidget({
    Key key,
    this.itemDefinition,
    this.plugDefinition,
    this.selectedOnSocket,
    this.selected,
    this.equipped,
    this.onTap,
    this.plugHash,
    this.scale = 1,
    this.wishlistScale = 1,
    this.canRoll = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool intrinsic =
        plugDefinition?.plug?.plugCategoryIdentifier == "intrinsics";
    bool isExotic = itemDefinition.inventory.tierType == TierType.Exotic;
    bool isEnhanced = plugDefinition?.inventory?.tierType == TierType.Common;
    int plugItemHash = plugHash ?? plugDefinition.hash;
    Color bgColor = Colors.transparent;
    Color borderColor = Colors.grey.shade300.withOpacity(.5);
    if (equipped && !intrinsic) {
      bgColor = DestinyData.perkColor.withOpacity(.5);
    }
    if (selectedOnSocket && !intrinsic) {
      bgColor = DestinyData.perkColor;
      borderColor = Colors.grey.shade300;
    }

    if (intrinsic && !selected) {
      borderColor = Colors.transparent;
    }

    BorderSide borderSide = BorderSide(color: borderColor, width: 2);

    return Container(
        key: Key("item_perk_$plugItemHash"),
        padding: const EdgeInsets.all(0),
        child: Opacity(
            opacity: canRoll ? 1 : .3,
            child: Stack(children: [
              AspectRatio(
                  aspectRatio: 1,
                  child: InkWell(
                    borderRadius: intrinsic && !isExotic
                        ? BorderRadius.circular(4 * scale)
                        : BorderRadius.circular(48 * scale),
                    onTap: onTap,
                    child: Material(
                        shape: intrinsic && !isExotic
                            ? RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4 * scale),
                                side: borderSide)
                            : CircleBorder(side: borderSide),
                        color: bgColor,
                        child: Padding(
                            padding: EdgeInsets.all(intrinsic ? 0 : 8 * scale),
                            child: ManifestImageWidget<
                                DestinyInventoryItemDefinition>(plugItemHash))),
                  )),
              if (isEnhanced)
                Positioned.fill(child: buildEnhancedPerkOverlay(context)),
              Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  child: Center(
                      child: buildWishlistTagIcons(context, itemDefinition.hash,
                          plugItemHash, wishlistScale)))
            ])));
  }

  Widget buildEnhancedPerkOverlay(BuildContext context) {
    return IgnorePointer(
        child: Container(
      margin: EdgeInsets.all(scale * 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(scale * 50),
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            LittleLightTheme.of(context)
                .achievementLayers
                .layer0
                .withOpacity(.9),
            LittleLightTheme.of(context).achievementLayers.layer3.withOpacity(0)
          ],
        ),
      ),
    ));
  }
}
