import 'package:flutter/material.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/widgets/common/wishlist_badge.widget.dart';

class WishlistBadgesWidget extends StatelessWidget {
  final Set<WishlistTag> tags;
  final double size;

  const WishlistBadgesWidget({this.tags, this.size = 24});

  @override
  Widget build(BuildContext context) {
    List<Widget> badges = [];
    if (tags.contains(WishlistTag.GodPVE)) {
      badges.add(WishlistBadgeWidget(size: size, tag: WishlistTag.GodPVE));
    } else if (tags.contains(WishlistTag.PVE)) {
      badges.add(WishlistBadgeWidget(size: size, tag: WishlistTag.PVE));
    }
    if (tags.contains(WishlistTag.GodPVP)) {
      badges.add(WishlistBadgeWidget(size: size, tag: WishlistTag.GodPVP));
    } else if (tags.contains(WishlistTag.PVP)) {
      badges.add(WishlistBadgeWidget(size: size, tag: WishlistTag.PVP));
    }
    if (tags.contains(WishlistTag.Bungie)) {
      badges.add(WishlistBadgeWidget(size: size, tag: WishlistTag.Bungie));
    }
    if (badges.length > 0) {
      return Row(
        children: badges,
      );
    }
    if (tags.contains(WishlistTag.Trash)) {
      return WishlistBadgeWidget(size: size, tag: WishlistTag.Trash);
    }
    return Container();
  }
}
