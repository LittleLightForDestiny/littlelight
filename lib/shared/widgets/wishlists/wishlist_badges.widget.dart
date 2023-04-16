import 'package:flutter/material.dart';
import 'package:little_light/models/parsed_wishlist.dart';

import 'wishlist_badge.widget.dart';

class WishlistBadgesWidget extends StatelessWidget {
  final Set<WishlistTag> tags;
  final double size;

  const WishlistBadgesWidget(this.tags, {this.size = 24});

  @override
  Widget build(BuildContext context) {
    List<Widget> badges = [];
    if (tags.contains(WishlistTag.GodPVE)) {
      badges.add(WishlistBadgeWidget(WishlistTag.GodPVE, size: size));
    } else if (tags.contains(WishlistTag.PVE)) {
      badges.add(WishlistBadgeWidget(WishlistTag.PVE, size: size));
    }
    if (tags.contains(WishlistTag.GodPVP)) {
      badges.add(WishlistBadgeWidget(WishlistTag.GodPVP, size: size));
    } else if (tags.contains(WishlistTag.PVP)) {
      badges.add(WishlistBadgeWidget(WishlistTag.PVP, size: size));
    }
    if (tags.contains(WishlistTag.Bungie)) {
      badges.add(WishlistBadgeWidget(WishlistTag.Bungie, size: size));
    }
    if (badges.isNotEmpty) {
      return Row(
        children: badges,
      );
    }
    if (tags.contains(WishlistTag.Trash)) {
      return WishlistBadgeWidget(WishlistTag.Trash, size: size);
    }
    return Container();
  }
}
