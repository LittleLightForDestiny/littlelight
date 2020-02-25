import 'package:flutter/material.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/widgets/common/wishlist_badge.widget.dart';

mixin PlugWishlistTagIconsMixin{
  List<Widget> wishlistIcons(BuildContext context, int itemHash, int plugItemHash) {
    var tags = WishlistsService().getPerkTags(itemHash, plugItemHash);
    if (tags == null) return [];
    List<Widget> items = [];
    if (tags.contains(WishlistTag.GodPVE)) {
      items.add(buildWishlistIcon(context, WishlistTag.GodPVE));
    }else if (tags.contains(WishlistTag.PVE)) {
      items.add(buildWishlistIcon(context, WishlistTag.PVE));
    }else{
      items.add(Container());
    }
    if (tags.contains(WishlistTag.GodPVP)) {
      items.add(buildWishlistIcon(context, WishlistTag.GodPVP));
    }else if (tags.contains(WishlistTag.PVP)) {
      items.add(buildWishlistIcon(context, WishlistTag.PVP));
    }
    return items;
  }

  buildWishlistIcon(BuildContext context, WishlistTag tag){
    return WishlistBadgeWidget(tags:[tag].toSet(), size:16);
  }

  Widget buildWishlistTagIcons(BuildContext context, int itemHash, int plugItemHash) {
    var icons = wishlistIcons(context, itemHash, plugItemHash);
    if ((icons?.length ?? 0) > 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: icons);
    }
    return Container();
  }
}