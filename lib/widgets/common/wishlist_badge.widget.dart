// @dart=2.9

import 'package:flutter/material.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/utils/wishlists_data.dart';

class WishlistBadgeWidget extends StatelessWidget {
  final WishlistTag tag;
  final double size;

  const WishlistBadgeWidget({this.tag, this.size = 24});

  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 2),
        height: size,
        child: AspectRatio(
            aspectRatio: 1,
            child: Container(
                alignment: Alignment.center,
                decoration:
                    WishlistsData.getBoxDecoration(context, tag).copyWith(borderRadius: BorderRadius.circular(4)),
                child: WishlistsData.getIcon(context, tag, size))));
  }
}
