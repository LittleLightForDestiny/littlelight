import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/shared/widgets/wishlists/wishlist_badge.widget.dart';

const _iconSize = 20.0;

class DetailsPlugWishlistInfoWidget extends StatelessWidget {
  final Set<WishlistTag> tags;

  const DetailsPlugWishlistInfoWidget(this.tags, {Key? key}) : super(key: key);

  WishlistTag? get pvePerk {
    if (tags.contains(WishlistTag.GodPVE)) return WishlistTag.GodPVE;
    if (tags.contains(WishlistTag.PVE)) return WishlistTag.PVE;
    return null;
  }

  WishlistTag? get pvpPerk {
    if (tags.contains(WishlistTag.GodPVP)) return WishlistTag.GodPVP;
    if (tags.contains(WishlistTag.PVP)) return WishlistTag.PVP;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final pve = pvePerk;
    final pvp = pvpPerk;
    if (pve == null && pvp == null) return Container();
    return Container(
      margin: EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: context.theme.surfaceLayers.layer1,
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          if (pve != null) buildPerkInfo(context, pve),
          if (pvp != null) buildPerkInfo(context, pvp),
        ],
      ),
    );
  }

  Widget buildPerkInfo(BuildContext context, WishlistTag tag) {
    return Row(
      children: [
        WishlistBadgeWidget(tag, size: _iconSize),
        SizedBox(
          width: 4,
        ),
        Text(
          getTagText(context, tag) ?? "",
          style: context.textTheme.caption,
        ),
      ],
    );
  }

  String? getTagText(BuildContext context, WishlistTag tag) {
    switch (tag) {
      case WishlistTag.GodPVE:
        return "This perk is considered the best for PvE on this item.".translate(context);
      case WishlistTag.GodPVP:
        return "This perk is considered the best for PvP on this item.".translate(context);
      case WishlistTag.PVE:
        return "This perk is considered good for PvE on this item.".translate(context);
      case WishlistTag.PVP:
        return "This perk is considered good for PvP on this item.".translate(context);
      default:
        return null;
    }
  }
}
