import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/modules/item_details/widgets/details_plug_wishlist_info.widget.dart';
import 'package:little_light/shared/widgets/wishlists/wishlist_badge.widget.dart';

class DetailsItemCoverPlugWishlistInfoWidget extends DetailsPlugWishlistInfoWidget {
  final double pixelSize;
  DetailsItemCoverPlugWishlistInfoWidget(Set<WishlistTag> tags, {this.pixelSize = 1}) : super(tags);

  @override
  Widget buildPerkInfo(BuildContext context, WishlistTag tag) {
    return Row(
      children: [
        WishlistBadgeWidget(tag, size: 32 * pixelSize),
        SizedBox(
          width: 4,
        ),
        Text(
          getTagText(context, tag) ?? "",
          style: context.textTheme.caption.copyWith(fontSize: 18 * pixelSize),
        ),
      ],
    );
  }
}
