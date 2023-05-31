import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/shapes/diamond_shape.dart';
import 'package:little_light/shared/widgets/wishlists/wishlist_badge.widget.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:provider/provider.dart';
import 'package:tinycolor2/tinycolor2.dart';

const _maxPerkIconSize = 64.0;
const _wishlistIconSize = 18.0;
const _animationDuration = const Duration(milliseconds: 300);

class SuperIconWidget extends StatelessWidget {
  static const maxIconSize = _maxPerkIconSize;
  final int plugItemHash;
  final int itemHash;
  final bool selectable;
  final bool available;
  final bool equipped;
  final bool selected;
  final VoidCallback? onTap;

  SuperIconWidget({
    required int this.plugItemHash,
    required int this.itemHash,
    this.selectable = true,
    this.equipped = false,
    this.available = true,
    this.selected = false,
    this.onTap,
  }) : super();

  Color perkColor(BuildContext context) => context.theme.primaryLayers.layer1;

  Color baseBorderColor(BuildContext context) => context.theme.onSurfaceLayers.layer1;

  @override
  Widget build(BuildContext context) {
    final itemDef = context.definition<DestinyInventoryItemDefinition>(itemHash);
    final subclassColor = itemDef?.talentGrid?.hudDamageType?.getColorLayer(context).layer0 ?? Colors.transparent;
    final plugDef = context.definition<DestinyInventoryItemDefinition>(plugItemHash);
    final intrinsic = plugDef?.plug?.plugCategoryIdentifier == "intrinsics";

    return Container(
      padding: const EdgeInsets.all(0),
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = constraints.maxWidth / _maxPerkIconSize;
            return AnimatedOpacity(
              opacity: equipped || selected ? 1 : .5,
              duration: _animationDuration,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: DiamondShapePainter.color(context.theme.onSurfaceLayers.layer1),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                        padding: const EdgeInsets.all(2),
                        child: CustomPaint(
                          key: Key("background_$selected"),
                          painter: selected
                              ? DiamondShapePainter.color(subclassColor)
                              : equipped
                                  ? DiamondShapePainter.color(subclassColor.mix(context.theme.surfaceLayers, 50))
                                  : DiamondShapePainter.color(context.theme.surfaceLayers),
                        )),
                  ),
                  Padding(
                      padding: EdgeInsets.all(intrinsic ? 0 : 4 * scale),
                      child: ManifestImageWidget<DestinyInventoryItemDefinition>(plugItemHash)),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      customBorder: DiamondBorder(),
                      onTap: selectable ? onTap : null,
                    ),
                  ),
                  Positioned.fill(child: buildWishlistTags(context)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget? getPveTag(Set<WishlistTag> tags) {
    if (tags.contains(WishlistTag.GodPVE)) return WishlistBadgeWidget(WishlistTag.GodPVE, size: _wishlistIconSize);
    if (tags.contains(WishlistTag.PVE)) return WishlistBadgeWidget(WishlistTag.PVE, size: _wishlistIconSize);
    return null;
  }

  Widget? getPvpTag(Set<WishlistTag> tags) {
    if (tags.contains(WishlistTag.GodPVP)) return WishlistBadgeWidget(WishlistTag.GodPVP, size: _wishlistIconSize);
    if (tags.contains(WishlistTag.PVP)) return WishlistBadgeWidget(WishlistTag.PVP, size: _wishlistIconSize);
    return null;
  }

  Widget buildWishlistTags(BuildContext context) {
    final wishlists = context.watch<WishlistsService>();
    final tags = wishlists.getPlugTags(itemHash, plugItemHash);
    final pve = getPveTag(tags);
    final pvp = getPvpTag(tags);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [pve ?? Container(), pvp ?? Container()],
    );
  }
}
