import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:little_light/shared/widgets/wishlists/wishlist_badge.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:provider/provider.dart';

const _maxPerkIconSize = 56.0;
const _defaultWishlistIconSize = 18.0;
const _animationDuration = const Duration(milliseconds: 300);

class PerkIconWidget extends StatelessWidget {
  static const maxIconSize = _maxPerkIconSize;
  final int plugItemHash;
  final int itemHash;
  final bool selectable;
  final bool available;
  final bool equipped;
  final bool selected;
  final VoidCallback? onTap;
  final double wishlistIconSize;

  PerkIconWidget({
    required int this.plugItemHash,
    required int this.itemHash,
    this.selectable = true,
    this.equipped = false,
    this.available = true,
    this.selected = false,
    this.onTap,
    this.wishlistIconSize = _defaultWishlistIconSize,
  }) : super();

  Color perkColor(BuildContext context) => context.theme.primaryLayers.layer1;

  Color baseBorderColor(BuildContext context) => context.theme.onSurfaceLayers.layer1;

  @override
  Widget build(BuildContext context) {
    final itemDef = context.definition<DestinyInventoryItemDefinition>(itemHash);
    final plugDef = context.definition<DestinyInventoryItemDefinition>(plugItemHash);
    final intrinsic = plugDef?.plug?.plugCategoryIdentifier == "intrinsics";
    final exotic = itemDef?.inventory?.tierType == TierType.Exotic;
    Color bgColor = Colors.transparent;
    Color borderColor = baseBorderColor(context).withOpacity(.5);
    final isRound = !intrinsic || exotic;
    final isEnhanced = plugDef?.inventory?.tierType == TierType.Common;
    if (equipped && !intrinsic) {
      bgColor = perkColor(context).withOpacity(.5);
    }
    if (selected && !intrinsic) {
      bgColor = perkColor(context);
      borderColor = baseBorderColor(context);
    }

    if (intrinsic && !selected) {
      borderColor = Colors.transparent;
    }

    return Container(
      padding: const EdgeInsets.all(0),
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = constraints.maxWidth / _maxPerkIconSize;
            final radius = BorderRadius.circular(isRound ? constraints.maxWidth / 2 : 8 * scale);
            return AnimatedOpacity(
              opacity: available ? 1 : .5,
              duration: _animationDuration,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      color: bgColor,
                      border: Border.all(color: borderColor, width: 1.5 * scale),
                    ),
                  ),
                  if (isEnhanced)
                    Positioned.fill(
                        child: Container(
                      margin: EdgeInsets.all(4 * scale),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(_maxPerkIconSize),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              context.theme.achievementLayers.layer0,
                              context.theme.achievementLayers.layer0.withOpacity(0),
                            ],
                          )),
                    )),
                  Padding(
                      padding: EdgeInsets.all(intrinsic ? 0 : 4 * scale),
                      child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                        plugItemHash,
                        noIconPlaceholder: Container(),
                        placeholder: DefaultLoadingShimmer(
                            child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(64),
                            color: Colors.white,
                          ),
                        )),
                      )),
                  InkWell(
                    customBorder: isRound ? CircleBorder() : RoundedRectangleBorder(borderRadius: radius),
                    onTap: selectable ? onTap : null,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(),
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
    if (tags.contains(WishlistTag.GodPVE)) return WishlistBadgeWidget(WishlistTag.GodPVE, size: wishlistIconSize);
    if (tags.contains(WishlistTag.PVE)) return WishlistBadgeWidget(WishlistTag.PVE, size: wishlistIconSize);
    return null;
  }

  Widget? getPvpTag(Set<WishlistTag> tags) {
    if (tags.contains(WishlistTag.GodPVP)) return WishlistBadgeWidget(WishlistTag.GodPVP, size: wishlistIconSize);
    if (tags.contains(WishlistTag.PVP)) return WishlistBadgeWidget(WishlistTag.PVP, size: wishlistIconSize);
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
      children: [
        Transform.translate(
          offset: Offset(-wishlistIconSize * .2, -wishlistIconSize * .2),
          child: pve ?? Container(),
        ),
        Transform.translate(
          offset: Offset(wishlistIconSize * .2, -wishlistIconSize * .2),
          child: pvp ?? Container(),
        )
      ],
    );
  }
}
