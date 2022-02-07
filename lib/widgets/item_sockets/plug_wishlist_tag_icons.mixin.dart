// @dart=2.9

import 'package:flutter/material.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/widgets/common/wishlist_badges.widget.dart';

mixin PlugWishlistTagIconsMixin {
  get _wishlistsService => getInjectedWishlistsService();
  List<Widget> wishlistIcons(BuildContext context, int itemHash, int plugItemHash, [double scale = 1]) {
    var tags = _wishlistsService.getPlugTags(itemHash, plugItemHash);
    if (tags == null) return [];
    List<Widget> items = [];
    if (tags.contains(WishlistTag.GodPVE)) {
      items.add(buildWishlistIcon(context, WishlistTag.GodPVE, scale));
    } else if (tags.contains(WishlistTag.PVE)) {
      items.add(buildWishlistIcon(context, WishlistTag.PVE, scale));
    } else {
      items.add(Container());
    }
    if (tags.contains(WishlistTag.GodPVP)) {
      items.add(buildWishlistIcon(context, WishlistTag.GodPVP, scale));
    } else if (tags.contains(WishlistTag.PVP)) {
      items.add(buildWishlistIcon(context, WishlistTag.PVP, scale));
    }
    return items;
  }

  buildWishlistIcon(BuildContext context, WishlistTag tag, [double scale = 1]) {
    return WishlistBadgesWidget(tags: [tag].toSet(), size: 16 * scale);
  }

  Widget buildWishlistTagIcons(BuildContext context, int itemHash, int plugItemHash, [double scale = 1]) {
    var icons = wishlistIcons(context, itemHash, plugItemHash, scale);
    if ((icons?.length ?? 0) > 0) {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: icons);
    }
    return Container();
  }
}
