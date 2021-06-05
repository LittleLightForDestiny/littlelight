import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/wishlist_builds/wishlist_build_perks.widget.dart';

class WishlistBuildsWidget extends StatelessWidget {
  final DestinyItemComponent item;

  WishlistBuildsWidget(this.item, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var builds = WishlistsService().getWishlistBuilds(itemHash: item?.itemHash);

    return Container(
      padding: EdgeInsets.all(8),
      child: Column(children: [
        HeaderWidget(
            child: Container(
          alignment: Alignment.centerLeft,
          child: TranslatedTextWidget(
            "Wishlist Builds",
            uppercase: true,
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        )),
        buildWishlistBuilds(context, builds)
      ]),
    );
  }

  buildWishlistBuilds(BuildContext context, List<WishlistBuild> builds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: builds
              ?.map((build) => WishlistBuildPerksWidget(build: build))
              ?.toList() ??
          [],
    );
  }
}
