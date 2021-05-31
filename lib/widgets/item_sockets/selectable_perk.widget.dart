import 'package:bungie_api/enums/tier_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
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
  final int plugHash;
  final Function onTap;

  const SelectablePerkWidget(
      {Key key,
      this.itemDefinition,
      this.plugDefinition,
      this.selectedOnSocket,
      this.selected,
      this.equipped,
      this.onTap,
      this.plugHash})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool intrinsic =
        plugDefinition?.plug?.plugCategoryIdentifier == "intrinsics";
    bool isExotic = itemDefinition.inventory.tierType == TierType.Exotic;
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
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.only(bottom: 8),
        child: Stack(children: [
          AspectRatio(
              aspectRatio: 1,
              child: InkWell(
                borderRadius: intrinsic && !isExotic
                    ? BorderRadius.circular(4)
                    : BorderRadius.circular(48),
                child: Material(
                    shape: intrinsic && !isExotic
                        ? RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: borderSide)
                        : CircleBorder(side: borderSide),
                    color: bgColor,
                    child: Padding(
                        padding: EdgeInsets.all(intrinsic ? 0 : 8),
                        child:
                            ManifestImageWidget<DestinyInventoryItemDefinition>(
                                plugItemHash))),
                onTap: onTap,
              )),
          Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Center(
                  child: buildWishlistTagIcons(
                      context, itemDefinition.hash, plugItemHash)))
        ]));
  }
}
